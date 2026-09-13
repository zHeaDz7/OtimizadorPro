# Gera um guia de texto com dicas do lado do ROTEADOR/rede que ajudam
# ping e estabilidade, mas que NÃO dão pra automatizar por script (cada
# roteador tem um painel diferente, e o PC não tem acesso a ele por
# padrão). Detecta se você está em Wi-Fi ou cabo pra personalizar o
# aviso mais importante.
$ErrorActionPreference = "SilentlyContinue"

$adapter = Get-NetAdapter -Physical | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
$emWifi = $adapter -and ($adapter.PhysicalMediaType -match "802.11|Wireless|Native 802.11")

$saida = Join-Path $PSScriptRoot "..\Guia-Rede.txt"

$avisoWifi = if ($emWifi) {
@"
VOCÊ ESTÁ EM WI-FI AGORA
-------------------------
É a mudança que mais reduz lag/oscilação de ping pra quem está em
Wi-Fi: troque pra cabo de rede (Ethernet) sempre que possível. Mesmo um
Wi-Fi com sinal "cheio" tem latência mais alta e mais instável que cabo,
porque o Wi-Fi negocia o ar com outros dispositivos (celular, TV,
vizinho) o tempo todo.

Se cabo não for possível:
- Use a banda de 5GHz em vez de 2.4GHz (menos interferência, mais rápida
  -- só tem alcance menor, então precisa estar mais perto do roteador).
- Evite deixar o micro-ondas ligado durante o jogo (interfere no 2.4GHz).
- Reduza a distância/paredes entre o PC e o roteador.

"@
} else { "" }

$texto = @"
GUIA DE REDE -- DICAS DO LADO DO ROTEADOR
==========================================
$avisoWifi
Estas dicas não dão pra automatizar por aqui porque dependem do painel
do SEU roteador específico (cada marca/modelo tem um jeito diferente de
acessar, geralmente digitando 192.168.0.1 ou 192.168.1.1 no navegador).

------------------------------------------------------------------------
1) QoS (Quality of Service) no roteador
------------------------------------------------------------------------
O QUE É: uma configuração no PAINEL DO ROTEADOR (não no Windows) que
deixa você priorizar o tráfego de um dispositivo ou tipo de tráfego
(jogos) sobre os outros na sua rede.
O QUE FAZ: se alguém em casa está baixando arquivo grande, assistindo
stream ou fazendo upload enquanto você joga, o QoS evita que isso
"engula" toda a banda e cause pico de ping no seu jogo.
COMO: entre no painel do roteador > procure "QoS" ou "Quality of
Service" > ative e priorize o dispositivo do seu PC (por IP ou MAC
address) ou a categoria "Gaming"/"Jogos" se o roteador tiver.

------------------------------------------------------------------------
2) Bufferbloat / Smart Queue Management (SQM)
------------------------------------------------------------------------
O QUE É: um problema comum em roteadores baratos onde o buffer de envio
fica "enchendo" durante upload/download pesado, causando um atraso que
sobe gradualmente (bufferbloat) em vez de manter estável.
O QUE FAZ: roteadores mais novos (ou com firmware alternativo tipo
OpenWrt/DD-WRT) tem uma opção "SQM" ou "Smart Queue Management" que
resolve isso automaticamente -- é o ajuste que mais resolve "ping sobe
quando alguém baixa algo em casa".
COMO: procure "SQM", "Smart Queue" ou "Bufferbloat" no painel do
roteador. Se seu roteador não tiver essa opção (a maioria dos que vêm
de operadora não tem), o QoS do item 1 já ajuda bastante.

------------------------------------------------------------------------
3) Canal de Wi-Fi congestionado
------------------------------------------------------------------------
O QUE É: seu roteador transmite num "canal" de rádio -- se o vizinho
usa o mesmo canal, os dois atrapalham um ao outro.
O QUE FAZ: trocar pra um canal menos usado reduz interferência e picos
de latência no Wi-Fi.
COMO: use um app tipo "WiFi Analyzer" no celular pra ver os canais
menos congestionados perto de você, e mude no painel do roteador
(geralmente em Wi-Fi > Avançado > Canal). Ou deixe em "Automático" se o
roteador for razoavelmente novo (muitos já escolhem sozinho).

------------------------------------------------------------------------
4) Reiniciar o roteador de vez em quando
------------------------------------------------------------------------
Roteador ligado por semanas/meses sem reiniciar pode acumular
lentidão/memória cheia. Reiniciar a cada 1-2 semanas (desligar da
tomada uns 10 segundos) resolve boa parte dos "meu ping fica ruim de
vez em quando sem motivo".

------------------------------------------------------------------------
5) Confirme com o diagnóstico deste OtimizadorPro
------------------------------------------------------------------------
Use a opção de diagnóstico de ping/latência do OtimizadorPro pra ver se
o problema é até o SEU roteador (rede local) ou depois dele (provedor).
Isso ajuda a saber se vale a pena mexer no roteador ou se o problema é
com o provedor de internet / servidor do jogo, fora do seu controle.
"@

[IO.File]::WriteAllText($saida, $texto, (New-Object System.Text.UTF8Encoding $true))
$statusConexao = if ($emWifi) { "Wi-Fi" } else { "Cabo" }
Write-Output "on: guia gerado em Guia-Rede.txt (conexão detectada: $statusConexao)"
