# So DIAGNOSTICA -- mostra a data do driver da placa de video instalado.
# Driver muito antigo (1+ ano) pode faltar otimizacao/correcao de bug pra
# jogos novos. Nao baixa nem instala nada -- so avisa, e indica onde
# baixar oficialmente.
$ErrorActionPreference = "SilentlyContinue"

$gpu = Get-CimInstance Win32_VideoController | Where-Object { $_.Name -notmatch "Basic|Meta|Virtual" } | Select-Object -First 1
if (-not $gpu) {
  Write-Output "Nao consegui identificar a placa de video."
  return
}

Write-Output "=== DRIVER DA PLACA DE VIDEO ==="
Write-Output ""
Write-Output "Placa: $($gpu.Name)"
Write-Output "Versao do driver: $($gpu.DriverVersion)"

if ($gpu.DriverDate) {
  # Get-CimInstance ja converte a data pra System.DateTime automaticamente
  # (diferente do Get-WmiObject antigo, que precisava do ManagementDateTimeConverter)
  $dataDriver = [datetime]$gpu.DriverDate
  $diasAtras = (New-TimeSpan -Start $dataDriver -End (Get-Date)).Days
  Write-Output "Data do driver: $($dataDriver.ToString('dd/MM/yyyy')) ($diasAtras dias atras)"
  Write-Output ""
  if ($diasAtras -gt 365) {
    Write-Output "AVISO: driver com mais de 1 ano. Vale a pena atualizar."
  } elseif ($diasAtras -gt 180) {
    Write-Output "Driver com alguns meses -- nao e urgente, mas considere atualizar se"
    Write-Output "algum jogo novo estiver com problema."
  } else {
    Write-Output "Driver relativamente recente. Tudo bem."
  }
} else {
  Write-Output "Nao consegui ler a data do driver."
}

Write-Output ""
if ($gpu.Name -match "NVIDIA|GeForce|RTX|GTX") {
  Write-Output "Baixar driver oficial: nvidia.com/drivers (ou pelo app NVIDIA App)"
} elseif ($gpu.Name -match "AMD|Radeon") {
  Write-Output "Baixar driver oficial: amd.com/support (ou pelo AMD Software: Adrenalin Edition)"
} elseif ($gpu.Name -match "Intel") {
  Write-Output "Baixar driver oficial: intel.com/content/www/us/en/support (ou Windows Update)"
}
Write-Output "Sempre baixe do site oficial do fabricante -- nunca de site de terceiro."
