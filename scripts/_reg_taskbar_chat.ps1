# Remove o icone de Chat/Teams da barra de tarefas do Windows 11. So
# interface -- se voce usa o Teams por fora (janela normal), continua
# funcionando igual, so some o atalho fixo da barra de tarefas.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"
$path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

try {
  if ($Action -eq "Status") {
    $v = (Get-ItemProperty -Path $path -Name "TaskbarMn" -ErrorAction SilentlyContinue).TaskbarMn
    if ($v -eq 0) { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
  if ($Action -eq "Reverter") {
    Set-ItemProperty -Path $path -Name "TaskbarMn" -Value 1 -Type DWord -Force
    Write-Output "on: icone de Chat voltou pra barra de tarefas."
  } else {
    Set-ItemProperty -Path $path -Name "TaskbarMn" -Value 0 -Type DWord -Force
    Write-Output "on: icone de Chat removido da barra de tarefas."
  }
  # So mata o Explorer -- o Windows religa ele sozinho automaticamente
  # como shell. Ver comentario identico em _reg_widgets.ps1.
  Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
} catch {
  Write-Output "AVISO: nao consegui mudar essa configuracao ($_)"
}
