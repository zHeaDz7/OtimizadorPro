# Verifica e desliga a "Melhorar Precisao do Ponteiro" (aceleracao do mouse)
# do Windows. Isso e uma configuracao 100% oficial do proprio Windows (Painel
# de Controle > Mouse > Opcoes de Ponteiro) -- so estamos aplicando ela via
# registro, sem baixar nem instalar nada de terceiro. Reduz inconsistencia
# de mira em qualquer jogo. Reversivel a qualquer momento pelo Painel de
# Controle normal ou pela opcao "Reverter" abaixo.
#
# NOTA TECNICA: quando MouseSpeed=0, o Windows ignora completamente a curva
# de aceleracao (SmoothMouseXCurve/YCurve) -- e assim que o proprio driver
# funciona, documentado pela Microsoft. Por isso NAO escrevemos nenhum valor
# binario customizado de curva (esse e o metodo usado por ferramentas tipo
# "MarkC Fix"): escrever uma curva errada de memoria poderia bagunçar sua
# mira silenciosamente. Em vez disso, removemos qualquer curva customizada
# que ja exista (pra nao ter nada conflitando) e deixamos o Windows aplicar
# 1:1 puro, que e o resultado real que esse tipo de ferramenta busca.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"
$path = "HKCU:\Control Panel\Mouse"

function Test-Mouse1a1 {
  $atual = Get-ItemProperty -Path $path
  return ($atual.MouseSpeed -eq "0" -and $atual.MouseThreshold1 -eq "0" -and $atual.MouseThreshold2 -eq "0")
}

if ($Action -eq "Status") {
  if (Test-Mouse1a1) { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
  return
}

if ($Action -eq "Reverter") {
  Set-ItemProperty -Path $path -Name "MouseSpeed" -Value "1"
  Set-ItemProperty -Path $path -Name "MouseThreshold1" -Value "6"
  Set-ItemProperty -Path $path -Name "MouseThreshold2" -Value "10"
  Write-Output "on: revertido pro padrao de fabrica do Windows (Melhorar precisao do ponteiro LIGADO)."
  Write-Output "AVISO: precisa deslogar e logar de novo (ou reiniciar) pra valer."
  return
}

if (Test-Mouse1a1) {
  Write-Output "Ja esta ligado (1:1 fisico, sem aceleracao)."
  return
}

Set-ItemProperty -Path $path -Name "MouseSpeed" -Value "0"
Set-ItemProperty -Path $path -Name "MouseThreshold1" -Value "0"
Set-ItemProperty -Path $path -Name "MouseThreshold2" -Value "0"
Remove-ItemProperty -Path $path -Name "SmoothMouseXCurve" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $path -Name "SmoothMouseYCurve" -ErrorAction SilentlyContinue

Write-Output "on: mouse em 1:1 fisico (sem aceleracao, sensibilidade X e Y uniformes)."
Write-Output "AVISO: precisa deslogar e logar de novo no Windows (ou reiniciar) pra valer."
