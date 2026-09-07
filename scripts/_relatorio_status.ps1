# Mostra o status atual de TODOS os itens que tem Aplicar/Reverter, numa
# lista so -- sem mudar nada. Serve como "modo preview": veja o que ja
# esta ligado/desligado antes de ir item por item no menu.
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

Write-Output "=== STATUS ATUAL DE TUDO QUE TEM APLICAR/REVERTER ==="
Write-Output ""
foreach ($it in $itens) {
  $caminho = Join-Path $dir $it.Script
  $status = & $caminho -Action Status 2>&1
  # Alguns status podem vir com mensagem de AVISO longa (ex: sem admin) --
  # mostra só a primeira linha pra manter a lista legivel
  $primeira = ($status -split "`n")[0]
  Write-Output ("  {0,-32} {1}" -f $it.Nome, $primeira)
}

Write-Output ""
$hagsStatus = & (Join-Path $dir "_hags.ps1") -Action Status 2>&1
Write-Output ("  {0,-32} {1}" -f "HAGS", (($hagsStatus -split "`n")[0]))

Write-Output ""
Write-Output "LIGADO = a otimizacao esta aplicada. DESLIGADO = ainda no padrao do Windows."
Write-Output "Pra mudar qualquer um, va no menu e escolha a letra correspondente."
