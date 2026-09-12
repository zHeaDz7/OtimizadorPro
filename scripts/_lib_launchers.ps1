# Biblioteca compartilhada -- carregada via dot-source. Reconhece se um
# executavel escolhido pelo usuario pertence a um jogo de verdade,
# instalado por um launcher oficial (Steam, Epic, Xbox/Microsoft Store,
# Battle.net, EA App, Ubisoft Connect, GOG Galaxy, Riot Client). Usado
# pra recusar executaveis "soltos" (ex: jogo pirata) na preferencia de
# GPU por jogo -- o objetivo NAO e detectar pirataria de forma perfeita
# (impossivel so olhando o caminho do arquivo), e sim recusar qualquer
# coisa que nao esteja dentro de uma pasta que um launcher oficial real
# instalou nessa maquina.
#
# NAO defina $ErrorActionPreference aqui (mesmo motivo do _detect_games.ps1
# e do _lib_common.ps1: dot-source roda no escopo de quem chama).
#
# Nivel de confianca por launcher:
# - Steam e Epic Games: reaproveita Get-AllDetectedGames (_detect_games.ps1),
#   ja testado nesse projeto -- confirmado, le libraryfolders.vdf/manifest real.
# - Xbox/Microsoft Store: Get-AppxPackage -> InstallLocation. Aproximado por
#   natureza: nao da pra saber com certeza se um pacote instalado e um JOGO
#   especifico (a Store nao expoe isso via PowerShell puro) -- mas garante
#   que veio de um pacote assinado, instalado pela Store, nao um exe solto.
# - Battle.net, EA App, Ubisoft Connect, GOG Galaxy, Riot Client: cada um tem
#   formato de manifesto proprio que NAO foi verificado contra uma instalacao
#   real nesta sessao -- em vez de chutar um caminho de registro especifico e
#   arriscar errar, usa o mecanismo generico e 100% documentado do Windows
#   (chave Uninstall, InstallLocation + Publisher) como fonte pra esses 5.
#   TODO: se confirmar num PC real com esses launchers instalados, trocar
#   por leitura direta do manifesto de cada um (mais preciso).

. (Join-Path $PSScriptRoot "_detect_games.ps1")

function Get-JogosLegitimosInstalados {
  $pastas = @()
  $exesExatos = @()

  try {
    foreach ($jogo in (Get-AllDetectedGames)) {
      if ($jogo.Caminho) { $pastas += $jogo.Caminho }
    }
  } catch {}

  try {
    $manifestDir = "C:\ProgramData\Epic\EpicGamesLauncher\Data\Manifests"
    if (Test-Path $manifestDir) {
      Get-ChildItem -LiteralPath $manifestDir -Filter "*.item" -ErrorAction SilentlyContinue | ForEach-Object {
        try {
          $d = Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json
          if ($d.InstallLocation -and (Test-Path $d.InstallLocation)) {
            $pastas += $d.InstallLocation
            if ($d.LaunchExecutable) {
              $exesExatos += (Join-Path $d.InstallLocation $d.LaunchExecutable)
            }
          }
        } catch {}
      }
    }
  } catch {}

  try {
    # Fallback: alem do manifesto (que pode estar desatualizado -- caso real
    # confirmado com Fortnite, que fica instalado mas some do manifesto
    # atual), confia tambem na pasta padrao onde o Epic Games Launcher
    # instala tudo por padrao. E um trade-off honesto: alguem poderia
    # forcar uma pasta chamada "Epic Games" na mao, mas o objetivo aqui e
    # barrar exe solto/pirata, nao resistir a um usuario ativamente
    # tentando enganar a propria ferramenta.
    foreach ($raizPF in @($env:ProgramFiles, ${env:ProgramFiles(x86)})) {
      if ($raizPF) {
        $raizEpic = Join-Path $raizPF "Epic Games"
        if (Test-Path $raizEpic) { $pastas += $raizEpic }
      }
    }
  } catch {}

  try {
    Get-AppxPackage -ErrorAction SilentlyContinue | ForEach-Object {
      if ($_.InstallLocation -and (Test-Path $_.InstallLocation)) { $pastas += $_.InstallLocation }
    }
  } catch {}

  # Fallback generico pra Battle.net, EA App, Ubisoft Connect, GOG Galaxy,
  # Riot Client -- chave de desinstalacao padrao do Windows, filtrada por
  # publisher conhecido. Mecanismo real e documentado, so nao e tao preciso
  # quanto ler o manifesto proprio de cada launcher (ainda nao verificado).
  $publishersConhecidos = @("Blizzard Entertainment", "Electronic Arts", "Ubisoft", "GOG.com", "GOG", "Riot Games")
  $raizesUninstall = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
  )
  foreach ($raiz in $raizesUninstall) {
    try {
      Get-ItemProperty -Path $raiz -ErrorAction SilentlyContinue | Where-Object {
        $_.Publisher -and $_.InstallLocation -and ($publishersConhecidos -contains $_.Publisher) -and (Test-Path $_.InstallLocation)
      } | ForEach-Object { $pastas += $_.InstallLocation }
    } catch {}
  }

  return @{
    Pastas     = @($pastas | Where-Object { $_ } | Select-Object -Unique)
    ExesExatos = @($exesExatos | Where-Object { $_ } | Select-Object -Unique)
  }
}

function Test-ExecutavelEhJogoLegitimo {
  param([Parameter(Mandatory)][string]$Caminho)
  try {
    $jogos = Get-JogosLegitimosInstalados
    $exeNorm = $Caminho.TrimEnd('\')
    if ($jogos.ExesExatos -contains $exeNorm) { return $true }
    foreach ($pasta in $jogos.Pastas) {
      $pastaNorm = $pasta.TrimEnd('\')
      if ($exeNorm -like "$pastaNorm\*") { return $true }
    }
    return $false
  } catch {
    return $false
  }
}
