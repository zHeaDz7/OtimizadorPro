# O Windows Update, por padrao, tambem usa sua internet pra mandar
# pedaco de atualizacao pra OUTROS PCs (seus ou de estranhos na
# internet) enquanto baixa a sua propria atualizacao -- e o mesmo tipo
# de tecnologia de torrent, oficial e chamado "Delivery Optimization".
# Isso pode consumir banda em segundo plano bem na hora que voce ta
# jogando. Desligar so impede esse compartilhamento; o Windows continua
# recebendo atualizacao normal, direto da Microsoft.
param(
  [ValidateSet("Off", "On")]
  [string]$Action = "Off"
)
$ErrorActionPreference = "Stop"

try {
  $chave = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config"
  if (-not (Test-Path $chave)) { New-Item -Path $chave -Force | Out-Null }

  if ($Action -eq "Off") {
    New-ItemProperty -Path $chave -Name "DODownloadMode" -Value 0 -PropertyType DWord -Force | Out-Null
    Write-Output "on: Delivery Optimization desligado (Windows Update para de compartilhar sua internet com outros PCs)"
  } else {
    New-ItemProperty -Path $chave -Name "DODownloadMode" -Value 3 -PropertyType DWord -Force | Out-Null
    Write-Output "on: Delivery Optimization voltou ao padrao (compartilha atualizacao com PCs na rede local e internet)"
  }
  Write-Output "Reverter manualmente: Configuracoes > Windows Update > Opcoes avancadas > Otimizacao de Entrega"
} catch {
  Write-Output "AVISO: precisa ser Administrador pra essa parte ($_)"
}
