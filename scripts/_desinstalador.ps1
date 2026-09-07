# Lista programas instalados (classicos E apps da Microsoft Store/UWP) e
# deixa escolher UM por vez pra desinstalar. DIFERENTE de tudo mais nesse
# programa: desinstalar NAO e uma configuracao reversivel com um clique --
# e a mesma acao de "Configuracoes > Aplicativos > Desinstalar". Por isso:
# nunca em lote, sempre confirma o nome antes, e pra programas classicos
# abrimos o desinstalador OFICIAL de cada fabricante (visivel na tela,
# igual ao Painel de Controle faria) em vez de tentar forcar modo
# silencioso -- assim voce ve exatamente o que esta acontecendo e pode
# cancelar a qualquer momento dentro do proprio desinstalador.
#
# Depois de desinstalar um programa CLASSICO, procura resto que o
# desinstalador oficial dele pode ter deixado pra tras (chave de
# registro orfa, pasta de configuracao/cache) -- mas SO procura por
# nomes que batem exatamente com o programa que ACABOU de sair (nunca
# uma varredura generica no registro inteiro, isso seria arriscado
# demais / e exatamente o tipo de coisa que "limpador de registro"
# generico faz de forma perigosa). Mostra tudo que achou com o caminho
# completo e avisa que pode ter configuracao/save que voce queira
# manter, antes de apagar qualquer coisa -- e sempre com voce escolhendo
# item por item, nunca em lote.
$ErrorActionPreference = "SilentlyContinue"

function Get-ProgramasClassicos {
  $caminhos = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
  )
  $lista = @()
  foreach ($c in $caminhos) {
    Get-ItemProperty -Path $c -ErrorAction SilentlyContinue | ForEach-Object {
      if ($_.DisplayName -and -not $_.SystemComponent -and $_.UninstallString) {
        $tamanhoMB = if ($_.EstimatedSize) { [math]::Round($_.EstimatedSize / 1024, 0) } else { $null }
        $lista += [PSCustomObject]@{
          Nome = $_.DisplayName
          Publicadora = $_.Publisher
          TamanhoMB = $tamanhoMB
          UninstallString = $_.UninstallString
          InstallLocation = $_.InstallLocation
          Tipo = "classico"
        }
      }
    }
  }
  return @($lista | Sort-Object Nome -Unique)
}

function Get-AppsUWP {
  $apps = Get-AppxPackage -ErrorAction SilentlyContinue | Where-Object {
    -not $_.IsFramework -and -not $_.IsResourcePackage -and $_.SignatureKind -ne "System"
  }
  $lista = @()
  foreach ($a in $apps) {
    $lista += [PSCustomObject]@{
      Nome = $a.Name
      Publicadora = $a.Publisher
      TamanhoMB = $null
      UninstallString = $a.PackageFullName
      InstallLocation = $null
      Tipo = "uwp"
    }
  }
  return @($lista | Sort-Object Nome -Unique)
}

function Find-Residuos($nome, $publicadora, $installLocation) {
  $achados = @()

  # Nomes candidatos pra comparar: nome completo, nome sem numero de
  # versao no final, e a publicadora -- so isso, nada de busca parcial
  # solta que poderia pegar programa errado.
  $nomeCurto = ($nome -replace '[\s\-_]*[\d]+(\.[\d]+)*[\s]*$', '').Trim()
  $publicadoraCurta = if ($publicadora) { ($publicadora -replace ',?\s*(Inc\.?|LLC|Ltd\.?|Corporation|Corp\.?)$', '').Trim() } else { $null }
  $candidatos = @($nome, $nomeCurto, $publicadora, $publicadoraCurta) | Where-Object { $_ -and $_.Trim().Length -gt 2 } | Select-Object -Unique

  if ($candidatos.Count -eq 0) { return $achados }

  # 1) Registro -- so subchave com nome EXATAMENTE igual a um candidato
  # (case-insensitive), nunca substring/wildcard.
  foreach ($base in @("HKCU:\Software", "HKLM:\Software", "HKLM:\Software\WOW6432Node")) {
    if (Test-Path $base) {
      Get-ChildItem -Path $base -ErrorAction SilentlyContinue | Where-Object {
        $sub = $_.PSChildName
        @($candidatos | Where-Object { $sub -eq $_ }).Count -gt 0
      } | ForEach-Object {
        $achados += [PSCustomObject]@{
          Tipo = "Registro"
          Caminho = ($_.Name -replace "^HKEY_CURRENT_USER", "HKCU:" -replace "^HKEY_LOCAL_MACHINE", "HKLM:")
          CaminhoReal = $_.PSPath
          TamanhoMB = $null
        }
      }
    }
  }

  # 2) Pastas -- pasta de instalacao (se ainda existir) + AppData/
  # LocalAppData/ProgramData com nome exatamente igual a um candidato.
  $pastasCandidatas = @()
  if ($installLocation -and $installLocation.Trim().Length -gt 3 -and (Test-Path $installLocation)) {
    # Nunca considera uma pasta-raiz generica (protecao contra registro malformado)
    if ($installLocation -notmatch "^[A-Za-z]:\\?$" -and $installLocation -ne "C:\Program Files" -and $installLocation -ne "C:\Program Files (x86)") {
      $pastasCandidatas += $installLocation
    }
  }
  foreach ($base in @($env:APPDATA, $env:LOCALAPPDATA, $env:ProgramData)) {
    foreach ($c in $candidatos) {
      $p = Join-Path $base $c
      if (Test-Path $p) { $pastasCandidatas += $p }
    }
  }
  foreach ($p in @($pastasCandidatas | Select-Object -Unique)) {
    $tamanhoMB = [math]::Round(((Get-ChildItem -LiteralPath $p -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { -not $_.PSIsContainer } | Measure-Object -Property Length -Sum).Sum) / 1MB, 1)
    $achados += [PSCustomObject]@{ Tipo = "Pasta"; Caminho = $p; CaminhoReal = $p; TamanhoMB = $tamanhoMB }
  }

  return $achados
}

Write-Output "Lendo programas instalados..."
$classicos = Get-ProgramasClassicos
$uwp = Get-AppsUWP
$todos = @($classicos) + @($uwp)

if ($todos.Count -eq 0) {
  Write-Output "Nao consegui ler a lista de programas instalados."
  return
}

Write-Output ""
Write-Output "=== PROGRAMAS INSTALADOS ($($todos.Count)) ==="
Write-Output ""
$i = 1
$indice = @{}
foreach ($p in $todos) {
  $tam = if ($p.TamanhoMB) { " ($($p.TamanhoMB) MB)" } else { "" }
  $tipoLabel = if ($p.Tipo -eq "uwp") { " [app da Microsoft Store]" } else { "" }
  Write-Output ("  {0,3}. {1}{2}{3}" -f $i, $p.Nome, $tam, $tipoLabel)
  $indice[$i] = $p
  $i++
}
Write-Output ""
Write-Output "  0. Nao desinstalar nada, so queria ver"
Write-Output ""
Write-Output "AVISO IMPORTANTE: desinstalar NAO tem 'desfazer' -- se quiser o programa de"
Write-Output "volta depois, vai ter que instalar de novo. So escolha um numero, um por"
Write-Output "vez. Programa classico abre o desinstalador oficial dele (voce confirma"
Write-Output "la tambem); app da Microsoft Store remove direto (pode reinstalar pela"
Write-Output "Microsoft Store depois, de graca, se for um app deles)."
$escolha = Read-Host "Digite UM numero pra desinstalar, ou 0"

if ($escolha -eq "0" -or [string]::IsNullOrWhiteSpace($escolha)) {
  Write-Output "Nada desinstalado."
  return
}
if ($escolha -notmatch "^\d+$" -or -not $indice.ContainsKey([int]$escolha)) {
  Write-Output "Numero invalido. Nada desinstalado."
  return
}

$alvo = $indice[[int]$escolha]
Write-Output ""
Write-Output "Voce escolheu: $($alvo.Nome)"
$confirma = Read-Host "Tem certeza que quer desinstalar isso? Digite o nome 'sim' pra confirmar"
if ($confirma -ne "sim") {
  Write-Output "Cancelado, nada desinstalado."
  return
}

$desinstalouOk = $false
try {
  if ($alvo.Tipo -eq "uwp") {
    Remove-AppxPackage -Package $alvo.UninstallString -ErrorAction Stop
    Write-Output "on: '$($alvo.Nome)' removido."
    $desinstalouOk = $true
  } else {
    $cmd = $alvo.UninstallString
    if ($cmd -match "msiexec") {
      # Normaliza pra rodar com interface visivel (sem /quiet forcado)
      if ($cmd -notmatch "/I") { $cmd = $cmd -replace "/X", "/I" }
      Start-Process "msiexec.exe" -ArgumentList ($cmd -replace ".*msiexec\.exe", "").Trim() -Wait
    } else {
      Start-Process -FilePath $cmd -Wait
    }
    Write-Output "on: desinstalador de '$($alvo.Nome)' foi executado. Se ele pediu mais alguma"
    Write-Output "confirmacao numa janela, isso ja foi tratado por voce ali."
    $desinstalouOk = $true
  }
} catch {
  Write-Output "AVISO: nao consegui iniciar a desinstalacao de '$($alvo.Nome)' ($_). Tente"
  Write-Output "pelo caminho normal: Configuracoes > Aplicativos > Aplicativos instalados."
}

# So procura resto pra programa CLASSICO (apps da Microsoft Store ja saem
# limpos -- o Windows guarda os dados deles isolados e Remove-AppxPackage
# ja limpa tudo sozinho, confirmado testando).
if ($desinstalouOk -and $alvo.Tipo -eq "classico") {
  Write-Output ""
  Write-Output "Procurando resto que o desinstalador possa ter deixado pra tras..."
  $residuos = @(Find-Residuos $alvo.Nome $alvo.Publicadora $alvo.InstallLocation)

  if ($residuos.Count -eq 0) {
    Write-Output "Nao achei nenhum resto (chave de registro ou pasta) com o nome de '$($alvo.Nome)'."
  } else {
    Write-Output ""
    Write-Output "=== RESTOS ENCONTRADOS ($($residuos.Count)) ==="
    Write-Output ""
    $j = 1
    $indiceResiduo = @{}
    foreach ($r in $residuos) {
      $tam = if ($r.TamanhoMB) { " ($($r.TamanhoMB) MB)" } else { "" }
      Write-Output ("  {0,2}. [{1}] {2}{3}" -f $j, $r.Tipo, $r.Caminho, $tam)
      $indiceResiduo[$j] = $r
      $j++
    }
    Write-Output ""
    Write-Output "AVISO: pastas podem conter configuracao, save de jogo ou log que voce"
    Write-Output "ainda queira -- confira os caminhos acima antes de apagar. So remova o"
    Write-Output "que voce reconhece como sendo mesmo do '$($alvo.Nome)'."
    $escolhaResiduo = Read-Host "Numeros pra APAGAR (separados por virgula), ou Enter pra deixar como esta"
    if (-not [string]::IsNullOrWhiteSpace($escolhaResiduo)) {
      foreach ($num in ($escolhaResiduo -split ",")) {
        $num = $num.Trim()
        if ($num -match "^\d+$" -and $indiceResiduo.ContainsKey([int]$num)) {
          $r = $indiceResiduo[[int]$num]
          try {
            if ($r.Tipo -eq "Registro") {
              Remove-Item -Path $r.CaminhoReal -Recurse -Force -ErrorAction Stop
            } else {
              Remove-Item -LiteralPath $r.CaminhoReal -Recurse -Force -ErrorAction Stop
            }
            Write-Output "apagado: $($r.Caminho)"
          } catch {
            Write-Output "nao consegui apagar $($r.Caminho): $_"
          }
        }
      }
    } else {
      Write-Output "Nada apagado dos restos -- ficaram como estavam."
    }
  }
}
