# So DIAGNOSTICA -- verifica se a RAM esta rodando em modo Dual Channel
# (2+ pentes trabalhando em paralelo, o normal/recomendado) ou Single
# Channel (só 1 pente, ou pentes em slots errados) -- isso pode ser um
# gargalo GRANDE de desempenho (perde banda de memoria, principalmente
# em CPU com grafico integrado ou jogos que dependem de CPU).
$ErrorActionPreference = "SilentlyContinue"

$pentes = @(Get-CimInstance Win32_PhysicalMemory)
$n = $pentes.Count

Write-Output "=== CANAIS DE MEMORIA RAM ==="
Write-Output ""
if ($n -eq 0) {
  Write-Output "Nao consegui ler informacao dos pentes de RAM."
  return
}

Write-Output "Pentes de RAM detectados: $n"
foreach ($p in $pentes) {
  $tamanhoGB = [math]::Round($p.Capacity / 1GB, 0)
  Write-Output "  Slot $($p.DeviceLocator): ${tamanhoGB}GB @ $($p.Speed)MHz"
}
Write-Output ""

if ($n -eq 1) {
  Write-Output "AVISO: so tem 1 pente de RAM instalado -- isso e SINGLE CHANNEL."
  Write-Output "Adicionar um segundo pente IGUAL (mesma capacidade/velocidade) no slot"
  Write-Output "certo (geralmente alternado, ver manual da placa-mae) ativa o Dual"
  Write-Output "Channel, que pode dar um ganho real de FPS em varios jogos -- e a"
  Write-Output "melhoria de hardware barata que mais impacta desempenho pra quem so"
  Write-Output "tem 1 pente."
} elseif ($n % 2 -ne 0) {
  Write-Output "AVISO: numero impar de pentes ($n) -- pode nao estar em Dual Channel"
  Write-Output "completo dependendo de qual slot cada um esta. Verifique no manual da"
  Write-Output "placa-mae quais slots formam par (geralmente A2+B2)."
} else {
  $capacidades = @($pentes | Select-Object -ExpandProperty Capacity -Unique)
  if ($capacidades.Count -eq 1) {
    Write-Output "Bom sinal: $n pentes do mesmo tamanho -- provavelmente ja esta em Dual"
    Write-Output "Channel (ou superior), desde que estejam nos slots corretos."
  } else {
    Write-Output "AVISO: os pentes tem capacidades DIFERENTES -- ainda funciona, mas o"
    Write-Output "Dual Channel só cobre ate o tamanho do menor pente (o resto roda em"
    Write-Output "Single Channel). Pentes iguais dao o melhor resultado."
  }
}
