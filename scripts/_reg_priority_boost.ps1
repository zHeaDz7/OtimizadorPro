# Duas coisas relacionadas a prioridade de CPU, ambas oficiais do Windows:
#
# 1) Win32PrioritySeparation: e o mesmo valor por tras da opcao "Ajustar
#    para obter o melhor desempenho de: Programas" em Configuracoes >
#    Sistema > Sobre > Configuracoes avancadas do sistema > Desempenho.
#    Isso faz o Windows dar fatias de tempo de CPU maiores/mais constantes
#    pro programa que esta em primeiro plano (o jogo que voce esta jogando)
#    em vez de dividir igual com tudo rodando atras.
# 2) Prioridade de CPU por executavel (Image File Execution Options): sobe
#    a prioridade dos executaveis dos jogos detectados pra "Acima do Normal"
#    -- um passo acima do padrao, sem chegar em "Tempo Real" (que pode
#    travar o sistema inteiro se o jogo travar segurando prioridade maxima,
#    entao NUNCA usamos isso).
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "_detect_games.ps1")

$prioPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
$ifeoBase = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
$valorGaming = 38        # foreground boost curto e fixo (equivalente a "Programs" + boost)
$valorPadrao = 2         # padrao de fabrica do Windows client
$prioridadeAcimaNormal = 6  # CpuPriorityClass: 6 = Acima do Normal

function Get-ExesDosJogos {
  $jogos = Get-AllDetectedGames
  $exes = @()
  foreach ($j in $jogos) {
    $exes += Get-ChildItem -LiteralPath $j.Caminho -Filter "*.exe" -Recurse -ErrorAction SilentlyContinue |
      Where-Object { $_.Length -gt 1MB } | Select-Object -First 2 | ForEach-Object { $_.Name }
  }
  return @($exes | Select-Object -Unique)
}

try {
  if ($Action -eq "Status") {
    $atual = (Get-ItemProperty -Path $prioPath -Name "Win32PrioritySeparation" -ErrorAction SilentlyContinue).Win32PrioritySeparation
    if ($atual -eq $valorGaming) { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if ($Action -eq "Reverter") {
    Set-ItemProperty -Path $prioPath -Name "Win32PrioritySeparation" -Value $valorPadrao -Type DWord
    $exes = Get-ExesDosJogos
    foreach ($exe in $exes) {
      $chave = Join-Path $ifeoBase "$exe\PerfOptions"
      if (Test-Path $chave) { Remove-Item -Path $chave -Force -ErrorAction SilentlyContinue }
    }
    Write-Output "on: prioridade de CPU revertida pro padrao do Windows."
    return
  }

  $exes = Get-ExesDosJogos
  if ($exes.Count -eq 0) {
    Write-Output "Nenhum jogo detectado pra ajustar prioridade de executavel (o Win32PrioritySeparation ainda assim vai ser ajustado)."
  }
  Set-ItemProperty -Path $prioPath -Name "Win32PrioritySeparation" -Value $valorGaming -Type DWord
  $n = 0
  foreach ($exe in $exes) {
    $chave = Join-Path $ifeoBase "$exe\PerfOptions"
    if (-not (Test-Path $chave)) { New-Item -Path $chave -Force | Out-Null }
    New-ItemProperty -Path $chave -Name "CpuPriorityClass" -Value $prioridadeAcimaNormal -PropertyType DWord -Force | Out-Null
    $n++
  }
  Write-Output "on: prioridade de CPU em primeiro plano ajustada, e $n executavel(is) de jogo com prioridade 'Acima do Normal'."
  Write-Output "AVISO: precisa reiniciar o PC pra valer 100%."
} catch {
  Write-Output "AVISO: precisa ser Administrador pra essa parte ($_)"
}
