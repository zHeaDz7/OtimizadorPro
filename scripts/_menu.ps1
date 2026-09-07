$ErrorActionPreference = "Continue"
$dir = $PSScriptRoot
$logDir = Join-Path (Split-Path $dir -Parent) "Logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$logFile = Join-Path $logDir "sessao_$(Get-Date -Format 'yyyy-MM-dd_HHmmss').txt"
try { Start-Transcript -Path $logFile -Append | Out-Null } catch {}

. (Join-Path $dir "_lib_common.ps1")

function Invoke-RegToggle([string]$nome, [string]$scriptName) {
  $script = Join-Path $dir $scriptName
  $status = & $script -Action Status
  $corStatus = if ($status -match "^LIGADO") { "Green" } elseif ($status -match "^DESLIGADO") { "DarkGray" } else { "Yellow" }
  Write-Host "$nome -- status atual: " -NoNewline
  Write-Host "$status" -ForegroundColor $corStatus
  $r = Read-Host "Aplicar (A), Reverter pro padrao do Windows (R), ou Enter pra cancelar"
  if ($r -match "^[Aa]") {
    $resultado = & $script -Action Aplicar
    $resultado
    Write-AuditLog -Item $nome -Acao "Aplicar" -Antes $status -Depois "Aplicado" -Resultado (($resultado -split "`n")[0])
  } elseif ($r -match "^[Rr]") {
    $resultado = & $script -Action Reverter
    $resultado
    Write-AuditLog -Item $nome -Acao "Reverter" -Antes $status -Depois "Revertido" -Resultado (($resultado -split "`n")[0])
  } else {
    Write-Output "Cancelado, nada alterado."
  }
}

function Show-CpuGpuMenu {
  while ($true) {
    Clear-Host
    Write-Host "=== CPU/GPU AVANCADO ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1  Core Parking desligado (mantem todos os nucleos sempre ativos)"
    Write-Host "  2  MSI Mode da GPU (interrupcao mais eficiente, menos DPC latency)"
    Write-Host "  3  TDR Delay maior (evita 'driver parou de responder' falso em cena pesada)"
    Write-Host ""
    Write-Host "  0  Voltar"
    Write-Host ""
    $c = (Read-Host "Escolha").Trim()
    try {
      switch ($c) {
        "1" { Invoke-RegToggle "Core Parking" "_core_parking.ps1" }
        "2" { Invoke-RegToggle "MSI Mode da GPU" "_gpu_msi_mode.ps1" }
        "3" { Invoke-RegToggle "TDR Delay" "_gpu_tdr_delay.ps1" }
        "0" { return }
        default { continue }
      }
    } catch {
      Write-Host ""
      Write-Host "ERRO: $_" -ForegroundColor Red
    }
    if ($c -ne "0") {
      Write-Host ""
      Read-Host "Enter para voltar"
    }
  }
}

function Show-DiagExtraMenu {
  while ($true) {
    Clear-Host
    Write-Host "=== DIAGNOSTICOS EXTRAS (nao mudam nada) ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1  RAM: Dual Channel ou Single Channel"
    Write-Host "  2  Overlays/gravacao rodando agora (Discord, GeForce Exp, Steam...)"
    Write-Host "  3  Data do driver da placa de video"
    Write-Host "  4  Core Isolation / Memory Integrity (VBS)"
    Write-Host "  5  OneDrive sincronizando"
    Write-Host "  6  Temperatura/throttling de CPU"
    Write-Host "  7  Antivirus instalados (conflito de terceiro)"
    Write-Host "  8  Controle/gamepad (Bluetooth vs cabo)"
    Write-Host "  9  GPU Hibrida (notebook com 2 placas)"
    Write-Host "  10 Taxa de atualizacao de CADA monitor conectado"
    Write-Host "  11 Perfil notebook (bateria vs tomada)"
    Write-Host "  12 VPN ativa"
    Write-Host "  13 Wi-Fi: canal, sinal, banda"
    Write-Host "  14 Inicializacao Rapida (Fast Startup)"
    Write-Host "  15 Drivers desatualizados (placa de video, rede, audio, armazenamento)"
    Write-Host ""
    Write-Host "  0  Voltar"
    Write-Host ""
    $c = (Read-Host "Escolha").Trim()
    $mapa = @{
      "1" = "_diag_ram_channel.ps1"; "2" = "_diag_overlays.ps1"; "3" = "_diag_gpu_driver.ps1"
      "4" = "_diag_vbs.ps1"; "5" = "_diag_onedrive.ps1"; "6" = "_diag_cpu_throttle.ps1"
      "7" = "_diag_antivirus.ps1"; "8" = "_diag_gamepad.ps1"; "9" = "_diag_hybrid_gpu.ps1"
      "10" = "_diag_multi_monitor.ps1"; "11" = "_perfil_notebook.ps1"; "12" = "_diag_vpn.ps1"
      "13" = "_diag_wifi.ps1"; "14" = "_diag_fast_startup.ps1"
    }
    try {
      if ($c -eq "0") { return }
      if ($c -eq "15") {
        & (Join-Path $dir "_diag_drivers.ps1")
        Write-Host ""
        $ru = Read-Host "Abrir Windows Update > Atualizacoes opcionais agora? (S para sim, Enter pra nao)"
        if ($ru -match "^[Ss]") { & (Join-Path $dir "_diag_drivers.ps1") -AbrirWindowsUpdate }
      } elseif ($mapa.ContainsKey($c)) { & (Join-Path $dir $mapa[$c]) } else { continue }
    } catch {
      Write-Host ""
      Write-Host "ERRO: $_" -ForegroundColor Red
    }
    Write-Host ""
    Read-Host "Enter para voltar"
  }
}

function Show-FerramentasMenu {
  while ($true) {
    Clear-Host
    Write-Host "=== FERRAMENTAS E RELATORIOS ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1  Ver status de TUDO que tem Aplicar/Reverter (preview, nao muda nada)"
    Write-Host "  2  Score de saude/otimizacao (0-100)"
    Write-Host "  3  Relatorio Antes/Depois (rode antes E depois de otimizar)"
    Write-Host "  4  Desfazer TUDO (reverte tudo pro padrao do Windows)"
    Write-Host "  5  Pausar Windows Search por completo (Aplicar/Reverter)"
    Write-Host "  6  Ver log de auditoria (toda mudanca de Registro Avancado, com antes/depois)"
    Write-Host "  7  Exportar log dessa sessao (pra mandar pro suporte se algo der errado)"
    Write-Host ""
    Write-Host "  0  Voltar"
    Write-Host ""
    $c = (Read-Host "Escolha").Trim()
    try {
      switch ($c) {
        "1" { & (Join-Path $dir "_relatorio_status.ps1") }
        "2" { & (Join-Path $dir "_score_saude.ps1") }
        "3" { & (Join-Path $dir "_relatorio_antes_depois.ps1") }
        "4" {
          Write-Host "Isso reverte TODOS os itens de Registro Avancado, HAGS e Delivery"
          Write-Host "Optimization de volta pro padrao do Windows de uma vez."
          $r = Read-Host "Confirma? (S para sim, Enter pra cancelar)"
          if ($r -match "^[Ss]") { & (Join-Path $dir "_desfazer_tudo.ps1") }
          else { Write-Output "Cancelado, nada alterado." }
        }
        "5" { Invoke-RegToggle "Pausar Windows Search" "_search_pause.ps1" }
        "6" {
          $csv = Join-Path (Split-Path $dir -Parent) "Logs\auditoria.csv"
          if (Test-Path $csv) { Import-Csv $csv | Format-Table -AutoSize | Out-String -Width 200 }
          else { Write-Output "Nenhuma mudanca de Registro Avancado registrada ainda nessa maquina." }
        }
        "7" { & (Join-Path $dir "_exportar_log.ps1") }
        "0" { return }
        default { continue }
      }
    } catch {
      Write-Host ""
      Write-Host "ERRO: $_" -ForegroundColor Red
    }
    if ($c -ne "0") {
      Write-Host ""
      Read-Host "Enter para voltar"
    }
  }
}

function Show-Busca {
  $indice = @(
    @{ C = "0R"; D = "Criar ponto de restauracao" }
    @{ C = "1"; D = "RAM, discos, jogos" }
    @{ C = "2"; D = "Detectar jogos Steam/Epic" }
    @{ C = "I"; D = "Arquivo de paginacao / pagefile" }
    @{ C = "3"; D = "Exclusoes Windows Defender" }
    @{ C = "4"; D = "Exclusoes indexacao Windows Search" }
    @{ C = "5"; D = "Plano de energia Desempenho Maximo" }
    @{ C = "6"; D = "Game Mode, Game Bar, efeitos visuais" }
    @{ C = "7"; D = "Prioridade CPU/GPU MMCSS" }
    @{ C = "8"; D = "Rede: Nagle, NetworkThrottling, LSO, energia placa" }
    @{ C = "9"; D = "HAGS agendamento GPU hardware" }
    @{ C = "J"; D = "DNS Cloudflare/Google" }
    @{ C = "K"; D = "Melhorias de audio (delay/estalo)" }
    @{ C = "L"; D = "TRIM SSD" }
    @{ C = "M"; D = "Otimizacoes de Tela Cheia" }
    @{ C = "N"; D = "Telemetria Windows DiagTrack" }
    @{ C = "P"; D = "Taxa de atualizacao monitor Hz" }
    @{ C = "Q"; D = "Storage Sense limpeza automatica" }
    @{ C = "R"; D = "Delivery Optimization Windows Update" }
    @{ C = "PG"; D = "Ping e latencia diagnostico" }
    @{ C = "GR"; D = "Guia de rede QoS roteador" }
    @{ C = "IM"; D = "Interrupt Moderation placa de rede" }
    @{ C = "NR"; D = "Reparar rede Winsock TCP-IP" }
    @{ C = "S"; D = "Mouse 1:1 aceleracao" }
    @{ C = "U"; D = "USB Selective Suspend" }
    @{ C = "V"; D = "Timer kernel bcdedit" }
    @{ C = "W"; D = "Fila mouse teclado MouseDataQueueSize" }
    @{ C = "X"; D = "ISLC kernel na RAM DisablePagingExecutive" }
    @{ C = "Y"; D = "StickyKeys ToggleKeys FilterKeys" }
    @{ C = "Z"; D = "Prioridade CPU jogos" }
    @{ C = "H"; D = "Core Parking, MSI Mode GPU, TDR Delay" }
    @{ C = "F"; D = "Limpeza profunda Temp Prefetch Recentes" }
    @{ C = "G"; D = "Desfragmentar disco HD" }
    @{ C = "A"; D = "Liberar memoria RAM agora" }
    @{ C = "B"; D = "Corrigir aceleracao do mouse" }
    @{ C = "C"; D = "Fechar programas pesados" }
    @{ C = "D"; D = "Programas de inicializacao pasta e registro" }
    @{ C = "DU"; D = "Desinstalar programa aplicativo app" }
    @{ C = "HB"; D = "Hibernacao desligar espaco em disco" }
    @{ C = "BG"; D = "Apps segundo plano Microsoft Store" }
    @{ C = "SA"; D = "Sugestoes anuncios menu Iniciar" }
    @{ C = "E"; D = "Guia placa de video NVIDIA AMD" }
    @{ C = "O"; D = "Guia BIOS UEFI XMP Resizable BAR" }
    @{ C = "DG"; D = "Diagnosticos extras: RAM channel, overlay, VBS, VPN, WiFi, gamepad, notebook, drivers desatualizados" }
    @{ C = "FR"; D = "Ferramentas: status geral, score, antes/depois, desfazer tudo" }
  )
  $termo = Read-Host "Digite uma palavra-chave (ex: mouse, rede, RAM, limpeza)"
  Write-Host ""
  $achados = @($indice | Where-Object { $_.D -match [regex]::Escape($termo) -or $_.C -eq $termo.ToUpper() })
  if ($achados.Count -eq 0) {
    Write-Host "Nada encontrado pra '$termo'."
    return
  }
  Write-Host "Resultados:"
  foreach ($a in $achados) {
    Write-Host ("  {0,-4} {1}" -f $a.C, $a.D)
  }
}

function Show-Menu {
  while ($true) {
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  OTIMIZADOR PRO" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  SEGURANCA" -ForegroundColor Yellow
    Write-Host "  0R Criar ponto de restauracao do Windows (recomendado fazer primeiro)"
    Write-Host ""
    Write-Host "  DIAGNOSTICO (nao muda nada)" -ForegroundColor Yellow
    Write-Host "  1  Ver RAM, discos (HD/SSD) e onde estao seus jogos"
    Write-Host "  2  Detectar jogos instalados (Steam/Epic)"
    Write-Host "  I  Verificar arquivo de paginacao (memoria virtual)"
    Write-Host ""
    Write-Host "  SISTEMA" -ForegroundColor Yellow
    Write-Host "  3  Exclusoes no Windows Defender pros jogos detectados"
    Write-Host "  4  Exclusoes na indexacao do Windows Search"
    Write-Host "  5  Plano de energia: Desempenho maximo"
    Write-Host "  6  Ajustes gerais (Game Mode, Game Bar, efeitos visuais)"
    Write-Host "  7  Prioridade de CPU/GPU pra jogos (MMCSS)"
    Write-Host "  8  Rede: menos latencia (Nagle, energia da placa, NetworkThrottling, LSO)"
    Write-Host "  9  HAGS - Agendamento de GPU por hardware (LIGAR)"
    Write-Host "  J  DNS mais rapido (Cloudflare)"
    Write-Host "  K  Desligar melhorias de audio (reduz delay/estalo)"
    Write-Host "  L  Manutencao de disco (TRIM no SSD)"
    Write-Host "  M  Desligar 'Otimizacoes de Tela Cheia' pra todos os jogos detectados"
    Write-Host "  N  Desligar telemetria do Windows (privacidade, fica fora do 'Rodar TUDO')" -ForegroundColor DarkGray
    Write-Host "  P  Verificar taxa de atualizacao do monitor (Hz)"
    Write-Host "  Q  Ligar limpeza automatica de disco (Assistente de Armazenamento)"
    Write-Host "  R  Desligar compartilhamento de banda do Windows Update (Delivery Optimization)"
    Write-Host ""
    Write-Host "  REDE / PING / LATENCIA" -ForegroundColor Yellow
    Write-Host "  PG Diagnostico de ping e latencia (nao muda nada -- roteador vs internet)"
    Write-Host "  GR Gerar guia de rede (dicas de QoS/Wi-Fi/roteador que nao dao pra automatizar)"
    Write-Host "  IM Interrupt Moderation da placa de rede (menos latencia, mais uso de CPU)"
    Write-Host "  NR Reparar rede (reset Winsock/TCP-IP -- so use se a internet estiver com problema)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  REGISTRO AVANCADO (input/desempenho -- mostra status e deixa cancelar)" -ForegroundColor Yellow
    Write-Host "  S  Mouse 1:1 fisico + curva X/Y uniforme (sem aceleracao)"
    Write-Host "  U  Desligar Suspensao Seletiva de USB (menos atraso no mouse/teclado)"
    Write-Host "  V  Timer do kernel de alta precisao (bcdedit -- precisa reiniciar)"
    Write-Host "  W  Aumentar fila de eventos de mouse/teclado (precisa reiniciar)"
    Write-Host "  X  Manter kernel/drivers sempre na RAM -- ISLC (precisa 8GB+ RAM, reiniciar)"
    Write-Host "  Y  Bloquear atalhos StickyKeys/ToggleKeys/FilterKeys (popup sem querer no jogo)"
    Write-Host "  Z  Prioridade de CPU em 1o plano + prioridade dos executaveis de jogo"
    Write-Host "  H  CPU/GPU Avancado (Core Parking, MSI Mode, TDR Delay -- submenu)"
    Write-Host "  HB Desligar Hibernacao (libera espaco em disco do tamanho da sua RAM)"
    Write-Host "  BG Bloquear apps da Microsoft Store de rodar em segundo plano"
    Write-Host "  SA Desligar sugestoes/anuncios do menu Iniciar"
    Write-Host ""
    Write-Host "  LIMPEZA" -ForegroundColor Yellow
    Write-Host "  F  Limpeza profunda (Temp, Prefetch, Recentes, cache do Update/shader, Lixeira)"
    Write-Host "  G  Desfragmentar disco (HD mecanico -- pode demorar, por isso fica de fora do T)"
    Write-Host ""
    Write-Host "  MANUTENCAO" -ForegroundColor Yellow
    Write-Host "  A  Liberar memoria RAM agora (pede pros programas devolverem o que nao usam)"
    Write-Host "  B  Corrigir aceleracao do mouse"
    Write-Host "  C  Ver/fechar programas pesados rodando agora"
    Write-Host "  D  Ver/desativar programas de inicializacao (pasta E registro, com reativar)"
    Write-Host "  DU Desinstalar um programa (classico ou app da Microsoft Store)" -ForegroundColor DarkGray
    Write-Host "  E  Gerar guia de configuracao da placa de video"
    Write-Host "  O  Gerar guia de BIOS/UEFI (RAM, Resizable BAR, Secure Boot, etc)"
    Write-Host ""
    Write-Host "  MAIS" -ForegroundColor Yellow
    Write-Host "  DG Diagnosticos extras (RAM channel, overlay, VBS, VPN, Wi-Fi, gamepad...)"
    Write-Host "  FR Ferramentas e relatorios (status geral, score, antes/depois, desfazer tudo)"
    Write-Host "  BU Buscar por palavra-chave"
    Write-Host ""
    Write-Host "  T  Rodar TUDO que e automatico e seguro (recomendado)" -ForegroundColor Green
    Write-Host ""
    Write-Host "  0  Sair"
    Write-Host ""
    $c = (Read-Host "Escolha").Trim().ToUpper()

    try {
      switch ($c) {
        "0R" { & (Join-Path $dir "_restore_point.ps1") }
        "1" { & (Join-Path $dir "_diagnostico.ps1") }
        "2" { . (Join-Path $dir "_detect_games.ps1"); (Get-AllDetectedGames) | Format-Table -AutoSize }
        "I" { & (Join-Path $dir "_pagefile_check.ps1") }
        "3" { & (Join-Path $dir "_defender_exclusions.ps1") }
        "4" { & (Join-Path $dir "_indexing_exclusion.ps1") }
        "5" { & (Join-Path $dir "_power_plan.ps1") }
        "6" { & (Join-Path $dir "_windows_tweaks.ps1") }
        "7" { & (Join-Path $dir "_gaming_priority.ps1") }
        "8" { & (Join-Path $dir "_network_tweaks.ps1") }
        "9" { & (Join-Path $dir "_hags.ps1") -Action On }
        "J" { & (Join-Path $dir "_dns_optimizer.ps1") -Provedor "Cloudflare" }
        "K" { & (Join-Path $dir "_audio_tweaks.ps1") }
        "L" { & (Join-Path $dir "_disk_maintenance.ps1") }
        "M" { & (Join-Path $dir "_fullscreen_opt.ps1") }
        "N" { & (Join-Path $dir "_telemetry.ps1") }
        "P" { & (Join-Path $dir "_monitor_refresh.ps1") }
        "Q" { & (Join-Path $dir "_storage_sense.ps1") }
        "R" { & (Join-Path $dir "_delivery_optimization.ps1") -Action "Off" }
        "PG" { & (Join-Path $dir "_ping_diagnostico.ps1") }
        "GR" { & (Join-Path $dir "_guia_rede.ps1") }
        "IM" { Invoke-RegToggle "Interrupt Moderation" "_net_interrupt_moderation.ps1" }
        "NR" {
          Write-Host "Isso reseta o Winsock e a pilha TCP/IP do Windows -- so use se a internet"
          Write-Host "estiver com comportamento estranho. Precisa reiniciar o PC depois."
          $r = Read-Host "Confirma? (S para sim, Enter pra cancelar)"
          if ($r -match "^[Ss]") { & (Join-Path $dir "_net_repair.ps1") }
          else { Write-Output "Cancelado, nada alterado." }
        }
        "S" { Invoke-RegToggle "Mouse 1:1" "_mouse_fix.ps1" }
        "U" { Invoke-RegToggle "USB Selective Suspend" "_reg_usb_suspend.ps1" }
        "V" { Invoke-RegToggle "Timer do kernel" "_reg_kernel_timer.ps1" }
        "W" { Invoke-RegToggle "Fila de mouse/teclado" "_reg_mouse_queue.ps1" }
        "X" { Invoke-RegToggle "ISLC (kernel na RAM)" "_reg_islc.ps1" }
        "Y" { Invoke-RegToggle "Bloqueio de atalhos de acessibilidade" "_reg_accessibility.ps1" }
        "Z" { Invoke-RegToggle "Prioridade de CPU" "_reg_priority_boost.ps1" }
        "H" { Show-CpuGpuMenu; continue }
        "HB" { Invoke-RegToggle "Hibernacao desligada" "_reg_hibernacao.ps1" }
        "BG" { Invoke-RegToggle "Apps em segundo plano bloqueados" "_reg_background_apps.ps1" }
        "SA" { Invoke-RegToggle "Sugestoes do menu Iniciar desligadas" "_reg_start_ads.ps1" }
        "F" { & (Join-Path $dir "_limpeza_profunda.ps1") }
        "G" { & (Join-Path $dir "_disk_defrag.ps1") }
        "A" { & (Join-Path $dir "_ram_trim.ps1") }
        "B" { & (Join-Path $dir "_mouse_fix.ps1") }
        "C" { & (Join-Path $dir "_process_audit.ps1") }
        "D" { & (Join-Path $dir "_startup_audit.ps1") }
        "DU" {
          Write-Host "Isso vai listar TODOS os programas instalados na sua maquina."
          Write-Host "Desinstalar nao tem 'desfazer' -- confirme com cuidado."
          & (Join-Path $dir "_desinstalador.ps1")
        }
        "E" { & (Join-Path $dir "_driver_guide.ps1") }
        "O" { & (Join-Path $dir "_bios_guide.ps1") }
        "DG" { Show-DiagExtraMenu; continue }
        "FR" { Show-FerramentasMenu; continue }
        "BU" { Show-Busca }
        "T" {
          & (Join-Path $dir "_restore_point.ps1"); Write-Host ""
          & (Join-Path $dir "_diagnostico.ps1"); Write-Host ""
          & (Join-Path $dir "_defender_exclusions.ps1"); Write-Host ""
          & (Join-Path $dir "_indexing_exclusion.ps1"); Write-Host ""
          & (Join-Path $dir "_power_plan.ps1"); Write-Host ""
          & (Join-Path $dir "_windows_tweaks.ps1"); Write-Host ""
          & (Join-Path $dir "_gaming_priority.ps1"); Write-Host ""
          & (Join-Path $dir "_network_tweaks.ps1"); Write-Host ""
          & (Join-Path $dir "_delivery_optimization.ps1") -Action "Off"; Write-Host ""
          & (Join-Path $dir "_storage_sense.ps1"); Write-Host ""
          & (Join-Path $dir "_monitor_refresh.ps1"); Write-Host ""
          & (Join-Path $dir "_audio_tweaks.ps1"); Write-Host ""
          & (Join-Path $dir "_disk_maintenance.ps1"); Write-Host ""
          & (Join-Path $dir "_fullscreen_opt.ps1"); Write-Host ""
          & (Join-Path $dir "_pagefile_check.ps1"); Write-Host ""
          & (Join-Path $dir "_limpeza_profunda.ps1"); Write-Host ""
          & (Join-Path $dir "_ram_trim.ps1"); Write-Host ""
          & (Join-Path $dir "_mouse_fix.ps1"); Write-Host ""
          & (Join-Path $dir "_driver_guide.ps1"); Write-Host ""
          & (Join-Path $dir "_bios_guide.ps1"); Write-Host ""
          & (Join-Path $dir "_ping_diagnostico.ps1"); Write-Host ""
          & (Join-Path $dir "_guia_rede.ps1"); Write-Host ""
          & (Join-Path $dir "_diag_ram_channel.ps1"); Write-Host ""
          & (Join-Path $dir "_diag_overlays.ps1"); Write-Host ""
          & (Join-Path $dir "_diag_gpu_driver.ps1"); Write-Host ""
          & (Join-Path $dir "_diag_vbs.ps1"); Write-Host ""
          & (Join-Path $dir "_diag_onedrive.ps1"); Write-Host ""
          & (Join-Path $dir "_diag_cpu_throttle.ps1"); Write-Host ""
          & (Join-Path $dir "_diag_antivirus.ps1"); Write-Host ""
          & (Join-Path $dir "_diag_gamepad.ps1"); Write-Host ""
          & (Join-Path $dir "_diag_hybrid_gpu.ps1"); Write-Host ""
          & (Join-Path $dir "_diag_multi_monitor.ps1"); Write-Host ""
          & (Join-Path $dir "_perfil_notebook.ps1"); Write-Host ""
          & (Join-Path $dir "_diag_vpn.ps1"); Write-Host ""
          & (Join-Path $dir "_diag_wifi.ps1"); Write-Host ""
          & (Join-Path $dir "_diag_fast_startup.ps1"); Write-Host ""
          & (Join-Path $dir "_diag_drivers.ps1"); Write-Host ""
          & (Join-Path $dir "_relatorio_status.ps1"); Write-Host ""
          & (Join-Path $dir "_score_saude.ps1")
          Write-Host ""
          Write-Host "NAO incluido no 'Rodar TUDO' de proposito (precisam de voce escolher):" -ForegroundColor Yellow
          Write-Host "  9 (HAGS -- teste e veja se melhora ou piora no seu jogo)"
          Write-Host "  J (DNS -- so se voce quiser trocar o servidor DNS)"
          Write-Host "  N (telemetria -- questao de privacidade, nao so desempenho)"
          Write-Host "  C/D (fechar programas / desativar inicializacao -- risco de fechar algo que voce precisa)"
          Write-Host "  G (desfragmentar disco -- pode demorar bastante, roda so quando voce escolher)"
          Write-Host "  H (CPU/GPU Avancado -- submenu com confirmacao)"
          Write-Host "  IM (Interrupt Moderation -- aumenta uso de CPU, sua escolha)"
          Write-Host "  NR (reparar rede -- so use se a internet estiver com problema de verdade)"
          Write-Host "  S/U/V/W/X/Y/Z/HB/BG/SA (Registro Avancado -- mostram status e pedem confirmacao, por isso ficam de fora do automatico)"
          Write-Host "  FR (ferramentas -- 'Desfazer tudo' e 'Antes/Depois' sao pra voce rodar na hora certa, nao automatico)"
          Write-Host "  DU (desinstalar programa -- nunca automatico, e a acao mais irreversivel do menu)"
        }
        "0" { Stop-Transcript | Out-Null; return }
        default { continue }
      }
    } catch {
      Write-Host ""
      Write-Host "ERRO: $_" -ForegroundColor Red
    }

    if ($c -ne "0" -and $c -ne "H" -and $c -ne "DG" -and $c -ne "FR") {
      Write-Host ""
      Read-Host "Enter para voltar ao menu"
    }
  }
}

Show-Menu
