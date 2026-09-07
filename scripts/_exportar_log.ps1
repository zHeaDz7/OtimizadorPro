# Empacota os logs dessa sessao (transcript + auditoria) num arquivo so,
# facil de mandar pra quem for te ajudar se algo der errado.
$ErrorActionPreference = "SilentlyContinue"
$logDir = Join-Path (Split-Path $PSScriptRoot -Parent) "Logs"
$destino = Join-Path (Split-Path $PSScriptRoot -Parent) "OtimizadorPro-log-$(Get-Date -Format 'yyyy-MM-dd_HHmmss').zip"

if (-not (Test-Path $logDir)) {
  Write-Output "Nenhum log encontrado ainda -- use o programa normalmente primeiro."
  return
}

# Copia pra uma pasta temporaria antes de zipar -- o transcript da SESSAO
# ATUAL fica aberto/travado pelo proprio PowerShell rodando agora, entao
# nao da pra ler ele direto. Copiando primeiro, arquivo travado so fica
# de fora (silenciosamente), em vez de travar a exportacao inteira.
$staging = Join-Path $env:TEMP "OtimizadorPro_export_$(Get-Date -Format 'yyyyMMddHHmmss')"
New-Item -ItemType Directory -Force -Path $staging | Out-Null

$copiados = 0
$pulados = 0
Get-ChildItem -Path $logDir -File | ForEach-Object {
  try {
    Copy-Item -LiteralPath $_.FullName -Destination $staging -ErrorAction Stop
    $copiados++
  } catch {
    $pulados++
  }
}

if ($copiados -eq 0) {
  Write-Output "AVISO: nao consegui copiar nenhum arquivo de log (todos em uso agora)."
  Remove-Item -Path $staging -Recurse -Force -ErrorAction SilentlyContinue
  return
}

try {
  Compress-Archive -Path (Join-Path $staging "*") -DestinationPath $destino -Force -ErrorAction Stop
  Write-Output "on: log exportado em $(Split-Path $destino -Leaf) ($copiados arquivo(s)$(if ($pulados -gt 0) { ", $pulados em uso agora ficaram de fora (normal se for o log da sessao atual)" }))."
  Write-Output "Mande esse arquivo .zip pra quem for te ajudar."
} catch {
  Write-Output "AVISO: nao consegui empacotar os logs ($_)"
} finally {
  Remove-Item -Path $staging -Recurse -Force -ErrorAction SilentlyContinue
}
