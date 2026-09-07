# So DIAGNOSTICA -- detecta programas com overlay/gravacao rodando que
# sao causa comum de FPS baixo, engasgo ou ate crash em jogos (o overlay
# injeta codigo dentro do processo do jogo). Nao fecha nada -- so avisa
# quais estao rodando, pra voce decidir desativar o overlay especifico
# nas configuracoes de cada programa (nao precisa desinstalar).
$ErrorActionPreference = "SilentlyContinue"

$conhecidos = @{
  "Discord"              = "Overlay do Discord -- em Configuracoes do Discord > Overlay, pode desligar so pra jogos problematicos"
  "GameBar"               = "Xbox Game Bar -- ja tratado no item 6 deste OtimizadorPro"
  "NVIDIA Share"          = "Overlay do GeForce Experience/NVIDIA App -- em Configuracoes > Overlay do jogo"
  "RTSS"                  = "RivaTuner Statistics Server (usado por MSI Afterburner) -- geralmente leve, raramente e o problema"
  "Steam"                 = "Overlay do Steam -- em Steam > Configuracoes > Na Partida, pode desligar por jogo"
  "EpicGamesLauncher"     = "Overlay da Epic Games -- em Configuracoes do launcher"
  "obs64"                 = "OBS Studio (gravacao/stream) -- captura de tela consome CPU/GPU real, nao só overlay"
  "obs32"                 = "OBS Studio (gravacao/stream)"
  "ReLive"                = "Overlay AMD ReLive -- no Radeon Software"
  "RadeonSoftware"        = "Overlay AMD Radeon Software"
}

$rodando = Get-Process -ErrorAction SilentlyContinue
$encontrados = @()
foreach ($nome in $conhecidos.Keys) {
  if ($rodando | Where-Object { $_.Name -match [regex]::Escape($nome) }) {
    $encontrados += $nome
  }
}

Write-Output "=== OVERLAYS E GRAVACAO DE TELA RODANDO AGORA ==="
Write-Output ""
if ($encontrados.Count -eq 0) {
  Write-Output "Nenhum overlay conhecido detectado rodando agora. Tudo limpo."
  return
}

foreach ($nome in $encontrados) {
  Write-Output "  - $nome"
  Write-Output "    $($conhecidos[$nome])"
}
Write-Output ""
Write-Output "Ter um overlay aberto nao e necessariamente ruim -- so vale desligar o"
Write-Output "overlay ESPECIFICO (nao o programa inteiro) se voce notar engasgo ou"
Write-Output "queda de FPS que sobe quando fecha esses programas."
