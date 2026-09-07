# Liga o "Assistente de Armazenamento" (Storage Sense) do Windows -- um
# recurso oficial que limpa arquivo temporario, itens antigos da
# Lixeira e da pasta Downloads sozinho, de tempos em tempos. Disco cheio
# (principalmente SSD quase no limite) deixa o Windows inteiro e os
# jogos mais lentos. So configura HKCU (nao precisa ser Administrador),
# e voce pode desligar a qualquer momento em Configuracoes > Sistema >
# Armazenamento > Assistente de Armazenamento.
$ErrorActionPreference = "Stop"

try {
  $chave = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy"
  if (-not (Test-Path $chave)) { New-Item -Path $chave -Force | Out-Null }

  New-ItemProperty -Path $chave -Name "01" -Value 1 -PropertyType DWord -Force | Out-Null       # liga o Storage Sense
  New-ItemProperty -Path $chave -Name "04" -Value 1 -PropertyType DWord -Force | Out-Null       # limpa temporarios que apps nao usam mais
  New-ItemProperty -Path $chave -Name "08" -Value 30 -PropertyType DWord -Force | Out-Null      # esvazia Lixeira apos 30 dias
  New-ItemProperty -Path $chave -Name "32" -Value 30 -PropertyType DWord -Force | Out-Null      # limpa Downloads nao mexidos ha 30 dias
  New-ItemProperty -Path $chave -Name "2048" -Value 7 -PropertyType DWord -Force | Out-Null     # roda a limpeza toda semana

  Write-Output "on: Assistente de Armazenamento ligado (limpa temporarios toda semana, Lixeira/Downloads apos 30 dias parados)"
  Write-Output "Reverter: Configuracoes > Sistema > Armazenamento > Assistente de Armazenamento > Desativado"
} catch {
  Write-Output "AVISO: nao consegui configurar ($_)"
}
