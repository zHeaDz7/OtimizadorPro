# Pausa o servico de indexacao do Windows Search por COMPLETO (diferente
# do item que so exclui pasta de jogo -- esse aqui para o servico
# inteiro). Util antes de uma sessao longa de jogo se voce tem MUITO
# arquivo novo/copiado que o Windows ainda esta processando. Reverter
# volta o servico e a busca do menu Iniciar a funcionar normal.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"

try {
  $servico = Get-Service -Name "WSearch" -ErrorAction Stop

  if ($Action -eq "Status") {
    if ($servico.Status -eq "Stopped") { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if ($Action -eq "Reverter") {
    Set-Service -Name "WSearch" -StartupType Automatic -ErrorAction Stop
    Start-Service -Name "WSearch" -ErrorAction Stop
    Write-Output "on: Windows Search voltou a indexar normalmente (busca do menu Iniciar volta a funcionar)."
    return
  }

  Set-Service -Name "WSearch" -StartupType Manual -ErrorAction Stop
  Stop-Service -Name "WSearch" -Force -ErrorAction Stop
  Write-Output "on: indexacao do Windows Search pausada por completo."
  Write-Output "AVISO: a busca do menu Iniciar fica mais lenta/nao encontra arquivo novo"
  Write-Output "enquanto isso estiver pausado. Reverta depois da sessao de jogo."
} catch {
  Write-Output "AVISO: precisa ser Administrador pra essa parte ($_)"
}
