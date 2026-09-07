# Constroi o conteudo da aba "Ajustes" -- lista de checkboxes agrupados
# por categoria, cada um ligado a um script .ps1 ja testado no menu de
# texto. Nao reimplementa nenhuma logica de otimizacao aqui -- so chama
# os mesmos scripts, igual o menu de texto faz.

# Cada item: Nome (rotulo), Script (arquivo em scripts\), Categoria,
# Conv = convencao de parametro do script:
#   "toggle"  -> -Action Aplicar/Reverter/Status
#   "onoff"   -> -Action On/Off/Status (so o _hags.ps1)
#   "direto"  -> sem -Action, roda uma vez, sem status/reverter formal
$Global:ListaAjustes = @(
  # --- Sistema ---
  @{ Nome = "Exclusoes no Windows Defender pros jogos"; Script = "_defender_exclusions.ps1"; Cat = "Sistema"; Conv = "direto" }
  @{ Nome = "Exclusoes na indexacao do Windows Search"; Script = "_indexing_exclusion.ps1"; Cat = "Sistema"; Conv = "direto" }
  @{ Nome = "Plano de energia: Desempenho Maximo"; Script = "_power_plan.ps1"; Cat = "Sistema"; Conv = "direto" }
  @{ Nome = "Game Mode, Game Bar, efeitos visuais"; Script = "_windows_tweaks.ps1"; Cat = "Sistema"; Conv = "direto" }
  @{ Nome = "Prioridade de CPU/GPU pra jogos (MMCSS)"; Script = "_gaming_priority.ps1"; Cat = "Sistema"; Conv = "direto" }
  @{ Nome = "Rede: Nagle, NetworkThrottling, LSO"; Script = "_network_tweaks.ps1"; Cat = "Sistema"; Conv = "direto" }
  @{ Nome = "Desligar melhorias de audio"; Script = "_audio_tweaks.ps1"; Cat = "Sistema"; Conv = "direto" }
  @{ Nome = "Manutencao de disco (TRIM no SSD)"; Script = "_disk_maintenance.ps1"; Cat = "Sistema"; Conv = "direto" }
  @{ Nome = "Otimizacoes de Tela Cheia desligadas"; Script = "_fullscreen_opt.ps1"; Cat = "Sistema"; Conv = "direto" }
  @{ Nome = "Storage Sense (limpeza automatica)"; Script = "_storage_sense.ps1"; Cat = "Sistema"; Conv = "direto" }
  @{ Nome = "Telemetria do Windows desligada"; Script = "_telemetry.ps1"; Cat = "Sistema"; Conv = "direto" }
  @{ Nome = "Delivery Optimization desligado"; Script = "_delivery_optimization.ps1"; Cat = "Sistema"; Conv = "onoffdireto" }
  @{ Nome = "HAGS (agendamento de GPU) ligado"; Script = "_hags.ps1"; Cat = "Sistema"; Conv = "onoff" }

  # --- Limpeza ---
  @{ Nome = "Limpeza profunda (Temp, Prefetch, shader, Lixeira)"; Script = "_limpeza_profunda.ps1"; Cat = "Limpeza"; Conv = "direto" }
  @{ Nome = "Liberar memoria RAM agora"; Script = "_ram_trim.ps1"; Cat = "Limpeza"; Conv = "direto" }

  # --- Registro Avancado (tem Aplicar/Reverter/Status de verdade) ---
  @{ Nome = "Mouse 1:1 fisico (sem aceleracao)"; Script = "_mouse_fix.ps1"; Cat = "Registro Avancado"; Conv = "toggle" }
  @{ Nome = "USB Selective Suspend desligado"; Script = "_reg_usb_suspend.ps1"; Cat = "Registro Avancado"; Conv = "toggle" }
  @{ Nome = "Timer do kernel de alta precisao"; Script = "_reg_kernel_timer.ps1"; Cat = "Registro Avancado"; Conv = "toggle" }
  @{ Nome = "Fila de mouse/teclado maior"; Script = "_reg_mouse_queue.ps1"; Cat = "Registro Avancado"; Conv = "toggle" }
  @{ Nome = "ISLC -- kernel/drivers sempre na RAM"; Script = "_reg_islc.ps1"; Cat = "Registro Avancado"; Conv = "toggle" }
  @{ Nome = "Bloquear atalhos de acessibilidade"; Script = "_reg_accessibility.ps1"; Cat = "Registro Avancado"; Conv = "toggle" }
  @{ Nome = "Prioridade de CPU em 1o plano"; Script = "_reg_priority_boost.ps1"; Cat = "Registro Avancado"; Conv = "toggle" }
  @{ Nome = "Core Parking desligado"; Script = "_core_parking.ps1"; Cat = "Registro Avancado"; Conv = "toggle" }
  @{ Nome = "MSI Mode da GPU"; Script = "_gpu_msi_mode.ps1"; Cat = "Registro Avancado"; Conv = "toggle" }
  @{ Nome = "TDR Delay maior"; Script = "_gpu_tdr_delay.ps1"; Cat = "Registro Avancado"; Conv = "toggle" }
  @{ Nome = "Interrupt Moderation da placa de rede"; Script = "_net_interrupt_moderation.ps1"; Cat = "Registro Avancado"; Conv = "toggle" }
  @{ Nome = "Hibernacao desligada"; Script = "_reg_hibernacao.ps1"; Cat = "Registro Avancado"; Conv = "toggle" }
  @{ Nome = "Apps da Microsoft Store em 2o plano bloqueados"; Script = "_reg_background_apps.ps1"; Cat = "Registro Avancado"; Conv = "toggle" }
  @{ Nome = "Sugestoes/anuncios do menu Iniciar desligados"; Script = "_reg_start_ads.ps1"; Cat = "Registro Avancado"; Conv = "toggle" }
  @{ Nome = "Windows Search pausado por completo"; Script = "_search_pause.ps1"; Cat = "Registro Avancado"; Conv = "toggle" }
)

# Funcao de nivel de modulo (nao aninhada dentro de Build-AjustesTab) --
# assim nenhum closure de botao depende do escopo de Build-AjustesTab
# ainda estar "vivo" no momento em que o clique acontece.
function Get-StatusItemAjuste($scriptsDir, $item) {
  $caminho = Join-Path $scriptsDir $item.Script
  try {
    switch ($item.Conv) {
      "toggle" { return ((& $caminho -Action Status 2>&1 | Select-Object -First 1) -match "^LIGADO") }
      "onoff"  { return (((& $caminho -Action Status 2>&1) -join " ") -match "Ligado") }
      default  { return $null }
    }
  } catch { return $null }
}

function Build-AjustesTab {
  param($window, $scriptsDir, $setStatus)

  $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"

  $raiz = New-Object System.Windows.Controls.DockPanel

  $barra = New-Object System.Windows.Controls.StackPanel
  $barra.Orientation = "Horizontal"
  $barra.Margin = "0,0,0,14"
  [System.Windows.Controls.DockPanel]::SetDock($barra, "Top")

  $btnStatus = New-Object System.Windows.Controls.Button
  $btnStatus.Name = "BtnAjustesStatus"
  $btnStatus.Content = "Marcar conforme sistema atual"
  $btnStatus.Style = $window.FindResource("BtnGhost")
  $btnStatus.Margin = "0,0,10,0"

  $btnAplicar = New-Object System.Windows.Controls.Button
  $btnAplicar.Name = "BtnAjustesAplicar"
  $btnAplicar.Content = "Aplicar selecionados"
  $btnAplicar.Style = $window.FindResource("BtnPrimary")
  $btnAplicar.Margin = "0,0,10,0"

  $btnReverter = New-Object System.Windows.Controls.Button
  $btnReverter.Name = "BtnAjustesReverter"
  $btnReverter.Content = "Reverter selecionados"
  $btnReverter.Style = $window.FindResource("BtnGhost")

  $barra.Children.Add($btnStatus) | Out-Null
  $barra.Children.Add($btnAplicar) | Out-Null
  $barra.Children.Add($btnReverter) | Out-Null
  $raiz.Children.Add($barra) | Out-Null

  $scroll = New-Object System.Windows.Controls.ScrollViewer
  $painelCategorias = New-Object System.Windows.Controls.StackPanel
  $scroll.Content = $painelCategorias

  $checkboxesPorItem = @{}
  $categorias = $Global:ListaAjustes.Cat | Select-Object -Unique
  foreach ($cat in $categorias) {
    $tituloCat = New-Object System.Windows.Controls.TextBlock
    $tituloCat.Text = $cat.ToUpper()
    $tituloCat.Style = $window.FindResource("Rotulo")
    $tituloCat.Margin = "2,14,0,6"
    $painelCategorias.Children.Add($tituloCat) | Out-Null

    $grade = New-Object System.Windows.Controls.WrapPanel
    foreach ($item in ($Global:ListaAjustes | Where-Object { $_.Cat -eq $cat })) {
      $cb = New-Object System.Windows.Controls.CheckBox
      $cb.Content = $item.Nome
      $cb.Width = 380
      $cb.Margin = "2,4,10,4"
      $cb.Tag = $item
      $checkboxesPorItem[$item.Nome] = $cb
      $grade.Children.Add($cb) | Out-Null
    }
    $painelCategorias.Children.Add($grade) | Out-Null
  }
  $raiz.Children.Add($scroll) | Out-Null

  $btnStatus.Add_Click({
    try {
      $setStatus.Invoke("Lendo status atual de cada item...") | Out-Null
      foreach ($nome in @($checkboxesPorItem.Keys)) {
        $cb = $checkboxesPorItem[$nome]
        $item = $cb.Tag
        if ($item.Conv -eq "toggle" -or $item.Conv -eq "onoff") {
          $ligado = Get-StatusItemAjuste $scriptsDir $item
          if ($null -ne $ligado) { $cb.IsChecked = [bool]$ligado }
        }
      }
      $setStatus.Invoke("Status atualizado.") | Out-Null
    } catch {
      "ERRO no BtnStatus: $_`n$($_.ScriptStackTrace)" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao ler status -- veja o log.") | Out-Null
    }
  }.GetNewClosure())

  $btnAplicar.Add_Click({
    try {
      $marcados = @($checkboxesPorItem.Values | Where-Object { $_.IsChecked -eq $true })
      if ($marcados.Count -eq 0) { $setStatus.Invoke("Nenhum item marcado.") | Out-Null; return }
      $setStatus.Invoke("Aplicando $($marcados.Count) item(ns)...") | Out-Null
      foreach ($cb in $marcados) {
        $item = $cb.Tag
        $caminho = Join-Path $scriptsDir $item.Script
        try {
          switch ($item.Conv) {
            "toggle"       { & $caminho -Action Aplicar 2>&1 | Out-Null }
            "onoff"        { & $caminho -Action On 2>&1 | Out-Null }
            "onoffdireto"  { & $caminho -Action Off 2>&1 | Out-Null }
            default        { & $caminho 2>&1 | Out-Null }
          }
        } catch {}
      }
      $setStatus.Invoke("Pronto: $($marcados.Count) item(ns) aplicado(s).") | Out-Null
    } catch {
      "ERRO no BtnAplicar: $_`n$($_.ScriptStackTrace)" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao aplicar -- veja o log.") | Out-Null
    }
  }.GetNewClosure())

  $btnReverter.Add_Click({
    try {
      $marcados = @($checkboxesPorItem.Values | Where-Object { $_.IsChecked -eq $true })
      if ($marcados.Count -eq 0) { $setStatus.Invoke("Nenhum item marcado.") | Out-Null; return }
      $comReverter = @($marcados | Where-Object { $_.Tag.Conv -eq "toggle" -or $_.Tag.Conv -eq "onoff" })
      $setStatus.Invoke("Revertendo $($comReverter.Count) item(ns)...") | Out-Null
      foreach ($cb in $comReverter) {
        $item = $cb.Tag
        $caminho = Join-Path $scriptsDir $item.Script
        try {
          if ($item.Conv -eq "toggle") { & $caminho -Action Reverter 2>&1 | Out-Null }
          else { & $caminho -Action Off 2>&1 | Out-Null }
        } catch {}
      }
      $setStatus.Invoke("Pronto: $($comReverter.Count) item(ns) revertido(s).") | Out-Null
    } catch {
      "ERRO no BtnReverter: $_`n$($_.ScriptStackTrace)" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao reverter -- veja o log.") | Out-Null
    }
  }.GetNewClosure())

  return $raiz
}
