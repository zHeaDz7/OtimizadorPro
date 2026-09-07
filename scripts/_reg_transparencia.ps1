# Desliga os efeitos de transparencia do Windows (barra de tarefas, menu
# Iniciar, janelas). Em PC mais fraco isso reduz um pouco o trabalho da
# placa de video pra desenhar a interface -- ganho pequeno, mas real.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"
$path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"

try {
  if ($Action -eq "Status") {
    $v = (Get-ItemProperty -Path $path -Name "EnableTransparency" -ErrorAction SilentlyContinue).EnableTransparency
    if ($v -eq 0) { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
  if ($Action -eq "Reverter") {
    Set-ItemProperty -Path $path -Name "EnableTransparency" -Value 1 -Type DWord -Force
    Write-Output "on: efeitos de transparencia religados."
  } else {
    Set-ItemProperty -Path $path -Name "EnableTransparency" -Value 0 -Type DWord -Force
    Write-Output "on: efeitos de transparencia desligados."
  }
} catch {
  Write-Output "AVISO: nao consegui mudar essa configuracao ($_)"
}
