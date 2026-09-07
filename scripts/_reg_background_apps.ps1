# Impede que apps UWP/da Microsoft Store rodem em segundo plano sem
# estarem abertos na tela (a mesma chave que Configuracoes > Aplicativos
# > Aplicativos instalados > (app) > Opcoes avancadas > "Permissoes de
# apps em segundo plano" controla, so que pra todos de uma vez). Libera
# CPU/RAM que esses apps ficam usando sem voce estar olhando pra eles.
# Nao afeta programas classicos (.exe) instalados fora da Microsoft
# Store, so os UWP.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"
$path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"

try {
  if ($Action -eq "Status") {
    $v = (Get-ItemProperty -Path $path -Name "GlobalUserDisabled" -ErrorAction SilentlyContinue).GlobalUserDisabled
    if ($v -eq 1) { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }

  if ($Action -eq "Reverter") {
    Set-ItemProperty -Path $path -Name "GlobalUserDisabled" -Value 0 -Type DWord
    Write-Output "on: apps da Microsoft Store podem rodar em segundo plano de novo (padrao do Windows)."
    return
  }

  Set-ItemProperty -Path $path -Name "GlobalUserDisabled" -Value 1 -Type DWord
  Write-Output "on: apps da Microsoft Store bloqueados de rodar em segundo plano (so funcionam com a tela aberta)."
} catch {
  Write-Output "AVISO: nao consegui mudar essa configuracao ($_)"
}
