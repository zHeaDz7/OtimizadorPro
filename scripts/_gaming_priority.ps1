# Ajusta o MMCSS (Multimedia Class Scheduler) do Windows -- e o sistema que
# decide quanto de CPU cada tipo de tarefa ganha em tempo real. Por padrao
# o Windows reserva uma fatia de CPU pra tarefas de "sistema" mesmo com um
# jogo pesado rodando. Zerar o "System Responsiveness" e dar prioridade alta
# pra tarefas de "Games" no perfil MMCSS e uma otimizacao oficial da
# Microsoft (documentada pra apps multimidia/jogos), so que raramente vem
# configurada assim por padrao.
$ErrorActionPreference = "Stop"

try {
  $sysProfilePath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
  Set-ItemProperty -Path $sysProfilePath -Name "SystemResponsiveness" -Value 0 -Type DWord -Force
  Write-Output "on: System Responsiveness zerado (CPU prioriza o app em uso, nao tarefas de fundo)"
} catch {
  Write-Output "AVISO: precisa ser Administrador pra essa parte ($_)"
}

try {
  $gamesTaskPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
  if (-not (Test-Path $gamesTaskPath)) { New-Item -Path $gamesTaskPath -Force | Out-Null }
  Set-ItemProperty -Path $gamesTaskPath -Name "GPU Priority" -Value 8 -Type DWord -Force
  Set-ItemProperty -Path $gamesTaskPath -Name "Priority" -Value 6 -Type DWord -Force
  Set-ItemProperty -Path $gamesTaskPath -Name "Scheduling Category" -Value "High" -Type String -Force
  Set-ItemProperty -Path $gamesTaskPath -Name "SFIO Priority" -Value "High" -Type String -Force
  Write-Output "on: perfil 'Games' do Windows com prioridade alta de CPU/GPU"
} catch {
  Write-Output "AVISO: precisa ser Administrador pra essa parte ($_)"
}

Write-Output ""
Write-Output "Reinicie o PC pra valer 100%."
