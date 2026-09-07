# Calcula um "placar" de quantas otimizacoes ja estao aplicadas nessa
# maquina, de 0 a 100. Nao muda nada -- e so um resumo visual de
# progresso. Alguns itens ficam de fora da conta de proposito (ex:
# telemetria, DNS, HAGS) porque sao escolha pessoal, nao "certo ou
# errado" pra todo mundo.
$ErrorActionPreference = "SilentlyContinue"
$dir = $PSScriptRoot

$itens = @(
  "_mouse_fix.ps1", "_reg_usb_suspend.ps1", "_reg_mouse_queue.ps1",
  "_reg_islc.ps1", "_reg_accessibility.ps1", "_reg_priority_boost.ps1",
  "_gpu_msi_mode.ps1", "_gpu_tdr_delay.ps1", "_net_interrupt_moderation.ps1"
)

$ligados = 0
$total = 0
foreach ($script in $itens) {
  $status = & (Join-Path $dir $script) -Action Status 2>&1
  $primeira = ($status -split "`n")[0]
  if ($primeira -match "^LIGADO") {
    $ligados++
    $total++
  } elseif ($primeira -match "^DESLIGADO") {
    $total++
  }
  # itens com AVISO (sem admin, hardware nao suporta) ficam fora da conta --
  # nao e justo penalizar o placar por algo que a maquina nao permite medir
}

# Bonus fixos: plano de energia, defender exclusion, restore point (rapido de checar, sempre relevantes)
$bonusTotal = 3
$bonus = 0
try {
  $planoAtual = (powercfg /getactivescheme) -join " "
  if ($planoAtual -match "Desempenho") { $bonus++ }
} catch {}
try {
  $exclusions = (Get-MpPreference -ErrorAction Stop).ExclusionPath
  if ($exclusions -and $exclusions.Count -gt 0) { $bonus++ }
} catch {}
try {
  $rp = Get-ComputerRestorePoint -ErrorAction Stop
  if ($rp) { $bonus++ }
} catch {}

$total += $bonusTotal
$ligados += $bonus

if ($total -eq 0) {
  Write-Output "Nao consegui calcular o placar (sem acesso a nenhum item de diagnostico)."
  return
}
$pct = [math]::Round(($ligados / $total) * 100, 0)

Write-Output "=== SCORE DE SAUDE / OTIMIZACAO ==="
Write-Output ""
Write-Output "  $ligados de $total itens medidos ja estao otimizados"
Write-Output ""
$barraCheia = [math]::Floor($pct / 5)
$barra = ("#" * $barraCheia) + ("-" * (20 - $barraCheia))
Write-Output "  [$barra] $pct%"
Write-Output ""
if ($pct -ge 80) {
  Write-Output "  Otimo -- seu PC ja esta bem configurado pra jogos."
} elseif ($pct -ge 50) {
  Write-Output "  Razoavel -- ainda da pra melhorar. Rode a opcao T (Rodar TUDO) e depois"
  Write-Output "  passe pelos itens do Registro Avancado um por um."
} else {
  Write-Output "  Tem bastante coisa pra otimizar ainda. Comece pela opcao T (Rodar TUDO)."
}
Write-Output ""
Write-Output "(Itens que precisam de Administrador e voce rodou sem admin nao entram na conta --"
Write-Output "rode o Otimizar.bat normalmente, ele pede elevacao, pra medir certo.)"
