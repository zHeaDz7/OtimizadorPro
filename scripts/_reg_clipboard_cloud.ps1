# Desliga o envio automatico da area de transferencia pra nuvem Microsoft
# (sincronizar copiar/colar entre PCs diferentes). Continua funcionando
# normal no mesmo PC -- so para de mandar o que voce copia pra conta
# Microsoft na nuvem.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"
$path = "HKCU:\Software\Microsoft\Clipboard"

try {
  if ($Action -eq "Status") {
    $v = (Get-ItemProperty -Path $path -Name "CloudClipboardAutomaticUpload" -ErrorAction SilentlyContinue).CloudClipboardAutomaticUpload
    if ($v -eq 0) { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
  if ($Action -eq "Reverter") {
    Set-ItemProperty -Path $path -Name "CloudClipboardAutomaticUpload" -Value 1 -Type DWord -Force
    Write-Output "on: sincronizacao da area de transferencia com a nuvem religada (padrao)."
  } else {
    Set-ItemProperty -Path $path -Name "CloudClipboardAutomaticUpload" -Value 0 -Type DWord -Force
    Write-Output "on: area de transferencia nao sincroniza mais com a nuvem."
  }
} catch {
  Write-Output "AVISO: nao consegui mudar essa configuracao ($_)"
}
