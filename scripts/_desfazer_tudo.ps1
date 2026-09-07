# Reverte TODOS os itens que tem Aplicar/Reverter de volta pro padrao do
# Windows, de uma vez. Nao mexe em coisas que nao tem "Reverter" formal
# (ex: limpeza de temporarios -- nao tem como "desfazer" apagar um
# arquivo temporario, mas isso tambem nunca teve risco nenhum). Pede
# confirmacao antes porque desfaz de uma vez tudo que voce configurou.
$ErrorActionPreference = "SilentlyContinue"
$dir = $PSScriptRoot

$itens = @(
  @{ Nome = "Mouse 1:1 fisico";                Script = "_mouse_fix.ps1" }
  @{ Nome = "USB Selective Suspend";           Script = "_reg_usb_suspend.ps1" }
  @{ Nome = "Timer do kernel (bcdedit)";       Script = "_reg_kernel_timer.ps1" }
  @{ Nome = "Fila de mouse/teclado";           Script = "_reg_mouse_queue.ps1" }
  @{ Nome = "ISLC (kernel na RAM)";            Script = "_reg_islc.ps1" }
  @{ Nome = "Bloqueio atalhos acessibilidade"; Script = "_reg_accessibility.ps1" }
  @{ Nome = "Prioridade de CPU";               Script = "_reg_priority_boost.ps1" }
  @{ Nome = "Core Parking";                    Script = "_core_parking.ps1" }
  @{ Nome = "MSI Mode da GPU";                 Script = "_gpu_msi_mode.ps1" }
  @{ Nome = "TDR Delay";                       Script = "_gpu_tdr_delay.ps1" }
  @{ Nome = "Interrupt Moderation";            Script = "_net_interrupt_moderation.ps1" }
)

Write-Output "Revertendo tudo pro padrao do Windows..."
Write-Output ""
foreach ($it in $itens) {
  $caminho = Join-Path $dir $it.Script
  $resultado = & $caminho -Action Reverter 2>&1
  $primeira = ($resultado -split "`n")[0]
  Write-Output ("  {0,-32} {1}" -f $it.Nome, $primeira)
}

$hagsResultado = & (Join-Path $dir "_hags.ps1") -Action Off 2>&1
Write-Output ("  {0,-32} {1}" -f "HAGS", (($hagsResultado -split "`n")[0]))

$doResultado = & (Join-Path $dir "_delivery_optimization.ps1") -Action On 2>&1
Write-Output ("  {0,-32} {1}" -f "Delivery Optimization", (($doResultado -split "`n")[0]))

Write-Output ""
Write-Output "Pronto. Itens que nao mudaram (sem admin, ou hardware nao suporta) ficaram como estavam."
Write-Output "Alguns precisam reiniciar o PC pra reverter valer 100% (mesmo aviso de quando foram aplicados)."
