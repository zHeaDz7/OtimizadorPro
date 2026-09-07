# Liga o "MSI Mode" (Message Signaled Interrupts) da placa de video --
# um jeito mais moderno e eficiente da GPU avisar o processador que
# precisa de atencao, comparado ao metodo antigo (interrupcao por linha
# compartilhada). Isso e a mesma mudanca que a ferramenta gratuita
# "MSI Mode Util" faz, so que direto no registro, sem instalar nada de
# terceiro. Pode reduzir picos de latencia (DPC latency) que causam
# microstutter. E uma configuracao por dispositivo, oficial do driver
# do Windows (Gerenciador de Dispositivos > sua GPU > Detalhes).
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"

function Get-GpuInterruptPath {
  $gpu = Get-CimInstance Win32_VideoController | Where-Object { $_.PNPDeviceID -and $_.Name -notmatch "Basic|Meta|Virtual" } | Select-Object -First 1
  if (-not $gpu) { return $null }
  $id = $gpu.PNPDeviceID
  $base = "HKLM:\SYSTEM\CurrentControlSet\Enum\$id\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"
  return @{ Path = $base; Nome = $gpu.Name }
}

try {
  $info = Get-GpuInterruptPath
  if (-not $info) {
    Write-Output "AVISO: nao consegui identificar a placa de video pra essa mudanca."
    return
  }

  if ($Action -eq "Status") {
    $v = (Get-ItemProperty -Path $info.Path -Name "MSISupported" -ErrorAction SilentlyContinue).MSISupported
    if ($v -eq 1) { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if ($Action -eq "Reverter") {
    if (Test-Path $info.Path) {
      Set-ItemProperty -Path $info.Path -Name "MSISupported" -Value 0 -Type DWord
    }
    Write-Output "on: MSI Mode revertido pro padrao ($($info.Nome))."
    Write-Output "AVISO: precisa reiniciar o PC pra valer."
    return
  }

  if (-not (Test-Path $info.Path)) { New-Item -Path $info.Path -Force | Out-Null }
  Set-ItemProperty -Path $info.Path -Name "MSISupported" -Value 1 -Type DWord
  Write-Output "on: MSI Mode ligado pra $($info.Nome)."
  Write-Output "AVISO: precisa reiniciar o PC pra valer."
} catch {
  Write-Output "AVISO: precisa ser Administrador pra essa parte ($_)"
}
