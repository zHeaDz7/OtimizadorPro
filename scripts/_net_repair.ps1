# Reseta o "catalogo" de rede do Windows (Winsock) e a pilha TCP/IP pros
# valores de fabrica. Isso NAO e uma otimizacao de desempenho -- e uma
# ferramenta de CONSERTO pra quando a internet comeca a se comportar
# estranho depois de instalar/desinstalar VPN, antivirus, ou outro
# programa que mexe na rede (sintomas: internet cai sozinha, sites nao
# carregam mas o Wi-Fi mostra conectado, erro de DNS do nada). Sao
# comandos oficiais do proprio Windows (netsh). SEMPRE pede confirmacao
# porque precisa reiniciar o PC pra valer, e desfaz configuracoes
# manuais de rede que voce tenha feito (ex: proxy customizado).
$ErrorActionPreference = "Stop"

try {
  # netsh e um programa externo, nao um cmdlet do PowerShell -- ele nao
  # lanca excecao mesmo quando falha (precisa checar $LASTEXITCODE na
  # mao, senao o script pode reportar sucesso mesmo sem admin).
  $r1 = netsh winsock reset 2>&1
  if ($LASTEXITCODE -ne 0) { throw "winsock reset: $($r1 -join ' ')" }
  $r2 = netsh int ip reset 2>&1
  if ($LASTEXITCODE -ne 0) { throw "ip reset: $($r2 -join ' ')" }

  Write-Output "on: catalogo Winsock e pilha TCP/IP resetados pro padrao do Windows."
  Write-Output "AVISO: PRECISA REINICIAR O PC AGORA pra valer. Se voce tinha proxy ou VPN"
  Write-Output "configurados manualmente, vai precisar configurar de novo depois de reiniciar."
} catch {
  Write-Output "AVISO: precisa ser Administrador pra essa parte ($_)"
}
