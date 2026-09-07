# Aumenta o "TDR Delay" (Timeout Detection and Recovery) do Windows -- o
# tempo que ele espera a placa de video responder antes de assumir que
# ela travou e reiniciar o driver (tela pisca, aparece "o driver de
# exibicao parou de responder e foi recuperado"). O padrao e 2 segundos --
# em cenas muito pesadas (ou GPU com leve overclock), a placa pode so
# estar demorando mais que o normal numa cena pesada, nao travada de
# verdade, e o Windows reinicia o driver sem necessidade (RECOVERY falso
# positivo, derruba o jogo). Aumentar da mais margem antes disso
# acontecer. E uma configuracao oficial e documentada do driver do
# Windows (WDDM).
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"
$path = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
$valorAumentado = 8   # segundos (padrao do Windows e 2)

try {
  if ($Action -eq "Status") {
    $v = (Get-ItemProperty -Path $path -Name "TdrDelay" -ErrorAction SilentlyContinue).TdrDelay
    if ($v -eq $valorAumentado) { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if ($Action -eq "Reverter") {
    Remove-ItemProperty -Path $path -Name "TdrDelay" -ErrorAction SilentlyContinue
    Write-Output "on: TDR Delay revertido pro padrao do Windows (2 segundos)."
    Write-Output "AVISO: precisa reiniciar o PC pra valer."
    return
  }

  if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
  New-ItemProperty -Path $path -Name "TdrDelay" -Value $valorAumentado -PropertyType DWord -Force | Out-Null
  Write-Output "on: TDR Delay aumentado de 2 pra $valorAumentado segundos."
  Write-Output "AVISO: precisa reiniciar o PC pra valer."
} catch {
  Write-Output "AVISO: precisa ser Administrador pra essa parte ($_)"
}
