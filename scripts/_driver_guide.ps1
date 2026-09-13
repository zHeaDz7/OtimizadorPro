# Gera um guia em texto com os passos exatos pra configurar o painel da
# placa de vídeo (NVIDIA ou AMD) pra desempenho máximo. Não dá pra mexer
# direto nessas configurações por script (ficam num banco de dados próprio
# do driver, sem API oficial simples) -- então geramos o passo a passo
# personalizado com o nome real da placa detectada, pra deixar bem claro
# onde clicar.
$ErrorActionPreference = "SilentlyContinue"

$gpu = (Get-CimInstance Win32_VideoController | Where-Object { $_.Name -notmatch "Basic|Meta|Virtual" } | Select-Object -First 1)
$nome = if ($gpu) { $gpu.Name } else { "placa de vídeo" }
$isNvidia = $nome -match "NVIDIA|GeForce|RTX|GTX"
$isAMD = $nome -match "AMD|Radeon"

$saida = Join-Path $PSScriptRoot "..\Guia-Placa-de-Video.txt"

if ($isNvidia) {
  $texto = @"
GUIA DE CONFIGURAÇÃO -- $nome
================================================

NVIDIA App (o app novo, substituiu o GeForce Experience) > ícone de
Elemento Gráfico > Configurações Globais. Valores pra quem quer o máximo
de desempenho possível:

  Modo de gerenciamento de energia .......... Preferência por desempenho máximo
  Modo de latência baixa ..................... Ultra
  Filtragem de textura - Qualidade ........... Alto desempenho
  Filtragem de textura - otimização trilinear  Ligado
  Tamanho do cache do criador de sombras ..... Sem limite
  Atribuição de GPU (notebook com 2 placas) .. A sua placa NVIDIA dedicada

Esses itens abaixo têm TROCA envolvida -- não é "sempre desligado é
melhor", depende do seu monitor e do jogo:

  Sincronização vertical (VSync) .............. Desligado dá MAIS FPS, mas pode
    dar tearing (linha cortando a tela). Se seu monitor tem G-Sync/FreeSync,
    deixe o VSync do jogo desligado e o G-Sync/FreeSync cuida disso sem
    perder desempenho. Sem G-Sync/FreeSync, só ligue se o tearing incomodar.

  Taxa Máxima de Quadros ...................... Deixar sem limite maximiza o
    número de FPS, mas gera mais calor/barulho de cooler sem ganho real
    acima da taxa de atualização do seu monitor. Limitar uns 3 quadros
    abaixo da taxa do monitor (ex: 141 num monitor de 144Hz) costuma dar
    MENOS latência e menos calor, quase sem perder sensação de fluidez.

  RTX Dynamic Vibrance ......................... É só uma preferência visual
    (cores mais vivas), não mexe no desempenho -- ligue se gostar do visual.

  Substituição global do DLSS .................. Só faz diferença em jogos
    que usam DLSS. Forçar o preset "Qualidade" dá mais nitidez, "Desempenho"
    dá mais FPS -- teste qual fica melhor pro seu jogo, não existe resposta
    única aqui.

Aviso sobre gerenciamento de energia: deixar em "desempenho máximo" faz a
placa manter os clocks altos o tempo todo, mesmo fora de jogo -- em
notebook isso reduz a bateria e aumenta o barulho do cooler em repouso.
Se você usa o notebook fora da tomada com frequência, considere deixar em
"Ótima energia" e só trocar pra "desempenho máximo" quando for jogar.
"@
} elseif ($isAMD) {
  $texto = @"
GUIA DE CONFIGURAÇÃO -- $nome
================================================

Software AMD (Radeon Software) > Gráficos > aba Global:

  Anti-Lag (ou Anti-Lag+) ..................... Ligado
  Radeon Chill ................................. Desligado (a não ser que o jogo/servidor tenha limite de FPS próprio)
  Filtragem de textura ......................... Desempenho
  Sincronização vertical (VSync) ............... Desligado
  Modo de energia da GPU ....................... Desempenho
"@
} else {
  $texto = @"
GUIA DE CONFIGURAÇÃO -- $nome
================================================

Não identifiquei se é NVIDIA ou AMD automaticamente. Vá no painel de
controle da fabricante da sua placa de vídeo e procure por:
  - Modo de baixa latência / Anti-Lag
  - Gerenciamento de energia -> Desempenho máximo
  - VSync -> Desligado
  - Filtragem de textura -> Desempenho
"@
}

[IO.File]::WriteAllText($saida, $texto, (New-Object System.Text.UTF8Encoding $true))
Write-Output "on: guia gerado em Guia-Placa-de-Video.txt (placa detectada: $nome)"
