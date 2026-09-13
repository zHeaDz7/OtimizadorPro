# Só DIAGNOSTICA a rede -- não muda nada. Ajuda a descobrir SE o problema
# de ping/lag é local (seu PC/roteador/Wi-Fi) ou é do provedor/servidor do
# jogo, antes de sair mexendo em configuração à toa.
$ErrorActionPreference = "SilentlyContinue"

$adapter = Get-NetAdapter -Physical | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
if ($adapter) {
  $tipo = if ($adapter.PhysicalMediaType -match "802.11|Wireless|Native 802.11") { "Wi-Fi" } else { "Cabo (Ethernet)" }
  $velocidadeMbps = [math]::Round($adapter.LinkSpeed -replace "[^\d]", "" , 0)
  Write-Output "Conexão ativa: $($adapter.Name) -- $tipo -- $($adapter.LinkSpeed)"
  if ($tipo -eq "Wi-Fi") {
    Write-Output "AVISO: Wi-Fi tem latência mais alta e instável que cabo, mesmo com sinal bom."
    Write-Output "Se der pra usar cabo de rede, é a melhoria que mais reduz lag/oscilação de ping."
  }
} else {
  Write-Output "Não encontrei um adaptador de rede ativo."
}
Write-Output ""

Write-Output "=== PING PRO SEU ROTEADOR (rede local) ==="
$gateway = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Sort-Object RouteMetric | Select-Object -First 1).NextHop
if ($gateway) {
  $r = Test-Connection -ComputerName $gateway -Count 4 -ErrorAction SilentlyContinue
  if ($r) {
    $media = [math]::Round(($r | Measure-Object -Property ResponseTime -Average).Average, 0)
    Write-Output "  $gateway (seu roteador): $media ms de média"
    if ($media -gt 5) {
      Write-Output "  AVISO: ping alto até o PRÓPRIO roteador (deveria ser 0-2ms) -- o problema é local:"
      Write-Output "  Wi-Fi com interferência, cabo com defeito, ou roteador sobrecarregado. Não é o provedor."
    } else {
      Write-Output "  Normal -- sua rede local está rápida, se o ping no jogo está alto o problema é depois do roteador (provedor/servidor)."
    }
  } else {
    Write-Output "  Não consegui pingar o roteador ($gateway)."
  }
} else {
  Write-Output "  Não encontrei o roteador (gateway padrão)."
}
Write-Output ""

Write-Output "=== PING PRA INTERNET (referência geral) ==="
foreach ($alvo in @("1.1.1.1", "8.8.8.8")) {
  $r = Test-Connection -ComputerName $alvo -Count 4 -ErrorAction SilentlyContinue
  if ($r) {
    $media = [math]::Round(($r | Measure-Object -Property ResponseTime -Average).Average, 0)
    $perda = [math]::Round((4 - $r.Count) / 4 * 100, 0)
    Write-Output "  $alvo : $media ms de média, $perda% de perda de pacote"
  } else {
    Write-Output "  $alvo : sem resposta (bloqueado por firewall, ou sem internet)"
  }
}
Write-Output ""
Write-Output "Isso mostra sua latência até a internet em geral -- o ping DENTRO do jogo"
Write-Output "depende de onde fica o servidor específico daquele jogo, pode ser bem diferente."
