# Desliga o servico SysMain (Superfetch) -- ele pre-carrega na RAM os
# programas que voce mais usa, pra abrir mais rapido. Em disco SSD/NVMe
# moderno esse pre-carregamento quase nao faz diferenca (o SSD ja e rapido
# pra ler do zero) e so consome CPU/RAM em segundo plano. Em HD mecanico
# antigo, desligar pode deixar programas frequentes um pouco mais lentos
# pra abrir da primeira vez.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"

try {
  if ($Action -eq "Status") {
    $s = Get-Service -Name SysMain -ErrorAction SilentlyContinue
    if ($s -and $s.StartType -eq "Disabled") { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if ($Action -eq "Reverter") {
    Set-Service -Name SysMain -StartupType Automatic -ErrorAction Stop
    Start-Service -Name SysMain -ErrorAction SilentlyContinue
    Write-Output "on: SysMain (Superfetch) religado (padrao)."
  } else {
    Stop-Service -Name SysMain -Force -ErrorAction SilentlyContinue
    Set-Service -Name SysMain -StartupType Disabled -ErrorAction Stop
    Write-Output "on: SysMain (Superfetch) desligado."
  }
} catch {
  Write-Output "AVISO: precisa ser Administrador pra essa parte ($_)"
}
