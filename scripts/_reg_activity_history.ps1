# Desliga o Historico de Atividades (Timeline) -- o Windows para de guardar
# um registro do que voce abriu/fez pra "continuar de onde parou" em outro
# PC com a mesma conta Microsoft. So privacidade, nao afeta desempenho.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"
$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
$chaves = @("EnableActivityFeed", "PublishUserActivities", "UploadUserActivities")

try {
  if ($Action -eq "Status") {
    $todosDesligados = $true
    foreach ($c in $chaves) {
      $v = (Get-ItemProperty -Path $path -Name $c -ErrorAction SilentlyContinue).$c
      if ($v -ne 0) { $todosDesligados = $false }
    }
    if ($todosDesligados) { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
  $valor = if ($Action -eq "Reverter") { 1 } else { 0 }
  foreach ($c in $chaves) {
    Set-ItemProperty -Path $path -Name $c -Value $valor -Type DWord -Force
  }
  if ($Action -eq "Reverter") {
    Write-Output "on: Historico de Atividades voltou a funcionar (padrao)."
  } else {
    Write-Output "on: Historico de Atividades (Timeline) desligado."
  }
} catch {
  Write-Output "AVISO: precisa ser Administrador pra essa parte ($_)"
}
