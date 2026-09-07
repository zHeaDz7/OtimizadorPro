# Desliga o servico de telemetria do Windows (DiagTrack -- "Connected User
# Experiences and Telemetry"). Ele manda dados de uso pra Microsoft em
# segundo plano; desligar reduz um pouco de CPU/disco/rede em segundo
# plano. Isso e mais uma questao de privacidade do que desempenho puro --
# por isso fica fora do "Rodar TUDO", so roda se voce escolher.
# 100% reversivel: reative o servico "DiagTrack" a qualquer momento pelo
# services.msc (Gerenciar > Servicos).
$ErrorActionPreference = "Stop"

try {
  $servico = Get-Service -Name "DiagTrack" -ErrorAction Stop
  if ($servico.Status -eq "Stopped" -and $servico.StartType -eq "Disabled") {
    Write-Output "Ja esta desligado."
    return
  }
  Stop-Service -Name "DiagTrack" -Force -ErrorAction Stop
  Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction Stop
  Write-Output "on: telemetria do Windows (DiagTrack) desligada"
  Write-Output "Pra reverter: services.msc > 'Connected User Experiences and Telemetry' > Automatico > Iniciar"
} catch {
  Write-Output "AVISO: precisa ser Administrador pra essa parte ($_)"
}
