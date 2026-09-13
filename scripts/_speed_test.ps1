# Mede a velocidade REAL de download/upload usando o mesmo endpoint que
# o teste de velocidade publico da Cloudflare usa no navegador
# (speed.cloudflare.com) -- baixa/envia bytes de verdade e cronometra,
# nao inventa numero. So mede -- nao muda nenhuma configuracao.
#
# IMPORTANTE: $ProgressPreference = "SilentlyContinue" e OBRIGATORIO
# aqui -- sem isso, Invoke-WebRequest fica MUITO mais lento por causa do
# jeito que ele desenha a barra de progresso a cada pedaco baixado
# (confirmado testando ao vivo nessa maquina: a MESMA rede mediu "5
# Mbps" sem isso e "210+ Mbps" com isso -- e um numero real, so que sem
# essa linha o script mede a velocidade de desenhar a barra de
# progresso do PowerShell, nao a internet de verdade).
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

try {
  $tamanhoDownload = 25000000  # 25 MB
  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  $resp = Invoke-WebRequest -Uri "https://speed.cloudflare.com/__down?bytes=$tamanhoDownload" -UseBasicParsing -TimeoutSec 30
  $sw.Stop()
  $segundosDown = $sw.Elapsed.TotalSeconds
  $mbpsDown = if ($segundosDown -gt 0) { [math]::Round(($resp.RawContentLength * 8 / 1MB) / $segundosDown, 1) } else { 0 }

  $tamanhoUpload = 10000000  # 10 MB
  $dados = New-Object byte[] $tamanhoUpload
  (New-Object Random).NextBytes($dados)
  $sw2 = [System.Diagnostics.Stopwatch]::StartNew()
  Invoke-WebRequest -Uri "https://speed.cloudflare.com/__up" -Method Post -Body $dados -UseBasicParsing -TimeoutSec 30 -ContentType "application/octet-stream" | Out-Null
  $sw2.Stop()
  $segundosUp = $sw2.Elapsed.TotalSeconds
  $mbpsUp = if ($segundosUp -gt 0) { [math]::Round(($tamanhoUpload * 8 / 1MB) / $segundosUp, 1) } else { 0 }

  Write-Output "Download: $mbpsDown Mbps"
  Write-Output "Upload: $mbpsUp Mbps"
} catch {
  Write-Output "Erro: nao consegui medir a velocidade agora ($_)"
}
