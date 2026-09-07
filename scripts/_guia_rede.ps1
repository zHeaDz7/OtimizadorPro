# Gera um guia de texto com dicas do lado do ROTEADOR/rede que ajudam
# ping e estabilidade, mas que NAO dao pra automatizar por script (cada
# roteador tem um painel diferente, e o PC nao tem acesso a ele por
# padrao). Detecta se voce esta em Wi-Fi ou cabo pra personalizar o
# aviso mais importante.
$ErrorActionPreference = "SilentlyContinue"

$adapter = Get-NetAdapter -Physical | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
$emWifi = $adapter -and ($adapter.PhysicalMediaType -match "802.11|Wireless|Native 802.11")

$saida = Join-Path $PSScriptRoot "..\Guia-Rede.txt"

$avisoWifi = if ($emWifi) {
@"
VOCE ESTA EM WI-FI AGORA
-------------------------
Isso e a mudanca que mais reduz lag/oscilacao de ping pra quem esta em
Wi-Fi: troque pra cabo de rede (Ethernet) sempre que possivel. Mesmo um
Wi-Fi com sinal "cheio" tem latencia mais alta e mais instavel que cabo,
porque o Wi-Fi negocia o ar com outros dispositivos (celular, TV,
vizinho) o tempo todo.

Se cabo nao for possivel:
- Use a banda de 5GHz em vez de 2.4GHz (menos interferencia, mais rapida
  -- so tem alcance menor, entao precisa estar mais perto do roteador).
- Evite deixar o micro-ondas ligado durante o jogo (interfere no 2.4GHz).
- Reduza a distancia/paredes entre o PC e o roteador.

"@
} else { "" }

$texto = @"
GUIA DE REDE -- DICAS DO LADO DO ROTEADOR
==========================================
$avisoWifi
Estas dicas nao dao pra automatizar por aqui porque dependem do painel
do SEU roteador especifico (cada marca/modelo tem um jeito diferente de
acessar, geralmente digitando 192.168.0.1 ou 192.168.1.1 no navegador).

------------------------------------------------------------------------
1) QoS (Quality of Service) no roteador
------------------------------------------------------------------------
O QUE E: uma configuracao no PAINEL DO ROTEADOR (nao no Windows) que
deixa voce priorizar o trafego de um dispositivo ou tipo de trafego
(jogos) sobre os outros na sua rede.
O QUE FAZ: se alguem em casa esta baixando arquivo grande, assistindo
stream ou fazendo upload enquanto voce joga, o QoS evita que isso
"engula" toda a banda e cause pico de ping no seu jogo.
COMO: entre no painel do roteador > procure "QoS" ou "Quality of
Service" > ative e priorize o dispositivo do seu PC (por IP ou MAC
address) ou a categoria "Gaming"/"Jogos" se o roteador tiver.

------------------------------------------------------------------------
2) Bufferbloat / Smart Queue Management (SQM)
------------------------------------------------------------------------
O QUE E: um problema comum em roteadores baratos onde o buffer de envio
fica "enchendo" durante upload/download pesado, causando um atraso que
sobe gradualmente (bufferbloat) em vez de manter estavel.
O QUE FAZ: roteadores mais novos (ou com firmware alternativo tipo
OpenWrt/DD-WRT) tem uma opcao "SQM" ou "Smart Queue Management" que
resolve isso automaticamente -- e o ajuste que mais resolve "ping sobe
quando alguem baixa algo em casa".
COMO: procure "SQM", "Smart Queue" ou "Bufferbloat" no painel do
roteador. Se seu roteador nao tiver essa opcao (a maioria dos que veem
de operadora nao tem), o QoS do item 1 ja ajuda bastante.

------------------------------------------------------------------------
3) Canal de Wi-Fi congestionado
------------------------------------------------------------------------
O QUE E: seu roteador transmite num "canal" de radio -- se o vizinho
usa o mesmo canal, os dois atrapalham um ao outro.
O QUE FAZ: trocar pra um canal menos usado reduz interferencia e picos
de latencia no Wi-Fi.
COMO: use um app tipo "WiFi Analyzer" no celular pra ver os canais
menos congestionados perto de voce, e mude no painel do roteador
(geralmente em Wi-Fi > Avancado > Canal). Ou deixe em "Automatico" se o
roteador for razoavelmente novo (muitos ja escolhem sozinho).

------------------------------------------------------------------------
4) Reiniciar o roteador de vez em quando
------------------------------------------------------------------------
Roteador ligado por semanas/meses sem reiniciar pode acumular
lentidao/memoria cheia. Reiniciar a cada 1-2 semanas (desligar da
tomada uns 10 segundos) resolve boa parte dos "meu ping fica ruim de
vez em quando sem motivo".

------------------------------------------------------------------------
5) Confirme com o item I de diagnostico deste OtimizadorPro
------------------------------------------------------------------------
Use a opcao de diagnostico de ping/latencia do OtimizadorPro pra ver se
o problema e ate o SEU roteador (rede local) ou depois dele (provedor).
Isso ajuda a saber se vale a pena mexer no roteador ou se o problema e
com o provedor de internet / servidor do jogo, fora do seu controle.
"@

[IO.File]::WriteAllText($saida, $texto, (New-Object System.Text.UTF8Encoding $false))
$statusConexao = if ($emWifi) { "Wi-Fi" } else { "Cabo" }
Write-Output "on: guia gerado em Guia-Rede.txt (conexao detectada: $statusConexao)"
