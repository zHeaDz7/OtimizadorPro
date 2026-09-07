# Pede pro Windows liberar RAM que programas em segundo plano reservaram
# mas nao estao usando de verdade agora (o "working set" de cada processo).
# Isso e a MESMA acao que o botao "Reduzir memoria" faz no Gerenciador de
# Tarefas (aba Detalhes, botao direito num processo), so que em todos os
# processos de uma vez. Nao fecha nada, nao perde nada -- o programa pode
# pedir a memoria de volta a qualquer momento se precisar, o Windows so
# devolve o que estava sobrando pro sistema usar agora (por exemplo, pro
# jogo que voce vai abrir). E uma acao pontual (roda agora), nao uma
# configuracao permanente -- por isso nao tem "Reverter".
$ErrorActionPreference = "Stop"

$antes = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory
$n = 0
$falhas = 0
foreach ($p in (Get-Process -ErrorAction SilentlyContinue)) {
  try {
    if ($p.Id -eq $PID) { continue }
    $p.MinWorkingSet = $p.MinWorkingSet
    $n++
  } catch {
    $falhas++
  }
}
Start-Sleep -Milliseconds 500
$depois = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory
$liberadoMB = [math]::Round(($depois - $antes) / 1024, 0)

Write-Output "on: memoria pedida de volta em $n processo(s) ($falhas sem permissao, normal pra processos de sistema)."
if ($liberadoMB -gt 0) {
  Write-Output "RAM livre foi de $([math]::Round($antes/1024,0)) MB pra $([math]::Round($depois/1024,0)) MB (+$liberadoMB MB)."
} else {
  Write-Output "RAM livre: $([math]::Round($depois/1024,0)) MB (pode nao mudar muito se ja estava tudo em uso ativo -- normal)."
}
