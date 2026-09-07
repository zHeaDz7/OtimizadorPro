# So DIAGNOSTICA a rede -- nao muda nada. Ajuda a descobrir SE o problema
# de ping/lag e local (seu PC/roteador/Wi-Fi) ou e do provedor/servidor do
# jogo, antes de sair mexendo em configuracao a toa.
$ErrorActionPreference = "SilentlyContinue"

$adapter = Get-NetAdapter -Physical | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
if ($adapter) {
  $tipo = if ($adapter.PhysicalMediaType -match "802.11|Wireless|Native 802.11") { "Wi-Fi" } else { "Cabo (Ethernet)" }
  $velocidadeMbps = [math]::Round($adapter.LinkSpeed -replace "[^\d]", "" , 0)
  Write-Output "Conexao ativa: $($adapter.Name) -- $tipo -- $($adapter.LinkSpeed)"
  if ($tipo -eq "Wi-Fi") {
    Write-Output "AVISO: Wi-Fi tem latencia mais alta e instavel que cabo, mesmo com sinal bom."
    Write-Output "Se der pra usar cabo de rede, e a melhoria que mais reduz lag/oscilacao de ping."
  }
} else {
  Write-Output "Nao encontrei um adaptador de rede ativo."
}
Write-Output ""

Write-Output "=== PING PRO SEU ROTEADOR (rede local) ==="
$gateway = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Sort-Object RouteMetric | Select-Object -First 1).NextHop
if ($gateway) {
  $r = Test-Connection -ComputerName $gateway -Count 4 -ErrorAction SilentlyContinue
  if ($r) {
    $media = [math]::Round(($r | Measure-Object -Property ResponseTime -Average).Average, 0)
    Write-Output "  $gateway (seu roteador): $media ms de media"
    if ($media -gt 5) {
      Write-Output "  AVISO: ping alto ate o PROPRIO roteador (deveria ser 0-2ms) -- o problema e local:"
      Write-Output "  Wi-Fi com interferencia, cabo com defeito, ou roteador sobrecarregado. Nao e o provedor."
    } else {
      Write-Output "  Normal -- sua rede local esta rapida, se o ping no jogo esta alto o problema e depois do roteador (provedor/servidor)."
    }
  } else {
    Write-Output "  Nao consegui pingar o roteador ($gateway)."
  }
} else {
  Write-Output "  Nao encontrei o roteador (gateway padrao)."
}
Write-Output ""

Write-Output "=== PING PRA INTERNET (referencia geral) ==="
foreach ($alvo in @("1.1.1.1", "8.8.8.8")) {
  $r = Test-Connection -ComputerName $alvo -Count 4 -ErrorAction SilentlyContinue
  if ($r) {
    $media = [math]::Round(($r | Measure-Object -Property ResponseTime -Average).Average, 0)
    $perda = [math]::Round((4 - $r.Count) / 4 * 100, 0)
    Write-Output "  $alvo : $media ms de media, $perda% de perda de pacote"
  } else {
    Write-Output "  $alvo : sem resposta (bloqueado por firewall, ou sem internet)"
  }
}
Write-Output ""
Write-Output "Isso mostra sua latencia ate a internet em geral -- o ping DENTRO do jogo"
Write-Output "depende de onde fica o servidor especifico daquele jogo, pode ser bem diferente."
