# Desliga a Cortana (assistente de voz) via politica do Windows. Ela nao
# vem mais ativada por padrao em instalacoes novas do Windows 11, mas em
# upgrades antigos pode continuar rodando em segundo plano.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"
$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"

try {
  if ($Action -eq "Status") {
    $v = (Get-ItemProperty -Path $path -Name "AllowCortana" -ErrorAction SilentlyContinue).AllowCortana
    if ($v -eq 0) { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
  if ($Action -eq "Reverter") {
    Remove-ItemProperty -Path $path -Name "AllowCortana" -ErrorAction SilentlyContinue
    Write-Output "on: Cortana liberada de novo (padrao do Windows)."
  } else {
    Set-ItemProperty -Path $path -Name "AllowCortana" -Value 0 -Type DWord -Force
    Write-Output "on: Cortana desativada."
  }
} catch {
  Write-Output "AVISO: precisa ser Administrador pra essa parte ($_)"
}
