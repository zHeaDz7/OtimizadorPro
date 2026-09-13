# Só DIAGNOSTICA -- se você estiver em Wi-Fi, mostra canal, banda
# (2.4GHz/5GHz) e força de sinal. Ajuda a saber se vale trocar de canal
# ou aproximar do roteador.
$ErrorActionPreference = "SilentlyContinue"

$adapter = Get-NetAdapter -Physical | Where-Object { $_.Status -eq "Up" -and $_.PhysicalMediaType -match "802.11|Wireless|Native 802.11" } | Select-Object -First 1
Write-Output "=== WI-FI ==="
Write-Output ""
if (-not $adapter) {
  Write-Output "Você não está conectado por Wi-Fi agora (está em cabo, ou sem rede) -- nada pra diagnosticar aqui."
  return
}

$saida = netsh wlan show interfaces 2>&1
$sinal = ($saida | Select-String -Pattern "Sinal|Signal").Line
$canal = ($saida | Select-String -Pattern "^\s*Canal|^\s*Channel").Line
$banda = ($saida | Select-String -Pattern "Tipo de radio|Radio type").Line
$ssid = ($saida | Select-String -Pattern "^\s*SSID" | Select-Object -First 1).Line

if ($ssid) { Write-Output "  Rede: $($ssid -replace '.*:\s*', '')" }
if ($sinal) { Write-Output "  Sinal: $($sinal -replace '.*:\s*', '')" }
if ($canal) {
  $canalNum = ($canal -replace '.*:\s*', '').Trim()
  Write-Output "  Canal: $canalNum"
  if ($canalNum -match "^\d+$" -and [int]$canalNum -le 14) {
    Write-Output "  AVISO: você está na banda de 2.4GHz (canal $canalNum) -- mais alcance,"
    Write-Output "  mas mais sujeita a interferência (micro-ondas, outros roteadores). Se o"
    Write-Output "  seu roteador e o adaptador suportam 5GHz e você não está longe demais,"
    Write-Output "  mudar pra 5GHz costuma dar ping mais estável."
  }
}
if ($banda) { Write-Output "  Tipo: $($banda -replace '.*:\s*', '')" }

Write-Output ""
Write-Output "Lembrete: cabo de rede sempre bate Wi-Fi em latência e estabilidade,"
Write-Output "mesmo com sinal Wi-Fi perfeito."
