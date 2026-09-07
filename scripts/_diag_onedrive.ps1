# So DIAGNOSTICA -- verifica se o OneDrive esta sincronizando. Sync de
# arquivo em segundo plano consome I/O de disco e as vezes CPU, o que
# pode causar engasgo bem na hora que voce abre um jogo (o Windows
# costuma sincronizar bastante logo depois do boot). Nao pausa
# automaticamente -- so avisa e explica como pausar manualmente quando
# quiser.
$ErrorActionPreference = "SilentlyContinue"

$proc = Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue
Write-Output "=== ONEDRIVE ==="
Write-Output ""
if (-not $proc) {
  Write-Output "OneDrive nao esta rodando nessa maquina. Nada a avisar."
  return
}

Write-Output "OneDrive esta rodando (processo ativo)."
Write-Output "Uso de CPU no momento: $([math]::Round($proc[0].CPU, 1))s acumulado"
Write-Output ""
Write-Output "Se notar engasgo logo ao abrir um jogo (principalmente logo apos ligar o"
Write-Output "PC), pode ser o OneDrive sincronizando arquivo grande em segundo plano."
Write-Output "Pra pausar temporariamente: clique no icone do OneDrive na bandeja do"
Write-Output "sistema (perto do relogio) > Ajuda e Configuracoes > Pausar sincronizacao"
Write-Output "> escolha 2/8/24 horas. Volta sozinho depois do tempo escolhido."
