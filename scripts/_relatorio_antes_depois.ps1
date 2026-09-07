# Tira uma "foto" do estado atual (RAM livre, espaco em disco, plano de
# energia) e salva num arquivo. Rode ANTES de otimizar e DEPOIS de
# otimizar -- na segunda vez ele compara com a foto anterior e mostra a
# diferenca. Prova visual de que alguma coisa mudou de verdade, nao só
# confiar que sim.
$ErrorActionPreference = "SilentlyContinue"
$snapPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Logs\snapshot_antes.json"

function Get-Snapshot {
  $os = Get-CimInstance Win32_OperatingSystem
  $planoRaw = (powercfg /getactivescheme) -join " "
  $plano = if ($planoRaw -match "\(([^)]+)\)") { $matches[1] } else { $planoRaw }
  $ramLivreMB = [math]::Round($os.FreePhysicalMemory / 1024, 0)
  $ramTotalMB = [math]::Round($os.TotalVisibleMemorySize / 1024, 0)
  $discoC = Get-Volume -DriveLetter C -ErrorAction SilentlyContinue
  $discoLivreGB = if ($discoC) { [math]::Round($discoC.SizeRemaining / 1GB, 1) } else { 0 }
  return [PSCustomObject]@{
    DataHora     = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    RamLivreMB   = $ramLivreMB
    RamTotalMB   = $ramTotalMB
    DiscoCLivreGB = $discoLivreGB
    PlanoEnergia = $plano
  }
}

$atual = Get-Snapshot

if (-not (Test-Path $snapPath)) {
  $atual | ConvertTo-Json | Set-Content -Path $snapPath -Encoding UTF8
  Write-Output "=== FOTO 'ANTES' SALVA ==="
  Write-Output "  RAM livre: $($atual.RamLivreMB) MB de $($atual.RamTotalMB) MB"
  Write-Output "  Disco C livre: $($atual.DiscoCLivreGB) GB"
  Write-Output "  Plano de energia: $($atual.PlanoEnergia)"
  Write-Output ""
  Write-Output "Agora rode as otimizacoes (T, Limpeza Profunda, etc) e rode essa opcao"
  Write-Output "de novo depois pra ver a comparacao ANTES vs DEPOIS."
  return
}

$antes = Get-Content -Path $snapPath -Raw | ConvertFrom-Json
Write-Output "=== ANTES (em $($antes.DataHora)) vs DEPOIS (agora) ==="
Write-Output ""
Write-Output ("  RAM livre:        {0,8} MB  ->  {1,8} MB   ({2}{3} MB)" -f $antes.RamLivreMB, $atual.RamLivreMB, $(if (($atual.RamLivreMB - $antes.RamLivreMB) -ge 0) {"+"} else {""}), ($atual.RamLivreMB - $antes.RamLivreMB))
Write-Output ("  Disco C livre:    {0,8} GB  ->  {1,8} GB   ({2}{3} GB)" -f $antes.DiscoCLivreGB, $atual.DiscoCLivreGB, $(if (($atual.DiscoCLivreGB - $antes.DiscoCLivreGB) -ge 0) {"+"} else {""}), [math]::Round($atual.DiscoCLivreGB - $antes.DiscoCLivreGB, 1))
Write-Output ("  Plano de energia: {0}  ->  {1}" -f $antes.PlanoEnergia, $atual.PlanoEnergia)
Write-Output ""
Write-Output "Removendo a foto antiga -- rode essa opcao de novo pra comecar uma nova comparacao."
Remove-Item -Path $snapPath -Force -ErrorAction SilentlyContinue
