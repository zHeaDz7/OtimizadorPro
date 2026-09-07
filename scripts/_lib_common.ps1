# Biblioteca compartilhada -- carregada via dot-source por outros scripts.
# NAO defina $ErrorActionPreference aqui (mesmo motivo do _detect_games.ps1:
# dot-source roda no escopo de quem chama, uma preferencia global aqui
# vazaria e sobrescreveria o "Stop" do script chamador).

function Write-AuditLog {
  param(
    [Parameter(Mandatory)][string]$Item,
    [Parameter(Mandatory)][string]$Acao,
    [string]$Antes = "",
    [string]$Depois = "",
    [string]$Resultado = ""
  )
  try {
    $logDir = Join-Path (Split-Path $PSScriptRoot -Parent) "Logs"
    if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Force -Path $logDir | Out-Null }
    $csv = Join-Path $logDir "auditoria.csv"
    $linha = [PSCustomObject]@{
      DataHora  = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
      Item      = $Item
      Acao      = $Acao
      Antes     = $Antes
      Depois    = $Depois
      Resultado = $Resultado
      Usuario   = $env:USERNAME
    }
    $existe = Test-Path $csv
    $linha | Export-Csv -Path $csv -Append -NoTypeInformation -Encoding UTF8 -Force
    if (-not $existe) {
      # Export-Csv com -Append em arquivo novo as vezes duplica cabecalho
      # dependendo da versao do PowerShell -- garante que so tem 1 linha de header
    }
  } catch {
    # Auditoria nunca pode quebrar a acao principal -- falha silenciosa aqui de proposito
  }
}

function Get-ItemRegistroSeguro {
  param([string]$Path, [string]$Name)
  try {
    return (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name
  } catch {
    return $null
  }
}
