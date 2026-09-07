# Tira as pastas de jogos detectadas da indexacao do Windows Search.
# O indexador fica escaneando arquivos em segundo plano pra busca rapida no
# menu Iniciar -- isso e inutil pra pasta de jogo (ninguem procura arquivo
# de jogo pelo menu Iniciar) e so gasta disco/CPU a toa, principalmente
# durante o jogo se ele decidir reindexar algo que mudou.
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "_detect_games.ps1")

try {
  $searchManager = New-Object -ComObject "Microsoft.Search.Interop.CSearchManager" -ErrorAction Stop
} catch {
  Write-Output "AVISO: nao consegui acessar o Windows Search nessa maquina (as vezes precisa ser Admin, ou o servico esta desligado). Pulando."
  return
}

$catalog = $searchManager.GetCatalog("SystemIndex")
$crawlScope = $catalog.GetCrawlScopeManager()

$jogos = Get-AllDetectedGames | Sort-Object Caminho -Unique
$n = 0
foreach ($j in $jogos) {
  try {
    $crawlScope.AddUserScopeRule("file:///" + ($j.Caminho -replace '\\','/'), $false, $true, $null)
    $n++
  } catch {}
}
try { $crawlScope.SaveAll() } catch {}

Write-Output "on: $n pasta(s) de jogo excluida(s) da indexacao do Windows Search"
