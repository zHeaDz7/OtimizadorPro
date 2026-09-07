# Relatorio de diagnostico -- nao muda nada, so mostra o que pode estar
# limitando o desempenho: RAM livre, se os jogos estao instalados em HD
# (mecanico, lento) ou SSD, e espaco livre em disco.
$ErrorActionPreference = "SilentlyContinue"
. (Join-Path $PSScriptRoot "_detect_games.ps1")

Write-Output "=== MEMORIA RAM ==="
$os = Get-CimInstance Win32_OperatingSystem
$totalGB = [math]::Round($os.TotalVisibleMemorySize/1MB,1)
$freeGB = [math]::Round($os.FreePhysicalMemory/1MB,1)
$pctLivre = [math]::Round(($freeGB/$totalGB)*100,0)
Write-Output "  $freeGB GB livres de $totalGB GB total ($pctLivre% livre)"
if ($pctLivre -lt 20) {
  Write-Output "  AVISO: RAM bem apertada. Isso pode causar travada/engasgo em jogo pesado."
  Write-Output "  Recomendado: fechar programas de fundo (use a opcao de auditoria de processos)."
}
Write-Output ""

Write-Output "=== DISCOS ==="
Get-PhysicalDisk | ForEach-Object {
  $tipo = $_.MediaType
  $tamanhoGB = [math]::Round($_.Size/1GB,0)
  Write-Output "  Disco $($_.DeviceId): $($_.FriendlyName) -- $tipo -- ${tamanhoGB}GB"
}
Write-Output ""
Get-Volume | Where-Object { $_.DriveLetter } | ForEach-Object {
  $livreGB = [math]::Round($_.SizeRemaining/1GB,1)
  $totalGB2 = [math]::Round($_.Size/1GB,1)
  Write-Output "  $($_.DriveLetter): $livreGB GB livres de $totalGB2 GB"
}
Write-Output ""

Write-Output "=== SEUS JOGOS: HD ou SSD? ==="
$discosFisicos = Get-PhysicalDisk
$particoes = Get-Partition -ErrorAction SilentlyContinue
$jogos = Get-AllDetectedGames
foreach ($j in $jogos | Sort-Object Caminho -Unique) {
  $letra = $j.Caminho.Substring(0,1)
  $part = $particoes | Where-Object { $_.DriveLetter -eq $letra }
  if ($part) {
    $disco = $discosFisicos | Where-Object { $_.DeviceId -eq $part.DiskNumber }
    if ($disco) {
      $aviso = if ($disco.MediaType -eq "HDD") { " <- HD mecanico, mais lento pra carregar" } else { "" }
      Write-Output ("  {0,-30} [{1}:] {2}{3}" -f $j.Nome, $letra, $disco.MediaType, $aviso)
    }
  }
}
Write-Output ""
Write-Output "Se algum jogo importante estiver em HD, mover pro SSD e a melhoria"
Write-Output "que mais reduz travada/engasgo em jogos com muita gente/muito conteudo."
