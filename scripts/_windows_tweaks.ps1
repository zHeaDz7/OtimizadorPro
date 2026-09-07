# Ajustes de Windows que cobrem a maior parte do que as ISOs "Windows Gamer"
# (GhostSpectre, KernelOS, etc.) vendem como diferencial -- so que feitos em
# CIMA do seu Windows normal e oficial, sem trocar o sistema operacional,
# sem risco de anticheat bloquear, e 100% reversivel.
# Cada item roda isolado -- se um falhar (ex: falta permissao de admin pra
# UM item especifico), os outros continuam aplicando normalmente.
$ErrorActionPreference = "Stop"

# 1) Game Mode ligado (prioriza o jogo em primeiro plano por recursos)
try {
  $gameBarPath = "HKCU:\Software\Microsoft\GameBar"
  if (-not (Test-Path $gameBarPath)) { New-Item -Path $gameBarPath -Force | Out-Null }
  Set-ItemProperty -Path $gameBarPath -Name "AutoGameModeEnabled" -Value 1 -Type DWord -Force
  Set-ItemProperty -Path $gameBarPath -Name "AllowAutoGameMode" -Value 1 -Type DWord -Force
  Write-Output "on: Game Mode do Windows ligado"
} catch {
  Write-Output "AVISO: nao consegui ligar o Game Mode ($_)"
}

# 2) Xbox Game Bar / gravacao em segundo plano desligada (o app Game Bar em
# si continua instalado, so paramos a gravacao/overlay dele rodando atras).
# A parte por-usuario (HKCU) funciona sem admin; a politica de maquina
# (HKLM) precisa de admin -- se nao tiver, so pula essa parte extra.
try {
  $gameDvrPath = "HKCU:\System\GameConfigStore"
  if (-not (Test-Path $gameDvrPath)) { New-Item -Path $gameDvrPath -Force | Out-Null }
  Set-ItemProperty -Path $gameDvrPath -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force
  Write-Output "on: gravacao em segundo plano do Xbox Game Bar desligada (usuario)"
} catch {
  Write-Output "AVISO: nao consegui desligar o Game Bar (usuario) ($_)"
}
try {
  $gameDvrPolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
  if (-not (Test-Path $gameDvrPolicy)) { New-Item -Path $gameDvrPolicy -Force | Out-Null }
  Set-ItemProperty -Path $gameDvrPolicy -Name "AllowGameDVR" -Value 0 -Type DWord -Force
  Write-Output "on: gravacao em segundo plano do Xbox Game Bar bloqueada (maquina toda)"
} catch {
  Write-Output "AVISO: precisa rodar como Administrador pra essa parte (politica de maquina) -- pulando, o resto continua."
}

# 3) Efeitos visuais em "melhor desempenho" (desliga animacao/sombra de
# janela, mantem so o essencial pra nao ficar feio)
try {
  $vfxPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
  if (-not (Test-Path $vfxPath)) { New-Item -Path $vfxPath -Force | Out-Null }
  Set-ItemProperty -Path $vfxPath -Name "VisualFXSetting" -Value 2 -Type DWord -Force
  Write-Output "on: efeitos visuais do Windows ajustados pra desempenho"
} catch {
  Write-Output "AVISO: nao consegui ajustar efeitos visuais ($_)"
}

Write-Output ""
Write-Output "Pronto. Reinicie o PC pra todos os ajustes valerem 100%."
