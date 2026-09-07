# Gera um guia em texto com os passos exatos pra configurar o painel da
# placa de video (NVIDIA ou AMD) pra desempenho maximo. Nao da pra mexer
# direto nessas configuracoes por script (ficam num banco de dados proprio
# do driver, sem API oficial simples) -- entao geramos o passo a passo
# personalizado com o nome real da placa detectada, pra deixar bem claro
# onde clicar.
$ErrorActionPreference = "SilentlyContinue"

$gpu = (Get-CimInstance Win32_VideoController | Where-Object { $_.Name -notmatch "Basic|Meta|Virtual" } | Select-Object -First 1)
$nome = if ($gpu) { $gpu.Name } else { "placa de video" }
$isNvidia = $nome -match "NVIDIA|GeForce|RTX|GTX"
$isAMD = $nome -match "AMD|Radeon"

$saida = Join-Path $PSScriptRoot "..\Guia-Placa-de-Video.txt"

if ($isNvidia) {
  $texto = @"
GUIA DE CONFIGURACAO -- $nome
================================================

Painel de Controle NVIDIA (botao direito na Area de Trabalho > Painel de
Controle NVIDIA) > Gerenciar Configuracoes 3D > aba Configuracoes do
Programa:

  Modo de gerenciamento de energia .......... Preferencia por desempenho maximo
  Modo de latencia baixa ..................... Ultra
  Filtragem de textura - Qualidade ........... Alto desempenho
  Filtragem de textura - otimizacao trilinear  Ligado
  Sincronizacao vertical (VSync) ............. Desligado
  Antialiasing - FXAA ........................ Desligado
  Buffering triplo ............................ Desligado
  Taxa Maxima de Quadros ...................... Desligado (deixe o limitador do jogo cuidar disso)
  Tamanho do cache do criador de sombras ..... Ilimitado

NVIDIA App > aba do jogo > Otimizar: puxe pra "Desempenho".
"@
} elseif ($isAMD) {
  $texto = @"
GUIA DE CONFIGURACAO -- $nome
================================================

Software AMD (Radeon Software) > Graficos > aba Global:

  Anti-Lag (ou Anti-Lag+) ..................... Ligado
  Radeon Chill ................................. Desligado (a nao ser que o jogo/servidor tenha limite de FPS proprio)
  Filtragem de textura ......................... Desempenho
  Sincronizacao vertical (VSync) ............... Desligado
  Modo de energia da GPU ....................... Desempenho
"@
} else {
  $texto = @"
GUIA DE CONFIGURACAO -- $nome
================================================

Nao identifiquei se e NVIDIA ou AMD automaticamente. Va no painel de
controle da fabricante da sua placa de video e procure por:
  - Modo de baixa latencia / Anti-Lag
  - Gerenciamento de energia -> Desempenho maximo
  - VSync -> Desligado
  - Filtragem de textura -> Desempenho
"@
}

[IO.File]::WriteAllText($saida, $texto, (New-Object System.Text.UTF8Encoding $false))
Write-Output "on: guia gerado em Guia-Placa-de-Video.txt (placa detectada: $nome)"
