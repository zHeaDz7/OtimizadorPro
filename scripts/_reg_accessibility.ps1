# Desliga os ATALHOS de teclado que ativam recursos de Acessibilidade do
# Windows (Teclas de Aderencia/StickyKeys ao apertar Shift 5x, Teclas de
# Alternancia/ToggleKeys ao segurar Num Lock, Teclas de Filtragem/FilterKeys
# ao segurar Shift 8s) -- em jogo, apertar Shift ou Num Lock repetido por
# acidente pode abrir um popup do Windows no meio da partida. Isso NAO
# remove os recursos de acessibilidade (quem precisa deles continua
# ativando pelas Configuracoes > Acessibilidade normalmente) -- so tira o
# "gesto" que ativa sozinho sem querer. Nao precisa reiniciar, e imediato.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"

$chaves = @(
  @{ Path = "HKCU:\Control Panel\Accessibility\StickyKeys";       Padrao = "506"; Desligado = "58" }
  @{ Path = "HKCU:\Control Panel\Accessibility\ToggleKeys";       Padrao = "62";  Desligado = "58" }
  @{ Path = "HKCU:\Control Panel\Accessibility\Keyboard Response"; Padrao = "126"; Desligado = "58" }
)

try {
  if ($Action -eq "Status") {
    $ligado = $true
    foreach ($k in $chaves) {
      $v = (Get-ItemProperty -Path $k.Path -Name "Flags" -ErrorAction SilentlyContinue).Flags
      if ($v -ne $k.Desligado) { $ligado = $false }
    }
    if ($ligado) { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if ($Action -eq "Reverter") {
    foreach ($k in $chaves) {
      if (-not (Test-Path $k.Path)) { New-Item -Path $k.Path -Force | Out-Null }
      Set-ItemProperty -Path $k.Path -Name "Flags" -Value $k.Padrao -Type String
    }
    Write-Output "on: atalhos de acessibilidade voltaram ao padrao do Windows."
    return
  }

  foreach ($k in $chaves) {
    if (-not (Test-Path $k.Path)) { New-Item -Path $k.Path -Force | Out-Null }
    Set-ItemProperty -Path $k.Path -Name "Flags" -Value $k.Desligado -Type String
  }
  Write-Output "on: atalhos de StickyKeys/ToggleKeys/FilterKeys desligados (os recursos continuam disponiveis em Configuracoes > Acessibilidade se voce precisar)."
} catch {
  Write-Output "AVISO: nao consegui mudar essa configuracao ($_)"
}
