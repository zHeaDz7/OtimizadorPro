# Cria um Ponto de Restauracao do Windows antes de qualquer mudanca.
# Isso e uma rede de seguranca: se alguma coisa nao ficar do jeito esperado,
# da pra voltar o Windows inteiro pro estado de antes em Configuracoes >
# Recuperacao > Restauracao do Sistema, sem perder arquivo pessoal nenhum.
$ErrorActionPreference = "Stop"

try {
  Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue

  # O Windows so deixa criar 1 ponto a cada 24h por padrao -- forcamos a
  # permissao pra garantir que o nosso ponto seja criado mesmo assim.
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name "SystemRestorePointCreationFrequency" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

  Checkpoint-Computer -Description "Antes do Otimizador Pro" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
  Write-Output "on: ponto de restauracao criado ('Antes do Otimizador Pro')"
  Write-Output "Se algo nao ficar bom, va em Configuracoes > Recuperacao > Restauracao do Sistema"
} catch {
  Write-Output "AVISO: nao consegui criar o ponto de restauracao ($_)"
  Write-Output "Isso pode acontecer se a Protecao do Sistema estiver desligada no disco C:,"
  Write-Output "ou se precisar ser Administrador. As outras opcoes continuam funcionando normalmente."
}
