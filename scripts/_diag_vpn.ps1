# Só DIAGNOSTICA -- detecta se tem VPN ativa. VPN quase sempre AUMENTA o
# ping (o tráfego dá uma volta a mais por um servidor da VPN antes de
# chegar no destino), a não ser em casos específicos (jogo bloqueado
# geograficamente, ou rota do provedor ruim que a VPN contorna). Não
# desliga nada -- só avisa que está ativa, caso você não lembrasse.
$ErrorActionPreference = "SilentlyContinue"

$adaptadoresVpn = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object {
  $_.InterfaceDescription -match "VPN|WireGuard|OpenVPN|Tailscale|NordLynx|TAP-Windows|Cisco AnyConnect" -and $_.Status -eq "Up"
}

Write-Output "=== VPN ==="
Write-Output ""
if (-not $adaptadoresVpn) {
  Write-Output "Nenhuma VPN ativa detectada agora."
  return
}

foreach ($a in $adaptadoresVpn) {
  Write-Output "  Ativa: $($a.InterfaceDescription)"
}
Write-Output ""
Write-Output "AVISO: VPN ativa quase sempre AUMENTA o ping (o tráfego passa por mais um"
Write-Output "servidor antes de chegar no destino). Se você não precisa dela pra esse"
Write-Output "jogo específico (bloqueio geográfico, contornar rota ruim do provedor),"
Write-Output "desligar costuma reduzir o ping."
