# So DIAGNOSTICA -- detecta se a maquina tem GPU hibrida (integrada da
# CPU + dedicada, comum em notebook -- "Optimus" na NVIDIA, "Switchable
# Graphics" na AMD). Se o Windows decidir rodar o jogo na integrada por
# engano, o desempenho cai MUITO. Nao muda nada -- so avisa e explica
# onde forcar a GPU certa.
$ErrorActionPreference = "SilentlyContinue"

$gpus = @(Get-CimInstance Win32_VideoController | Where-Object { $_.Name -notmatch "Basic|Meta|Virtual" })

Write-Output "=== GPU HIBRIDA (NOTEBOOK) ==="
Write-Output ""
if ($gpus.Count -lt 2) {
  Write-Output "So uma placa de video detectada -- nao e um sistema hibrido, nada a avisar aqui."
  return
}

$integrada = $gpus | Where-Object { $_.Name -match "Intel|Radeon\(TM\) Graphics|AMD Radeon Graphics" -and $_.Name -notmatch "RTX|GTX|RX \d" }
$dedicada = $gpus | Where-Object { $_.Name -match "RTX|GTX|RX \d|NVIDIA|Radeon RX" }

foreach ($g in $gpus) { Write-Output "  - $($g.Name)" }
Write-Output ""

if ($integrada -and $dedicada) {
  Write-Output "Sistema hibrido detectado: $($integrada[0].Name) (integrada) +"
  Write-Output "$($dedicada[0].Name) (dedicada)."
  Write-Output ""
  Write-Output "IMPORTANTE: garanta que seus jogos rodem na placa DEDICADA, nao na"
  Write-Output "integrada -- se um jogo estiver com FPS muito baixo sem motivo aparente,"
  Write-Output "essa e a causa mais comum em notebook."
  Write-Output "COMO FORCAR: Configuracoes > Sistema > Tela > Graficos > selecione o"
  Write-Output "executavel do jogo > Opcoes > 'Alto desempenho' -- escolha a GPU"
  Write-Output "dedicada explicitamente. Tambem confira no Painel de Controle"
  Write-Output "NVIDIA/AMD, em 'Configuracoes de Grafico 3D' por programa."
} else {
  Write-Output "Mais de uma GPU detectada mas nao identifiquei claramente qual e"
  Write-Output "integrada/dedicada -- confira manualmente em Configuracoes > Sistema >"
  Write-Output "Tela > Graficos qual GPU cada jogo esta usando."
}
