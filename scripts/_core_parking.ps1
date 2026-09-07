# "Core Parking" e um recurso de economia de energia que deixa o Windows
# "adormecer" nucleos da CPU que ele acha que nao vai precisar no momento,
# acordando eles de novo quando precisar. Isso economiza energia, mas o
# processo de acordar um nucleo parado leva um tempinho -- em jogos que
# usam varios nucleos de forma irregular (picos rapidos), isso pode causar
# microstutter. Desligar mantem todos os nucleos sempre prontos. E uma
# configuracao oficial do plano de energia do Windows (powercfg), so
# escondida da tela normal de Opcoes de Energia.
#
# NOTA: em algumas CPUs/drivers essa configuracao especifica do Windows
# vem travada em 0 (o proprio Windows nao permite outro valor nessa
# maquina) -- isso NAO e um erro do script, e uma limitacao da propria
# CPU/driver de energia. O script detecta isso e avisa em vez de tentar
# forcar um valor invalido.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"
$subgrupo = "54533251-82be-4824-96c1-47b60b740d00"   # Processor power management
$config = "0cc5b647-c1df-4637-891a-dec35c318583"     # Processor performance core parking min cores
$valorPadrao = 5      # padrao tipico do Windows (a maioria dos nucleos pode ser parada)

function Get-HexValores($saida) {
  # Extrai todos os "0x..." na ordem em que aparecem -- evita depender de
  # texto com acento, que pode vir com encoding diferente dependendo de
  # como a saida do powercfg (comando externo) e capturada.
  return @($saida | Select-String -Pattern "0x[0-9a-fA-F]+" -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { [convert]::ToInt32($_.Value, 16) })
}

function Get-CoreParkingRange {
  # Ordem no /qh: Minima, Maxima, Incremento, Atual AC, Atual DC
  $saida = powercfg /qh SCHEME_CURRENT $subgrupo $config 2>&1
  $vals = Get-HexValores $saida
  if ($vals.Count -lt 2) { return $null }
  return $vals[1]
}

function Get-CoreParkingValor {
  # Ordem no /query: Atual AC, Atual DC
  $saida = powercfg /query SCHEME_CURRENT $subgrupo $config 2>&1
  $vals = Get-HexValores $saida
  if ($vals.Count -lt 1) { return $null }
  return $vals[0]
}

try {
  $maxSuportado = Get-CoreParkingRange
  if (-not $maxSuportado -or $maxSuportado -le $valorPadrao) {
    Write-Output "AVISO: essa CPU/driver de energia nao permite ajustar essa configuracao nessa maquina (o Windows trava o valor maximo em $maxSuportado). Nao e falha do script -- e limitacao do hardware/driver."
    return
  }

  if ($Action -eq "Status") {
    $atual = Get-CoreParkingValor
    if ($atual -ge $maxSuportado) { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if ($Action -eq "Reverter") {
    powercfg /setacvalueindex SCHEME_CURRENT $subgrupo $config $valorPadrao | Out-Null
    powercfg /setdcvalueindex SCHEME_CURRENT $subgrupo $config $valorPadrao | Out-Null
    powercfg /setactive SCHEME_CURRENT | Out-Null
    Write-Output "on: Core Parking revertido pro padrao do Windows ($valorPadrao%)."
    return
  }

  powercfg /setacvalueindex SCHEME_CURRENT $subgrupo $config $maxSuportado | Out-Null
  powercfg /setdcvalueindex SCHEME_CURRENT $subgrupo $config $maxSuportado | Out-Null
  powercfg /setactive SCHEME_CURRENT | Out-Null
  Write-Output "on: Core Parking desligado (todos os nucleos da CPU ficam sempre ativos)."
} catch {
  Write-Output "AVISO: nao consegui mudar essa configuracao ($_)"
}
