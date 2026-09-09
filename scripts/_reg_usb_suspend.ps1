# Desliga a "Suspensao Seletiva de USB" do Windows -- um recurso de economia
# de energia que deixa o Windows "adormecer" portas USB ociosas (incluindo
# mouse/teclado) por um instante antes de acorda-las de novo. Isso pode
# causar um micro-atraso perceptivel na primeira movimentacao apos parar de
# mexer o mouse. E uma configuracao oficial do Windows (a mesma do Gerenciador
# de Dispositivos > seu mouse/teclado > Gerenciamento de Energia), so estamos
# aplicando pra TODOS os dispositivos USB de uma vez via plano de energia.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"
$subgrupo = "2a737441-1930-4402-8d77-b2bebba308a3"   # USB settings
$config = "48e6b7a6-50f5-4782-a5d4-53bb8f07e226"     # USB selective suspend setting

function Get-UsbSuspendValor {
  # Le o valor de AC (primeiro "0x..." que aparece na saida, independente do idioma do Windows)
  $saida = powercfg /query SCHEME_CURRENT $subgrupo $config 2>&1
  $hex = ($saida | Select-String -Pattern "0x[0-9a-fA-F]+" -AllMatches | Select-Object -First 1).Matches[0].Value
  return ([convert]::ToInt32($hex, 16) -ne 0)
}

try {
  if ($Action -eq "Status") {
    if (Get-UsbSuspendValor) { Write-Output "DESLIGADO (suspensao ativa, padrao do Windows)" } else { Write-Output "LIGADO" }
    return
  }

  if ($Action -eq "Reverter") {
    powercfg /setacvalueindex SCHEME_CURRENT $subgrupo $config 1 | Out-Null
    powercfg /setdcvalueindex SCHEME_CURRENT $subgrupo $config 1 | Out-Null
    powercfg /setactive SCHEME_CURRENT | Out-Null
    Write-Output "on: Suspensao Seletiva de USB voltou ao padrao do Windows (ligada)."
    return
  }

  if (-not (Get-UsbSuspendValor)) {
    Write-Output "Ja esta desligada."
    return
  }
  powercfg /setacvalueindex SCHEME_CURRENT $subgrupo $config 0 | Out-Null
  powercfg /setdcvalueindex SCHEME_CURRENT $subgrupo $config 0 | Out-Null
  powercfg /setactive SCHEME_CURRENT | Out-Null
  Write-Output "on: Suspensao Seletiva de USB desligada (mouse/teclado nao 'dormem' mais)."
} catch {
  Write-Output "AVISO: nao consegui mudar essa configuracao ($_)"
}
