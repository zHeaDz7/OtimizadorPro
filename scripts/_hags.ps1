param(
  [ValidateSet("On", "Off", "Status")]
  [string]$Action = "On"
)
# Liga/desliga o "Agendamento de GPU acelerado por hardware" (HAGS) do
# Windows -- recurso oficial (Configuracoes > Sistema > Tela > Graficos)
# que deixa a propria placa de video gerenciar sua fila de trabalho em vez
# do driver via CPU. Em GPUs e drivers recentes (a maioria hoje em dia)
# reduz latencia; em placas mais antigas pode nao fazer diferenca ou raramente
# piorar -- por isso o script permite ligar OU desligar, teste o que for
# melhor no seu jogo.
$ErrorActionPreference = "Stop"
$path = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"

if ($Action -eq "Status") {
  $atual = (Get-ItemProperty -Path $path -Name "HwSchMode" -ErrorAction SilentlyContinue).HwSchMode
  Write-Output "HAGS atual: $(if ($atual -eq 2) {'Ligado'} else {'Desligado'})"
  return
}

try {
  $valor = if ($Action -eq "On") { 2 } else { 1 }
  Set-ItemProperty -Path $path -Name "HwSchMode" -Value $valor -Type DWord -Force
  Write-Output "on: HAGS (agendamento de GPU por hardware) $(if ($Action -eq 'On') {'LIGADO'} else {'DESLIGADO'})"
  Write-Output "AVISO: precisa reiniciar o PC pra valer. Se notar mais engasgo depois, tente o outro modo."
} catch {
  Write-Output "AVISO: precisa ser Administrador pra essa parte ($_)"
}
