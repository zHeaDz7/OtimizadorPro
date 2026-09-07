# So DIAGNOSTICA -- lista antivirus instalados. Ter MAIS de um antivirus
# em tempo real ativo ao mesmo tempo (alem do Defender) costuma causar
# lentidao forte (os dois ficam escaneando o mesmo arquivo) e as vezes
# ate conflito de verdade. Nao desinstala nada -- so avisa.
$ErrorActionPreference = "SilentlyContinue"

$produtos = Get-CimInstance -Namespace "root\SecurityCenter2" -ClassName "AntiVirusProduct" -ErrorAction SilentlyContinue

Write-Output "=== ANTIVIRUS INSTALADOS ==="
Write-Output ""
if (-not $produtos) {
  Write-Output "Nao consegui listar (comum em algumas versoes/edicoes do Windows)."
  return
}

$terceiros = @($produtos | Where-Object { $_.displayName -notmatch "Windows Defender|Microsoft Defender" })
foreach ($p in $produtos) {
  Write-Output "  - $($p.displayName)"
}
Write-Output ""

if ($terceiros.Count -gt 1) {
  Write-Output "AVISO: mais de um antivirus de terceiro detectado -- isso quase sempre"
  Write-Output "causa lentidao (os dois escaneiam o mesmo arquivo) e pode gerar falso"
  Write-Output "positivo entre eles. Recomendado manter so um."
} elseif ($terceiros.Count -eq 1) {
  Write-Output "Voce tem um antivirus de terceiro alem do que o Windows ja tem embutido."
  Write-Output "Normalmente o Windows Defender fica em modo passivo automaticamente"
  Write-Output "quando outro antivirus esta ativo, entao geralmente nao ha conflito --"
  Write-Output "mas se notar lentidao, vale conferir as exclusoes de pasta de jogo"
  Write-Output "tambem nesse outro antivirus (o item 3 deste OtimizadorPro so configura"
  Write-Output "o Defender)."
} else {
  Write-Output "So o Windows Defender (ou nenhum terceiro detectado). Configuracao limpa."
}
