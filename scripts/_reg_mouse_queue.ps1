# Aumenta o tamanho da fila de eventos de mouse/teclado que o driver do
# Windows guarda antes de entregar pro jogo (MouseDataQueueSize /
# KeyboardDataQueueSize). O padrao do Windows e 100 -- em mouses de taxa de
# report muito alta (1000Hz, 4000Hz, 8000Hz+) ou em momentos de pico de CPU,
# essa fila pode nao dar conta e descartar algum movimento. Aumentar da mais
# margem sem custar nada perceptivel de recursos. E um parametro de driver,
# so faz efeito depois de REINICIAR o PC.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"
$mousePath = "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters"
$kbPath = "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters"
$valorAumentado = 200   # padrao do Windows e 100; dobramos a margem
$valorPadrao = 100

try {
  if ($Action -eq "Status") {
    $m = (Get-ItemProperty -Path $mousePath -Name "MouseDataQueueSize" -ErrorAction SilentlyContinue).MouseDataQueueSize
    if ($m -eq $valorAumentado) { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if ($Action -eq "Reverter") {
    Remove-ItemProperty -Path $mousePath -Name "MouseDataQueueSize" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $kbPath -Name "KeyboardDataQueueSize" -ErrorAction SilentlyContinue
    Write-Output "on: fila de mouse/teclado revertida pro padrao do Windows (100)."
    Write-Output "AVISO: precisa reiniciar o PC pra valer."
    return
  }

  if (-not (Test-Path $mousePath)) { New-Item -Path $mousePath -Force | Out-Null }
  if (-not (Test-Path $kbPath)) { New-Item -Path $kbPath -Force | Out-Null }
  New-ItemProperty -Path $mousePath -Name "MouseDataQueueSize" -Value $valorAumentado -PropertyType DWord -Force | Out-Null
  New-ItemProperty -Path $kbPath -Name "KeyboardDataQueueSize" -Value $valorAumentado -PropertyType DWord -Force | Out-Null
  Write-Output "on: fila de eventos de mouse/teclado aumentada de $valorPadrao pra $valorAumentado."
  Write-Output "AVISO: precisa reiniciar o PC pra valer."
} catch {
  Write-Output "AVISO: precisa ser Administrador pra essa parte ($_)"
}
