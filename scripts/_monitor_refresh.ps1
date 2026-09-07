# So DIAGNOSTICA -- nao muda nada. Muita gente troca de monitor (ex: de
# 60Hz pra 144Hz) e o Windows continua usando a taxa de atualizacao
# antiga, porque ele nao troca sozinho na maioria das vezes. Jogar num
# monitor 144Hz configurado em 60Hz trava metade do beneficio da placa
# de video sem voce nem perceber que o problema e essa configuracao.
$ErrorActionPreference = "SilentlyContinue"

$monitores = Get-CimInstance Win32_VideoController | Where-Object { $_.CurrentRefreshRate -gt 0 }

if (-not $monitores) {
  Write-Output "Nao consegui ler a taxa de atualizacao (comum em maquina virtual ou acesso remoto)."
  return
}

foreach ($m in $monitores) {
  $atual = $m.CurrentRefreshRate
  $maximo = $m.MaxRefreshRate
  Write-Output "$($m.Name): rodando a $atual Hz (maximo relatado pelo driver: $maximo Hz)"
  if ($maximo -gt 0 -and $atual -lt $maximo) {
    Write-Output "AVISO: seu monitor/placa suporta ate $maximo Hz mas esta configurado pra $atual Hz."
    Write-Output "Pra corrigir: botao direito na Area de Trabalho > Configuracoes de Video >"
    Write-Output "Video avancado (ou Propriedades de exibicao avancadas) > Taxa de atualizacao > escolha $maximo Hz."
  }
}
