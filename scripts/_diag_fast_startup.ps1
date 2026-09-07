# So DIAGNOSTICA -- verifica se o "Inicializacao Rapida" (Fast Startup /
# hibernacao hibrida) esta ligado. E util pra boot rapido, mas em alguns
# PCs (principalmente apos update de driver, ou com dual-boot) pode
# deixar o sistema num estado "nao totalmente desligado" que causa
# comportamento estranho de driver/GPU na sessao seguinte. Nao desligamos
# automaticamente -- e uma configuracao de conveniencia, decisao sua.
$ErrorActionPreference = "SilentlyContinue"
$path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"

$valor = (Get-ItemProperty -Path $path -Name "HiberbootEnabled" -ErrorAction SilentlyContinue).HiberbootEnabled

Write-Output "=== INICIALIZACAO RAPIDA (FAST STARTUP) ==="
Write-Output ""
if ($null -eq $valor) {
  Write-Output "Nao consegui ler essa configuracao (pode nao existir em notebooks/desktops sem suporte a hibernacao)."
  return
}

if ($valor -eq 1) {
  Write-Output "LIGADO -- boot mais rapido, mas o Windows nao desliga 100% (salva parte do"
  Write-Output "kernel num arquivo de hibernacao pra carregar mais rapido)."
  Write-Output ""
  Write-Output "Se voce faz update de driver de GPU com frequencia, usa dual-boot, ou"
  Write-Output "notou comportamento estranho logo apos ligar o PC que REINICIAR (nao so"
  Write-Output "desligar) resolve, desligar essa opcao pode ajudar."
  Write-Output "COMO: Painel de Controle > Opcoes de Energia > Escolher o que os botoes"
  Write-Output "fazem > Alterar configuracoes indisponiveis no momento > desmarcar"
  Write-Output "'Ativar inicializacao rapida'."
} else {
  Write-Output "DESLIGADO -- o PC desliga por completo (boot um pouco mais lento, mas"
  Write-Output "estado sempre limpo)."
}
