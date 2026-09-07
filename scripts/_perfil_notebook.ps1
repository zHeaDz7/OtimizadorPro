# So DIAGNOSTICA -- se a maquina for notebook (tem bateria), verifica se
# esta rodando na tomada ou na bateria. Notebook jogando na bateria tem
# desempenho MUITO menor (a CPU/GPU se limitam sozinhas pra economizar
# energia, independente de qualquer configuracao do Windows) -- e o
# ajuste mais simples e mais impactante que existe pra notebook.
$ErrorActionPreference = "SilentlyContinue"

$bateria = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue

Write-Output "=== PERFIL NOTEBOOK ==="
Write-Output ""
if (-not $bateria) {
  Write-Output "Essa maquina nao tem bateria (desktop) -- esse item nao se aplica."
  return
}

$naTomada = $bateria.BatteryStatus -eq 2
if (-not $naTomada) {
  Write-Output "AVISO: voce esta jogando NA BATERIA agora."
  Write-Output "Notebook na bateria limita a CPU/GPU sozinho pra render a carga,"
  Write-Output "independente de qualquer plano de energia -- e a causa numero 1 de"
  Write-Output "'meu notebook joga pior que deveria'. CONECTE NA TOMADA antes de jogar,"
  Write-Output "isso sozinho costuma dar mais FPS que qualquer ajuste de software."
} else {
  Write-Output "Voce esta na tomada -- bom, isso evita o limite automatico de energia."
}

Write-Output ""
Write-Output "Outras dicas especificas de notebook:"
Write-Output "- No Windows 11, arraste o controle deslizante 'Modo de energia' pra"
Write-Output "  'Melhor desempenho' (Configuracoes > Sistema > Energia)."
Write-Output "- Se tiver GPU dedicada (veja o item de GPU Hibrida), garanta que o jogo"
Write-Output "  esta usando ela, nao a integrada."
Write-Output "- Notebook em superficie mole (cama, sofa) esquenta mais e pode fazer o"
Write-Output "  throttling termico entrar mais cedo -- prefira superficie dura/ventilada."
