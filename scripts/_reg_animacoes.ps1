# Reduz/desliga animacoes de janela (minimizar, maximizar, abrir menu).
# Em PC mais fraco a interface responde mais na hora porque nao espera a
# animacao terminar -- ganho pequeno de "sensacao de velocidade", nao de
# FPS em jogo.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"
$pathDesktop = "HKCU:\Control Panel\Desktop\WindowMetrics"
$pathAdv = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

try {
  if ($Action -eq "Status") {
    $v = (Get-ItemProperty -Path $pathDesktop -Name "MinAnimate" -ErrorAction SilentlyContinue).MinAnimate
    if ($v -eq "0") { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if (-not (Test-Path $pathDesktop)) { New-Item -Path $pathDesktop -Force | Out-Null }
  if (-not (Test-Path $pathAdv)) { New-Item -Path $pathAdv -Force | Out-Null }

  if ($Action -eq "Reverter") {
    Set-ItemProperty -Path $pathDesktop -Name "MinAnimate" -Value "1" -Type String -Force
    Set-ItemProperty -Path $pathAdv -Name "TaskbarAnimations" -Value 1 -Type DWord -Force
    Write-Output "on: animacoes de janela religadas (padrao)."
  } else {
    Set-ItemProperty -Path $pathDesktop -Name "MinAnimate" -Value "0" -Type String -Force
    Set-ItemProperty -Path $pathAdv -Name "TaskbarAnimations" -Value 0 -Type DWord -Force
    Write-Output "on: animacoes de janela/barra de tarefas reduzidas."
    Write-Output "AVISO: pode precisar deslogar e logar de novo pra valer 100%."
  }
} catch {
  Write-Output "AVISO: nao consegui mudar essa configuracao ($_)"
}
