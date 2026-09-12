# Consulta a versao mais recente do driver NVIDIA pra placa detectada
# nessa maquina, usando a mesma API que o proprio site nvidia.com usa
# internamente pra busca manual de driver (gfwsl.geforce.com +
# lookupValueSearch.aspx). NAO e uma API documentada/oficial da NVIDIA
# -- e a mesma coisa que a pagina publica chama no navegador, testada e
# confirmada funcionando em 2026-09 contra uma RTX 3050 real. Se a
# NVIDIA mudar isso, essa checagem para de funcionar -- por isso TUDO
# aqui tem try/catch e nunca lanca excecao pra fora, so devolve
# "Erro = <motivo>" pra quem chamar mostrar um aviso em vez de travar.
#
# NAO baixa nem instala nada -- so consulta versao/data/link oficial. O
# link de download e o oficial da propria NVIDIA (download.nvidia.com),
# pra abrir no navegador -- quem baixa e instala e o usuario, pelo
# proprio navegador dele.
param(
  [string]$NomeGpu = $null
)
$ErrorActionPreference = "Stop"

function Resolve-OsId {
  $build = [System.Environment]::OSVersion.Version.Build
  if ($build -ge 22000) { return 135 }  # Windows 11
  return 57                              # Windows 10 64-bit
}

function Resolve-Pfid([string]$nomeGpu) {
  # Nome vem tipo "NVIDIA GeForce RTX 3050" (Win32_VideoController) --
  # a API usa so "GeForce RTX 3050", sem o prefixo do fabricante.
  $nomeBusca = ($nomeGpu -replace "^NVIDIA\s+", "").Trim()
  # -UseBasicParsing evita um bug conhecido do Invoke-WebRequest no
  # Windows PowerShell 5.1 que depende do motor do Internet Explorer
  # (pode lancar NullReferenceException se o IE nunca foi aberto/
  # configurado nessa maquina). "Name"/"Value" sao ELEMENTOS filhos
  # dentro de <LookupValue>, nao atributos -- confirmado no XML real.
  $xml = [xml](Invoke-WebRequest -Uri "https://www.nvidia.com/Download/API/lookupValueSearch.aspx?TypeID=3" -Method Get -TimeoutSec 10 -UseBasicParsing).Content
  $match = $xml.SelectSingleNode("//LookupValue[Name='$nomeBusca']")
  if (-not $match) { return $null }
  return [int]$match.Value
}

try {
  $gpu = $null
  if ($NomeGpu) {
    $gpu = $NomeGpu
  } else {
    $ci = Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "NVIDIA|GeForce|RTX|GTX" } | Select-Object -First 1
    if (-not $ci) { Write-Output "Erro: nenhuma placa NVIDIA detectada nessa maquina."; return }
    $gpu = $ci.Name
  }

  $pfid = Resolve-Pfid $gpu
  if (-not $pfid) { Write-Output "Erro: nao consegui identificar '$gpu' na base da NVIDIA (nome pode ter mudado do lado deles)."; return }

  $osID = Resolve-OsId

  # isWHQL=1 pede o driver "Game Ready" (o certo pra um otimizador de
  # jogos) em vez do "Studio Driver" que a busca sem esse parametro
  # devolve por padrao -- confirmado testando os dois ao vivo.
  $resp = Invoke-RestMethod -Uri "https://gfwsl.geforce.com/services_toolkit/services/com/nvidia/services/AjaxDriverService.php?func=DriverManualLookup&pfid=$pfid&osID=$osID&dch=1&isWHQL=1" -Method Get -TimeoutSec 15

  # A resposta real observada tem "IDS" (array com um item) contendo os
  # campos -- confere a forma antes de usar, pra nao quebrar silencioso
  # se a NVIDIA mudar o formato.
  $item = $null
  if ($resp.IDS -and $resp.IDS.Count -gt 0) { $item = $resp.IDS[0].downloadInfo }
  if (-not $item) { Write-Output "Erro: resposta da NVIDIA veio num formato inesperado -- provavelmente mudaram a API."; return }

  $versao = $item.Version
  $dataBruta = $item.ReleaseDateTime
  $urlDownload = $item.DownloadURL

  # Nao existe campo direto "ReleaseNotesURL" na resposta real -- o link
  # do PDF de notas de versao vem embutido como HTML url-encoded dentro
  # de "OtherNotes". Extrai via regex; se o formato mudar, so fica sem
  # link de notas (nao quebra o resto).
  $urlNotas = $null
  if ($item.OtherNotes) {
    $notasDecodificadas = [System.Uri]::UnescapeDataString($item.OtherNotes)
    if ($notasDecodificadas -match 'href="([^"]+release-notes\.pdf)"') { $urlNotas = $matches[1] }
  }

  if (-not $versao -or -not $urlDownload) { Write-Output "Erro: resposta da NVIDIA veio incompleta."; return }

  Write-Output "Versao: $versao"
  Write-Output "Data: $dataBruta"
  Write-Output "UrlDownload: $urlDownload"
  Write-Output "UrlNotas: $urlNotas"
  Write-Output "Pfid: $pfid"
  Write-Output "OsID: $osID"
} catch {
  Write-Output "Erro: nao consegui consultar a NVIDIA agora ($_)"
}
