# Desliga a Inicializacao Rapida (Fast Startup) do Windows -- ela salva um
# "hibernar parcial" do kernel/drivers pra ligar mais rapido, mas pode
# causar problema em PC com dual-boot (Linux) ou depois de atualizar
# driver/placa de video (o Windows nao reinicia "de verdade", so acorda o
# estado salvo). Desligar deixa o boot ~alguns segundos mais lento, mas
# cada desligamento fica 100% limpo.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"
$path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"

try {
  if ($Action -eq "Status") {
    $v = (Get-ItemProperty -Path $path -Name "HiberbootEnabled" -ErrorAction SilentlyContinue).HiberbootEnabled
    if ($v -eq 0) { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if ($Action -eq "Reverter") {
    Set-ItemProperty -Path $path -Name "HiberbootEnabled" -Value 1 -Type DWord -Force
    Write-Output "on: Inicializacao Rapida religada (padrao)."
  } else {
    Set-ItemProperty -Path $path -Name "HiberbootEnabled" -Value 0 -Type DWord -Force
    Write-Output "on: Inicializacao Rapida desligada -- todo desligamento agora e completo de verdade."
  }
} catch {
  Write-Output "AVISO: precisa ser Administrador pra essa parte ($_)"
}
