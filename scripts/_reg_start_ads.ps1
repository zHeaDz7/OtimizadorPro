# Desliga sugestoes/anuncios/dicas que o Windows mostra no menu Iniciar,
# na tela de bloqueio e nas Configuracoes ("Voce pode gostar de...",
# apps sugeridos que instalam sozinhos, dicas de uso). Nao e desempenho
# puro -- e mais sobre parar de gastar espaco/atencao com propaganda do
# proprio Windows, mas fica aqui porque afeta o que aparece toda vez que
# voce abre o menu Iniciar.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"
$path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"

$chaves = @(
  "SubscribedContent-338388Enabled",   # apps sugeridos no menu Iniciar
  "SubscribedContent-338389Enabled",   # sugestoes nas Configuracoes
  "SubscribedContent-353694Enabled",   # dicas ocasionais
  "SubscribedContent-338393Enabled",   # notificacoes sugeridas
  "SoftLandingEnabled",                 # dicas do Windows
  "RotatingLockScreenOverlayEnabled",   # Windows Spotlight (dicas na tela de bloqueio)
  "SystemPaneSuggestionsEnabled"        # sugestoes no menu Iniciar
)

try {
  if ($Action -eq "Status") {
    $todosDesligados = $true
    foreach ($c in $chaves) {
      $v = (Get-ItemProperty -Path $path -Name $c -ErrorAction SilentlyContinue).$c
      if ($v -ne 0) { $todosDesligados = $false }
    }
    if ($todosDesligados) { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
  $valor = if ($Action -eq "Reverter") { 1 } else { 0 }
  foreach ($c in $chaves) {
    Set-ItemProperty -Path $path -Name $c -Value $valor -Type DWord -Force
  }

  if ($Action -eq "Reverter") {
    Write-Output "on: sugestoes/dicas do Windows voltaram a aparecer (padrao)."
  } else {
    Write-Output "on: sugestoes, apps recomendados e dicas do Windows desligados no menu Iniciar/Configuracoes/tela de bloqueio."
    Write-Output "AVISO: pode precisar deslogar e logar de novo pra sumir tudo."
  }
} catch {
  Write-Output "AVISO: nao consegui mudar essa configuracao ($_)"
}
