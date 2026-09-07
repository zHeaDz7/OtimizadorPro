# Desliga o ID de publicidade do Windows -- um identificador unico que apps
# usam pra te mostrar anuncio "personalizado" com base no que voce usa.
# So afeta privacidade/rastreamento de anuncio, nao muda desempenho.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"
$path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"

try {
  if ($Action -eq "Status") {
    $v = (Get-ItemProperty -Path $path -Name "Enabled" -ErrorAction SilentlyContinue).Enabled
    if ($v -eq 0) { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
  if ($Action -eq "Reverter") {
    Set-ItemProperty -Path $path -Name "Enabled" -Value 1 -Type DWord -Force
    Write-Output "on: ID de publicidade voltou a ficar ligado (padrao)."
  } else {
    Set-ItemProperty -Path $path -Name "Enabled" -Value 0 -Type DWord -Force
    Write-Output "on: ID de publicidade desligado."
  }
} catch {
  Write-Output "AVISO: nao consegui mudar essa configuracao ($_)"
}
