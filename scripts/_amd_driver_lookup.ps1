# Consulta a versao mais recente do driver AMD (Adrenalin Edition) pra
# placa detectada, lendo direto a pagina oficial de download do produto
# em amd.com -- diferente da NVIDIA, a AMD nao tem uma API JSON
# separada conhecida; a pagina do produto ja mostra Revision Number e
# Release Date em HTML estatico de verdade (confirmado lendo o HTML
# bruto de varias paginas reais: RX 5700 XT, RX 6800, RX 7800 XT, RX
# 9070 XT -- todas responderam 200 e com os mesmos campos).
#
# LIMITACAO HONESTA: o formato de URL da pagina do produto (montado a
# partir do nome da placa) so foi confirmado pra RX 5000 em diante
# (RDNA1/2/3/4 -- "radeon-rx-XOOO-series/amd-radeon-rx-MODELO.html").
# Placas mais antigas (RX 400/500, Vega, HD) usam outro esquema de URL
# que nao foi verificado -- pra essas, o script devolve Erro e quem
# chamar deve cair no fallback manual (abrir a pagina geral da AMD).
#
# NAO baixa nem instala nada -- so consulta versao/data/link oficial.
param(
  [string]$NomeGpu = $null
)
$ErrorActionPreference = "Stop"

function Resolve-AmdUrl([string]$nomeGpu) {
  if ($nomeGpu -notmatch "RX\s*0*(\d{4})\b") { return $null }
  $modeloNum = [int]$matches[1]
  if ($modeloNum -lt 5000) { return $null }  # so RX 5000+ tem URL confirmada
  $milhar = [math]::Floor($modeloNum / 1000)
  $semPrefixo = ($nomeGpu -replace "^AMD\s+", "" -replace "^Radeon\s+", "").Trim()
  $slug = ($semPrefixo.ToLower() -replace "\s+", "-")
  return "https://www.amd.com/en/support/downloads/drivers.html/graphics/radeon-rx/radeon-rx-${milhar}000-series/amd-radeon-$slug.html"
}

function Get-MelhorDriverAmd([string]$html) {
  $opcoes = [System.Text.RegularExpressions.RegexOptions]::Singleline
  $regex = New-Object System.Text.RegularExpressions.Regex('<strong>Revision Number</strong>\s*<p>([^<]*)</p>.{0,400}?<strong>Release Date</strong>\s*<p>\s*([^<]+?)\s*</p>.{0,600}?href="(https://drivers\.amd\.com/[^"]+)"', $opcoes)
  $candidatos = @()
  foreach ($m in $regex.Matches($html)) {
    $rev = $m.Groups[1].Value.Trim()
    if ($rev -notmatch "Adrenalin") { continue }
    $dataTxt = $m.Groups[2].Value.Trim()
    try { $data = [datetime]::ParseExact($dataTxt, "yyyy-MM-dd", [System.Globalization.CultureInfo]::InvariantCulture) } catch { continue }
    $candidatos += [PSCustomObject]@{
      Revisao = $rev; Data = $data; DataTxt = $dataTxt
      UrlDownload = $m.Groups[3].Value.Trim(); Posicao = $m.Index
    }
  }
  if ($candidatos.Count -eq 0) { return $null }
  return ($candidatos | Sort-Object Data -Descending | Select-Object -First 1)
}

try {
  $gpu = $null
  if ($NomeGpu) {
    $gpu = $NomeGpu
  } else {
    $ci = Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "AMD|Radeon" } | Select-Object -First 1
    if (-not $ci) { Write-Output "Erro: nenhuma placa AMD detectada nessa maquina."; return }
    $gpu = $ci.Name
  }

  $url = Resolve-AmdUrl $gpu
  if (-not $url) { Write-Output "Erro: nao consegui montar o link da pagina de driver pra '$gpu' (esse modelo nao esta coberto pela deteccao automatica)."; return }

  $resp = Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 15 -UseBasicParsing -Headers @{ "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" }
  if ($resp.StatusCode -ne 200) { Write-Output "Erro: a pagina da AMD nao respondeu como esperado (codigo $($resp.StatusCode))."; return }

  $melhor = Get-MelhorDriverAmd $resp.Content
  if (-not $melhor) { Write-Output "Erro: nao consegui achar a versao do driver na pagina da AMD -- o formato da pagina pode ter mudado."; return }

  # Link de notas de versao -- procura perto de onde o driver escolhido
  # foi encontrado na pagina (mesma janela usada pra achar o download).
  $urlNotas = $null
  $janela = $resp.Content.Substring($melhor.Posicao, [Math]::Min(3000, $resp.Content.Length - $melhor.Posicao))
  if ($janela -match 'href="(/en/resources/support-articles/release-notes/[^"]+\.html)"') { $urlNotas = "https://www.amd.com$($matches[1])" }

  Write-Output "Versao: $($melhor.Revisao)"
  Write-Output "Data: $($melhor.DataTxt)"
  Write-Output "UrlDownload: $($melhor.UrlDownload)"
  Write-Output "UrlNotas: $urlNotas"
  Write-Output "UrlProduto: $url"
} catch {
  Write-Output "Erro: nao consegui consultar a AMD agora ($_)"
}
