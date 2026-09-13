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

NVIDIA App (o app novo, substituiu o GeForce Experience) > icone de
Elemento Grafico > Configuracoes Globais. Valores pra quem quer o maximo
de desempenho possivel:

  Modo de gerenciamento de energia .......... Preferencia por desempenho maximo
  Modo de latencia baixa ..................... Ultra
  Filtragem de textura - Qualidade ........... Alto desempenho
  Filtragem de textura - otimizacao trilinear  Ligado
  Tamanho do cache do criador de sombras ..... Sem limite
  Atribuicao de GPU (notebook com 2 placas) .. A sua placa NVIDIA dedicada

Esses itens abaixo tem TROCA envolvida -- nao e "sempre desligado e
melhor", depende do seu monitor e do jogo:

  Sincronizacao vertical (VSync) ............. Desligado da MAIS FPS, mas pode
    dar tearing (linha cortando a tela). Se seu monitor tem G-Sync/FreeSync,
    deixe o VSync do jogo desligado e o G-Sync/FreeSync cuida disso sem
    perder desempenho. Sem G-Sync/FreeSync, so ligue se o tearing incomodar.

  Taxa Maxima de Quadros ...................... Deixar sem limite maximiza o
    numero de FPS, mas gera mais calor/barulho de cooler sem ganho real
    acima da taxa de atualizacao do seu monitor. Limitar uns 3 quadros
    abaixo da taxa do monitor (ex: 141 num monitor de 144Hz) costuma dar
    MENOS latencia e menos calor, quase sem perder sensacao de fluidez.

  RTX Dynamic Vibrance ........................ E so uma preferencia visual
    (cores mais vivas), nao mexe no desempenho -- ligue se gostar do visual.

  Substituicao global do DLSS ................. So faz diferenca em jogos
    que usam DLSS. Forcar o preset "Qualidade" da mais nitidez, "Desempenho"
    da mais FPS -- teste qual fica melhor pro seu jogo, nao existe resposta
    unica aqui.

Aviso sobre gerenciamento de energia: deixar em "desempenho maximo" faz a
placa manter os clocks altos o tempo todo, mesmo fora de jogo -- em
notebook isso reduz a bateria e aumenta o barulho do cooler em repouso.
Se voce usa o notebook fora da tomada com frequencia, considere deixar em
"Otima energia" e so trocar pra "desempenho maximo" quando for jogar.
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
