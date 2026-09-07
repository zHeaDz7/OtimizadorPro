# So DIAGNOSTICA -- tenta ler a temperatura/throttling da CPU. Nem toda
# maquina expoe isso pro Windows sem um sensor de terceiro instalado
# (esse dado geralmente vem de WMI so em alguns fabricantes/notebooks) --
# quando nao da pra ler, o script avisa em vez de inventar um numero.
$ErrorActionPreference = "SilentlyContinue"

Write-Output "=== TEMPERATURA / THROTTLING DE CPU ==="
Write-Output ""

$termico = Get-CimInstance -Namespace "root\WMI" -ClassName "MSAcpi_ThermalZoneTemperature" -ErrorAction SilentlyContinue
if ($termico) {
  foreach ($t in $termico) {
    $celsius = [math]::Round(($t.CurrentTemperature / 10) - 273.15, 1)
    Write-Output "  Zona termica: $celsius C"
  }
} else {
  Write-Output "Esse Windows/placa-mae nao expoe temperatura via WMI padrao (comum --"
  Write-Output "a maioria dos fabricantes so libera esse dado pra software proprio, tipo"
  Write-Output "HWiNFO, HWMonitor ou o app da propria placa-mae/notebook)."
}
Write-Output ""

$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
if ($cpu) {
  Write-Output "CPU: $($cpu.Name.Trim())"
  Write-Output "Velocidade atual: $($cpu.CurrentClockSpeed) MHz (maxima: $($cpu.MaxClockSpeed) MHz)"
  if ($cpu.CurrentClockSpeed -lt ($cpu.MaxClockSpeed * 0.7)) {
    Write-Output "AVISO: velocidade atual bem abaixo da maxima -- pode ser so economia de"
    Write-Output "energia em repouso (normal se voce nao esta jogando agora), ou pode ser"
    Write-Output "throttling termico se isso acontecer TAMBEM durante o jogo. Pra saber ao"
    Write-Output "certo, recomendamos instalar o HWiNFO (gratuito, so pra monitorar -- nao"
    Write-Output "mexe em nada) e ver a temperatura durante o jogo."
  }
}
