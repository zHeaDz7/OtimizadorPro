# Impede que o Windows mande codigo do kernel/drivers pra memoria virtual
# (arquivo de paginacao) quando a RAM fica sob pressao -- eles ficam sempre
# na RAM fisica. Isso e um parametro oficial e antigo do Windows
# (DisablePagingExecutive), documentado ate em guias de performance da
# propria Microsoft para servidores. So vale a pena com RAM de sobra (8GB+,
# idealmente 16GB+) -- com pouca RAM pode ate atrapalhar, por isso avisamos
# a quantidade de RAM detectada antes de aplicar. So faz efeito depois de
# REINICIAR o PC.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"
$path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"

try {
  if ($Action -eq "Status") {
    $v = (Get-ItemProperty -Path $path -Name "DisablePagingExecutive" -ErrorAction SilentlyContinue).DisablePagingExecutive
    if ($v -eq 1) { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if ($Action -eq "Reverter") {
    Set-ItemProperty -Path $path -Name "DisablePagingExecutive" -Value 0 -Type DWord
    Write-Output "on: paginacao do kernel/drivers revertida pro padrao do Windows."
    Write-Output "AVISO: precisa reiniciar o PC pra valer."
    return
  }

  $ramGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
  if ($ramGB -lt 8) {
    Write-Output "AVISO: sua maquina tem $ramGB GB de RAM. Esse ajuste so vale a pena com 8GB+ (idealmente 16GB+), entao NAO foi aplicado pra nao arriscar travar a maquina por falta de RAM."
    return
  }
  Set-ItemProperty -Path $path -Name "DisablePagingExecutive" -Value 1 -Type DWord
  Write-Output "on: kernel e drivers ficam sempre na RAM fisica (RAM detectada: $ramGB GB)."
  Write-Output "AVISO: precisa reiniciar o PC pra valer."
} catch {
  Write-Output "AVISO: precisa ser Administrador pra essa parte ($_)"
}
