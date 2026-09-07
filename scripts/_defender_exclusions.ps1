# Adiciona exclusao no Windows Defender pra pasta de cada jogo detectado.
# Isso NAO desliga o antivirus -- so evita que ele fique escaneando em tempo
# real arquivos gigantes de jogo que ficam sendo lidos o tempo todo (fonte
# comum de engasgo/stutter). O Defender continua ligado e protegendo o
# resto do sistema normalmente.
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "_detect_games.ps1")

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
  Write-Output "AVISO: precisa ser Administrador pra essa parte (exclusao no Defender)."
  return
}

$games = Get-AllDetectedGames
if ($games.Count -eq 0) {
  Write-Output "Nenhum jogo detectado (Steam/Epic nao encontrados)."
  return
}

Write-Output "Jogos detectados:"
$games | ForEach-Object { Write-Output "  - $($_.Nome) [$($_.Origem)]: $($_.Caminho)" }
Write-Output ""

$existentes = (Get-MpPreference).ExclusionPath
$n = 0
foreach ($g in $games) {
  if ($existentes -notcontains $g.Caminho) {
    try {
      Add-MpPreference -ExclusionPath $g.Caminho -ErrorAction Stop
      Write-Output "on: exclusao adicionada -> $($g.Caminho)"
      $n++
    } catch {
      Write-Output "AVISO: nao consegui adicionar exclusao pra $($g.Caminho): $_"
    }
  }
}
Write-Output ""
Write-Output "$n exclusao(oes) nova(s) adicionada(s). $($games.Count - $n) ja estavam configuradas."
