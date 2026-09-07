# Desliga as "Otimizacoes de Tela Cheia" do Windows pro executavel
# principal de cada jogo detectado -- isso e a mesma correcao que o
# Windows oferece manualmente (botao direito no .exe > Propriedades >
# Compatibilidade > "Desativar otimizacoes de tela cheia"). Resolve um
# problema comum de tela preta/travamento ao alternar janela (Alt+Tab)
# em jogos de tela cheia exclusiva.
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "_detect_games.ps1")

$jogos = Get-AllDetectedGames
$regPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }

$n = 0
foreach ($j in $jogos) {
  $exes = Get-ChildItem -LiteralPath $j.Caminho -Filter "*.exe" -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.Length -gt 1MB } | Select-Object -First 3
  foreach ($exe in $exes) {
    try {
      New-ItemProperty -Path $regPath -Name $exe.FullName -Value "~ DISABLEDXMAXIMIZEDWINDOWEDMODE" -PropertyType String -Force | Out-Null
      $n++
    } catch {}
  }
}

Write-Output "on: 'otimizacoes de tela cheia' desligadas em $n executavel(is) de jogo"
Write-Output "(reduz chance de tela preta/travamento ao dar Alt+Tab em tela cheia exclusiva)"
