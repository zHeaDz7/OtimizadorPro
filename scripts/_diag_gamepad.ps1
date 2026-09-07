# So DIAGNOSTICA -- lista controles/gamepads conectados e avisa sobre
# Bluetooth vs cabo/dongle. Bluetooth tem latencia real maior e mais
# instavel que conexao com fio ou dongle 2.4GHz proprio (tipo Xbox
# Wireless) -- relevante pra jogo que depende de reflexo.
$ErrorActionPreference = "SilentlyContinue"

$controles = Get-PnpDevice -Class "HIDClass" -ErrorAction SilentlyContinue | Where-Object {
  $_.FriendlyName -match "Controller|Gamepad|Xbox|DualShock|DualSense|Controle" -and $_.Status -eq "OK"
}

Write-Output "=== CONTROLES / GAMEPADS ==="
Write-Output ""
if (-not $controles) {
  Write-Output "Nenhum controle detectado conectado agora."
  return
}

foreach ($c in $controles) {
  $tipo = if ($c.InstanceId -match "^BTH|BLUETOOTH") { "Bluetooth" } elseif ($c.InstanceId -match "^USB") { "USB (cabo ou dongle)" } else { "Desconhecido" }
  Write-Output "  $($c.FriendlyName) -- $tipo"
  if ($tipo -eq "Bluetooth") {
    Write-Output "    AVISO: Bluetooth tem latencia maior e mais instavel que cabo ou"
    Write-Output "    dongle proprio (ex: Xbox Wireless Adapter). Pra jogo competitivo,"
    Write-Output "    cabo USB e a opcao com menos delay."
  }
}
