# Troca o plano de energia do Windows pra "Desempenho maximo" (o plano
# oficial e escondido da Microsoft, "Ultimate Performance") -- ou "Alto
# desempenho" se o "Ultimate" nao existir/nao puder ser criado nessa
# maquina. Isso impede o Windows de reduzir a velocidade da CPU pra
# economizar energia durante o jogo. 100% reversivel: pode voltar pro
# "Equilibrado" a qualquer hora em Configuracoes > Energia.
$ErrorActionPreference = "Stop"

$ultimateGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
$highPerfGuid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
$balancedGuid = "381b4222-f694-41f0-9685-ff5bb260df2e"
$powerSaverGuid = "a1841308-3541-4fab-bc81-f71556f20b4a"
$conhecidos = @($highPerfGuid, $balancedGuid, $powerSaverGuid)

$lista = powercfg /list
$linhas = $lista | Where-Object { $_ -match "GUID do Esquema de Energia:\s*([0-9a-f\-]{36})" }
$guidExtra = $null
foreach ($linha in $linhas) {
  if ($linha -match "([0-9a-f\-]{36})") {
    $g = $matches[1]
    if ($conhecidos -notcontains $g) { $guidExtra = $g; break }
  }
}

if ($guidExtra) {
  # Ja existe um plano "extra" (duplicado antes, provavelmente o Desempenho
  # Maximo) -- so reativa ele, sem duplicar de novo.
  powercfg /setactive $guidExtra | Out-Null
  Write-Output "on: plano de energia 'Desempenho maximo' ativado (ja existia)."
} else {
  $saida = powercfg /duplicatescheme $ultimateGuid 2>&1
  $novoGuid = $null
  foreach ($linha in $saida) {
    if ($linha -match "([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})") {
      $novoGuid = $matches[1]
      break
    }
  }
  if ($novoGuid) {
    powercfg /setactive $novoGuid | Out-Null
    Write-Output "on: plano de energia 'Desempenho maximo' criado e ativado."
  } else {
    powercfg /setactive $highPerfGuid | Out-Null
    Write-Output "on: plano de energia 'Alto desempenho' ativado (essa maquina nao suporta o 'Desempenho maximo')."
  }
}

Write-Output "Pra voltar ao padrao: Configuracoes > Sistema > Energia > escolha 'Equilibrado'."
