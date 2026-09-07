param(
  [ValidateSet("Cloudflare", "Google", "Automatico")]
  [string]$Provedor = "Cloudflare"
)
# Troca o DNS dos adaptadores de rede ativos por um servidor DNS mais
# rapido (Cloudflare ou Google) -- isso so afeta a velocidade de resolver
# nomes de site/servidor (ex: entrar num servidor de jogo, carregar update),
# nao afeta o jogo em si depois de conectado. Reversivel a qualquer
# momento escolhendo "Automatico" (volta a pegar do roteador/provedor).
$ErrorActionPreference = "Stop"

$dns = switch ($Provedor) {
  "Cloudflare" { @("1.1.1.1", "1.0.0.1") }
  "Google" { @("8.8.8.8", "8.8.4.4") }
  "Automatico" { $null }
}

try {
  $adapters = @(Get-NetAdapter -Physical | Where-Object { $_.Status -eq "Up" })
  if ($adapters.Count -eq 0) {
    Write-Output "Nenhum adaptador de rede ativo encontrado."
    return
  }
  foreach ($a in $adapters) {
    if ($dns) {
      Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ServerAddresses $dns -ErrorAction Stop
    } else {
      Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ResetServerAddresses -ErrorAction Stop
    }
  }
  if ($dns) {
    Write-Output "on: DNS trocado pra $Provedor ($($dns -join ', ')) em $($adapters.Count) adaptador(es)"
  } else {
    Write-Output "on: DNS voltou pro automatico (do roteador/provedor) em $($adapters.Count) adaptador(es)"
  }
} catch {
  Write-Output "AVISO: precisa ser Administrador pra essa parte ($_)"
}
