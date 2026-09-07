# Remove o botao de Widgets da barra de tarefas do Windows 11 (aquele
# painel de noticias/tempo que abre do lado esquerdo). So interface --
# nao desliga nenhum servico nem processo em segundo plano por conta
# propria, so tira o botao de acesso.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"
$path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

try {
  if ($Action -eq "Status") {
    $v = (Get-ItemProperty -Path $path -Name "TaskbarDa" -ErrorAction SilentlyContinue).TaskbarDa
    if ($v -eq 0) { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
  if ($Action -eq "Reverter") {
    Set-ItemProperty -Path $path -Name "TaskbarDa" -Value 1 -Type DWord -Force
    Write-Output "on: botao de Widgets voltou pra barra de tarefas."
  } else {
    Set-ItemProperty -Path $path -Name "TaskbarDa" -Value 0 -Type DWord -Force
    Write-Output "on: botao de Widgets removido da barra de tarefas."
  }
  Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
  Start-Sleep -Milliseconds 500
  Start-Process explorer.exe
} catch {
  Write-Output "AVISO: nao consegui mudar essa configuracao ($_)"
}
