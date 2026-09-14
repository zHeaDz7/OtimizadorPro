# Move os icones da barra de tarefas do Windows 11 pra esquerda (estilo
# Windows 10) em vez de centralizados. So preferencia visual, zero efeito
# em desempenho.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"
$path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

try {
  if ($Action -eq "Status") {
    $v = (Get-ItemProperty -Path $path -Name "TaskbarAl" -ErrorAction SilentlyContinue).TaskbarAl
    if ($v -eq 0) { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
  if ($Action -eq "Reverter") {
    Set-ItemProperty -Path $path -Name "TaskbarAl" -Value 1 -Type DWord -Force
    Write-Output "on: icones da barra de tarefas voltaram pro centro (padrao)."
  } else {
    Set-ItemProperty -Path $path -Name "TaskbarAl" -Value 0 -Type DWord -Force
    Write-Output "on: icones da barra de tarefas movidos pra esquerda."
  }
  # So mata o Explorer -- o Windows religa ele sozinho automaticamente
  # como shell. Ver comentario identico em _reg_widgets.ps1.
  Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
} catch {
  Write-Output "AVISO: nao consegui mudar essa configuracao ($_)"
}
