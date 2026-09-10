# Define qual placa de video (integrada ou dedicada) um jogo especifico
# deve sempre usar, via a mesma configuracao oficial que Configuracoes >
# Sistema > Tela > Graficos usa por tras dos panos (chave
# HKCU:\...\DirectX\UserGpuPreferences). Nao mexe no driver nem instala
# nada -- so grava a preferencia por executavel, exatamente como o
# Windows faz quando voce escolhe manualmente ali. E por usuario (HKCU),
# entao nao precisa ser Administrador.
param(
  [string]$Caminho,
  [ValidateSet("Definir", "Remover", "Listar")]
  [string]$Action = "Definir"
)
$ErrorActionPreference = "Stop"
$chave = "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences"

try {
  if ($Action -eq "Listar") {
    if (-not (Test-Path $chave)) { return }
    $props = Get-ItemProperty -Path $chave -ErrorAction SilentlyContinue
    if (-not $props) { return }
    $props.PSObject.Properties | Where-Object { $_.Name -notmatch "^PS" -and $_.Value -match "GpuPreference=2" } | ForEach-Object {
      Write-Output $_.Name
    }
    return
  }

  if (-not $Caminho) {
    Write-Output "AVISO: nenhum executavel informado."
    return
  }

  if (-not (Test-Path $chave)) { New-Item -Path $chave -Force | Out-Null }

  if ($Action -eq "Remover") {
    Remove-ItemProperty -Path $chave -Name $Caminho -ErrorAction SilentlyContinue
    Write-Output "on: preferencia removida pra $Caminho -- volta pro padrao do Windows escolher a GPU."
    return
  }

  Set-ItemProperty -Path $chave -Name $Caminho -Value "GpuPreference=2;" -Type String -Force
  Write-Output "on: esse jogo agora sempre vai abrir na placa de video de Alto Desempenho."
} catch {
  Write-Output "AVISO: nao consegui gravar essa preferencia ($_)"
}
