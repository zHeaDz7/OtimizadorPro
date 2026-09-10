# Constroi o conteudo da aba "Ajustes" -- lista de itens agrupados por
# categoria, cada um ligado a um script .ps1 ja testado no menu de texto.
# Nao reimplementa nenhuma logica de otimizacao aqui -- so chama os
# mesmos scripts, igual o menu de texto faz. Cada item mostra o que
# melhora e o que pode piorar, pra pessoa saber exatamente o que esta
# marcando antes de clicar em Aplicar.

# Cada item: Nome (rotulo), Script (arquivo em scripts\), Categoria,
# Melhora (o que fica melhor), Contras (o que pode piorar/trade-off),
# Conv = convencao de parametro do script:
#   "toggle"  -> -Action Aplicar/Reverter/Status
#   "onoff"   -> -Action On/Off/Status (so o _hags.ps1)
#   "direto"  -> sem -Action, roda uma vez, sem status/reverter formal
$Global:ListaAjustes = @(
  # --- Sistema ---
  @{ Nome = "Exclusões no Windows Defender pros jogos"; Script = "_defender_exclusions.ps1"; Cat = "Sistema"; Conv = "direto"
     Melhora = "Menos verificação em tempo real nas pastas de jogos -- carregamento mais rápido."
     Contras = "Essas pastas ficam sem proteção antivírus. Só use em pastas de jogo confiáveis." }
  @{ Nome = "Exclusões na indexação do Windows Search"; Script = "_indexing_exclusion.ps1"; Cat = "Sistema"; Conv = "direto"
     Melhora = "Menos uso de disco/CPU em segundo plano indexando pastas de jogos."
     Contras = "Buscar arquivo dentro dessas pastas pelo Windows Search fica mais lento." }
  @{ Nome = "Plano de energia: Desempenho Máximo"; Script = "_power_plan.ps1"; Cat = "Sistema"; Conv = "direto"
     Melhora = "CPU nunca reduz frequência pra economizar energia -- desempenho consistente."
     Contras = "Mais consumo de energia e calor. Notebook na bateria dura menos." }
  @{ Nome = "Game Mode, Game Bar, efeitos visuais"; Script = "_windows_tweaks.ps1"; Cat = "Sistema"; Conv = "direto"
     Melhora = "Windows prioriza o jogo em primeiro plano, menos interrupção de outros processos."
     Contras = "Nenhum efeito colateral conhecido." }
  @{ Nome = "Prioridade de CPU/GPU pra jogos (MMCSS)"; Script = "_gaming_priority.ps1"; Cat = "Sistema"; Conv = "direto"
     Melhora = "Jogo recebe fatia maior de CPU/GPU quando várias coisas rodam ao mesmo tempo."
     Contras = "Outros programas em segundo plano podem ficar mais lentos enquanto o jogo roda." }
  @{ Nome = "Desligar melhorias de áudio"; Script = "_audio_tweaks.ps1"; Cat = "Sistema"; Conv = "direto"
     Melhora = "Remove processamento extra de efeitos sonoros -- reduz microlatência de áudio."
     Contras = "Perde efeitos como equalização automática, se você gostava deles." }
  @{ Nome = "Manutenção de disco (TRIM no SSD)"; Script = "_disk_maintenance.ps1"; Cat = "Sistema"; Conv = "direto"
     Melhora = "SSD mantém a velocidade de escrita ao longo do tempo."
     Contras = "Nenhum -- é manutenção recomendada pela própria Microsoft." }
  @{ Nome = "Otimizações de Tela Cheia desligadas"; Script = "_fullscreen_opt.ps1"; Cat = "Sistema"; Conv = "direto"
     Melhora = "Reduz input lag e telas pretas em alguns jogos mais antigos."
     Contras = "Pode alterar o comportamento do Alt+Tab em alguns jogos específicos." }
  @{ Nome = "Storage Sense (limpeza automática)"; Script = "_storage_sense.ps1"; Cat = "Sistema"; Conv = "direto"
     Melhora = "Windows limpa temporários e Lixeira sozinho de tempos em tempos -- libera espaço."
     Contras = "Arquivos na Lixeira somem automaticamente depois de alguns dias." }
  @{ Nome = "Telemetria do Windows desligada"; Script = "_telemetry.ps1"; Cat = "Sistema"; Conv = "direto"
     Melhora = "Menos dado enviado pra Microsoft em segundo plano -- leve alívio de rede/CPU."
     Contras = "Nenhum efeito percebido no uso do dia a dia." }
  @{ Nome = "Delivery Optimization desligado"; Script = "_delivery_optimization.ps1"; Cat = "Sistema"; Conv = "onoffdireto"
     Melhora = "Para de usar sua internet/upload pra distribuir atualização do Windows pra outros PCs."
     Contras = "Você continua recebendo atualização normal -- só não ajuda a distribuir pra terceiros." }
  @{ Nome = "HAGS (agendamento de GPU) ligado"; Script = "_hags.ps1"; Cat = "Sistema"; Conv = "onoff"
     Melhora = "Pode reduzir latência em alguns jogos e placas de vídeo mais novas."
     Contras = "Em combinação com driver mais antigo, pode causar instabilidade -- reverta se notar problema." }

  # --- Rede ---
  @{ Nome = "Rede: Nagle, NetworkThrottling, LSO"; Script = "_network_tweaks.ps1"; Cat = "Rede"; Conv = "direto"
     Melhora = "Reduz a latência de rede -- importante pra jogo online."
     Contras = "Reduz um pouco a eficiência em downloads grandes em massa." }
  @{ Nome = "Interrupt Moderation da placa de rede"; Script = "_net_interrupt_moderation.ps1"; Cat = "Rede"; Conv = "toggle"
     Melhora = "Reduz o atraso entre o pacote de rede chegar e o PC processar -- bom pra jogo competitivo."
     Contras = "Uso de CPU pode subir um pouco (mais interrupções por segundo)." }
  @{ Nome = "DNS otimizado (Cloudflare)"; Script = "_dns_optimizer.ps1"; Cat = "Rede"; Conv = "direto"
     Melhora = "Resolve nome de site/servidor mais rápido (entrar em servidor de jogo, carregar update)."
     Contras = "Não afeta o jogo depois de conectado -- só a velocidade de 'achar o endereço' muda." }

  # --- Interface ---
  @{ Nome = "Menu de contexto clássico (botão direito)"; Script = "_reg_menu_classico.ps1"; Cat = "Interface"; Conv = "toggle"
     Melhora = "Todas as opções do menu aparecem na hora, sem clicar em 'Mostrar mais opções'."
     Contras = "Reinicia o Explorer -- a tela pisca um instante." }
  @{ Nome = "Widgets desativados na barra de tarefas"; Script = "_reg_widgets.ps1"; Cat = "Interface"; Conv = "toggle"
     Melhora = "Barra de tarefas mais limpa, uma coisa a menos pra abrir sem querer."
     Contras = "Reinicia o Explorer -- a tela pisca um instante." }
  @{ Nome = "Chat/Teams removido da barra de tarefas"; Script = "_reg_taskbar_chat.ps1"; Cat = "Interface"; Conv = "toggle"
     Melhora = "Barra de tarefas mais limpa."
     Contras = "Reinicia o Explorer -- a tela pisca um instante." }
  @{ Nome = "Efeitos de transparência desligados"; Script = "_reg_transparencia.ps1"; Cat = "Interface"; Conv = "toggle"
     Melhora = "Leve alívio pra placa de vídeo em PC mais fraco."
     Contras = "Interface fica com aparência mais 'chapada', sem efeito de vidro." }
  @{ Nome = "Barra de tarefas alinhada à esquerda"; Script = "_reg_taskbar_esquerda.ps1"; Cat = "Interface"; Conv = "toggle"
     Melhora = "Preferência visual, estilo Windows 10."
     Contras = "Nenhum -- é só estética." }
  @{ Nome = "Animações de janela reduzidas"; Script = "_reg_animacoes.ps1"; Cat = "Interface"; Conv = "toggle"
     Melhora = "Sensação de resposta mais imediata ao abrir/minimizar/fechar janelas."
     Contras = "Transições ficam mais secas -- pode estranhar no começo." }

  # --- Privacidade ---
  @{ Nome = "Cortana desativada"; Script = "_reg_cortana.ps1"; Cat = "Privacidade"; Conv = "toggle"
     Melhora = "Um processo a menos rodando em segundo plano."
     Contras = "Se você usava comando de voz da Cortana, para de funcionar." }
  @{ Nome = "ID de publicidade desligado"; Script = "_reg_advertising_id.ps1"; Cat = "Privacidade"; Conv = "toggle"
     Melhora = "Apps param de te rastrear pra anúncio 'personalizado'."
     Contras = "Os anúncios continuam aparecendo, só ficam menos direcionados." }
  @{ Nome = "Histórico de Atividades (Timeline) desligado"; Script = "_reg_activity_history.ps1"; Cat = "Privacidade"; Conv = "toggle"
     Melhora = "Windows para de guardar registro do que você abre pra sincronizar entre PCs."
     Contras = "Perde o recurso de 'continuar de onde parou' em outro PC com a mesma conta." }
  @{ Nome = "Sincronização da área de transferência (nuvem) desligada"; Script = "_reg_clipboard_cloud.ps1"; Cat = "Privacidade"; Conv = "toggle"
     Melhora = "O que você copia não é mais enviado pra conta Microsoft na nuvem."
     Contras = "Copiar em um PC e colar em outro PC seu para de funcionar." }

  # --- Limpeza ---
  @{ Nome = "Limpeza profunda (Temp, Prefetch, shader, Lixeira)"; Script = "_limpeza_profunda.ps1"; Cat = "Limpeza"; Conv = "direto"
     Melhora = "Libera espaço em disco, remove lixo acumulado."
     Contras = "Cache de shader dos jogos é reconstruído -- primeiros minutos após limpar podem ter engasgo." }
  @{ Nome = "Liberar memória RAM agora"; Script = "_ram_trim.ps1"; Cat = "Limpeza"; Conv = "direto"
     Melhora = "Libera RAM presa por programas que não devolveram sozinhos."
     Contras = "Efeito temporário -- a RAM enche de novo com o uso normal." }
  @{ Nome = "Desfragmentação de HD mecânico"; Script = "_disk_defrag.ps1"; Cat = "Limpeza"; Conv = "direto"
     Melhora = "HD mecânico fica mais rápido pra ler arquivo fragmentado."
     Contras = "Pode demorar bastante dependendo do tamanho/fragmentação. Detecta e pula SSD sozinho." }

  # --- Registro Avançado (tem Aplicar/Reverter/Status de verdade) ---
  @{ Nome = "Mouse 1:1 físico (sem aceleração)"; Script = "_mouse_fix.ps1"; Cat = "Registro Avançado"; Conv = "toggle"
     Melhora = "Mouse responde exatamente ao movimento da mão, sem 'aceleração' que atrapalha mira."
     Contras = "Se você gostava da aceleração pra navegar rápido no desktop, vai sentir diferença." }
  @{ Nome = "USB Selective Suspend desligado"; Script = "_reg_usb_suspend.ps1"; Cat = "Registro Avançado"; Conv = "toggle"
     Melhora = "Mouse/teclado nunca 'dormem' -- zero microatraso ao voltar a mexer."
     Contras = "Consumo de energia um pouco maior. Notebook na bateria dura menos." }
  @{ Nome = "Timer do kernel de alta precisão"; Script = "_reg_kernel_timer.ps1"; Cat = "Registro Avançado"; Conv = "toggle"
     Melhora = "Temporização mais precisa pro sistema -- pode reduzir stutter em alguns jogos."
     Contras = "Pode aumentar levemente o consumo de energia." }
  @{ Nome = "Fila de mouse/teclado maior"; Script = "_reg_mouse_queue.ps1"; Cat = "Registro Avançado"; Conv = "toggle"
     Melhora = "Menos chance de perder movimento/clique em pico de uso de CPU."
     Contras = "Nenhum efeito colateral conhecido." }
  @{ Nome = "ISLC -- kernel/drivers sempre na RAM"; Script = "_reg_islc.ps1"; Cat = "Registro Avançado"; Conv = "toggle"
     Melhora = "Evita que partes do kernel sejam paginadas pro disco -- resposta mais consistente."
     Contras = "Usa um pouco mais de RAM reservada." }
  @{ Nome = "Bloquear atalhos de acessibilidade"; Script = "_reg_accessibility.ps1"; Cat = "Registro Avançado"; Conv = "toggle"
     Melhora = "Evita ativar sem querer (ex: Teclas de Aderência apertando Shift 5x durante o jogo)."
     Contras = "Se você usa esses atalhos de verdade por necessidade, precisa reverter." }
  @{ Nome = "Prioridade de CPU em 1º plano"; Script = "_reg_priority_boost.ps1"; Cat = "Registro Avançado"; Conv = "toggle"
     Melhora = "O programa que você está usando ganha prioridade sobre os em segundo plano."
     Contras = "Nenhum efeito colateral conhecido." }
  @{ Nome = "Core Parking desligado"; Script = "_core_parking.ps1"; Cat = "Registro Avançado"; Conv = "toggle"
     Melhora = "Todos os núcleos de CPU ficam sempre disponíveis, sem esperar 'acordar' núcleo parado."
     Contras = "Mais consumo de energia. Notebook na bateria dura menos." }
  @{ Nome = "MSI Mode da GPU"; Script = "_gpu_msi_mode.ps1"; Cat = "Registro Avançado"; Conv = "toggle"
     Melhora = "Reduz latência de interrupção da placa de vídeo."
     Contras = "Nenhum efeito colateral conhecido -- recurso oficial do driver." }
  @{ Nome = "TDR Delay maior"; Script = "_gpu_tdr_delay.ps1"; Cat = "Registro Avançado"; Conv = "toggle"
     Melhora = "Evita 'tela preta e volta' (driver da GPU reiniciando) em cargas pesadas/overclock."
     Contras = "Se a GPU travar de verdade, o Windows demora mais pra perceber e recuperar." }
  @{ Nome = "Hibernação desligada"; Script = "_reg_hibernacao.ps1"; Cat = "Registro Avançado"; Conv = "toggle"
     Melhora = "Libera espaço em disco (arquivo hiberfil.sys)."
     Contras = "Perde a opção 'Hibernar' no menu de energia." }
  @{ Nome = "Apps da Microsoft Store em 2º plano bloqueados"; Script = "_reg_background_apps.ps1"; Cat = "Registro Avançado"; Conv = "toggle"
     Melhora = "Apps UWP param de gastar CPU/rede quando você não está usando."
     Contras = "Notificações desses apps podem chegar atrasadas." }
  @{ Nome = "Sugestões/anúncios do menu Iniciar desligados"; Script = "_reg_start_ads.ps1"; Cat = "Registro Avançado"; Conv = "toggle"
     Melhora = "Menu Iniciar/Configurações sem propaganda/apps sugeridos."
     Contras = "Nenhum efeito colateral conhecido." }
  @{ Nome = "Windows Search pausado por completo"; Script = "_search_pause.ps1"; Cat = "Registro Avançado"; Conv = "toggle"
     Melhora = "Zero uso de CPU/disco em segundo plano indexando arquivos."
     Contras = "Buscar arquivo pelo nome no Explorer/menu Iniciar fica bem mais lento." }
  @{ Nome = "Inicialização Rápida (Fast Startup) desligada"; Script = "_reg_fast_startup.ps1"; Cat = "Registro Avançado"; Conv = "toggle"
     Melhora = "Cada desligamento fica 100% completo -- bom pra dual-boot Linux ou após trocar driver/GPU."
     Contras = "Boot fica alguns segundos mais lento." }
  @{ Nome = "SysMain (Superfetch) desligado"; Script = "_reg_sysmain.ps1"; Cat = "Registro Avançado"; Conv = "toggle"
     Melhora = "Menos uso de CPU/disco em segundo plano pré-carregando programas -- ganho maior em SSD."
     Contras = "Em HD mecânico antigo, programas frequentes podem abrir um pouco mais devagar na primeira vez." }

  # --- Seguranca ---
  @{ Nome = "Criar Ponto de Restauração antes de aplicar"; Script = "_restore_point.ps1"; Cat = "Segurança"; Conv = "direto"
     Melhora = "Se algo não ficar do jeito esperado, dá pra voltar o Windows inteiro ao estado de antes."
     Contras = "Usa um pouco de espaço em disco pro ponto de restauração." }
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
  param($window, $scriptsDir, $setStatus, $emSegundoPlano)

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
      $cartao = New-Object System.Windows.Controls.Border
      $cartao.Width = 478
      $cartao.Padding = "12,10,12,10"
      $cartao.Margin = "0,0,14,14"
      $cartao.CornerRadius = 6
      $cartao.BorderBrush = $window.FindResource("BrushBorder")
      $cartao.BorderThickness = 1
      $cartao.Background = $window.FindResource("BrushSurface2")

      $painelCartao = New-Object System.Windows.Controls.StackPanel
      $cartao.Child = $painelCartao

      $cb = New-Object System.Windows.Controls.CheckBox
      $cb.Content = $item.Nome
      $cb.FontSize = 13.5
      $cb.Tag = $item
      $checkboxesPorItem[$item.Nome] = $cb
      $painelCartao.Children.Add($cb) | Out-Null

      $txtMelhora = New-Object System.Windows.Controls.TextBlock
      $txtMelhora.Text = "+ $($item.Melhora)"
      $txtMelhora.Foreground = $window.FindResource("BrushGood")
      $txtMelhora.FontSize = 11.5
      $txtMelhora.TextWrapping = "Wrap"
      $txtMelhora.Margin = "26,4,0,0"
      $painelCartao.Children.Add($txtMelhora) | Out-Null

      $txtContras = New-Object System.Windows.Controls.TextBlock
      $txtContras.Text = "- $($item.Contras)"
      $txtContras.Foreground = $window.FindResource("BrushMuted")
      $txtContras.FontSize = 11.5
      $txtContras.TextWrapping = "Wrap"
      $txtContras.Margin = "26,2,0,0"
      $painelCartao.Children.Add($txtContras) | Out-Null

      $grade.Children.Add($cartao) | Out-Null
    }
    $painelCategorias.Children.Add($grade) | Out-Null
  }
  $raiz.Children.Add($scroll) | Out-Null

  # Callbacks criados com GetNewClosure() UMA vez, aqui no escopo direto
  # de Build-AjustesTab -- nao aninhados dentro do Add_Click. GetNewClosure()
  # aninhado dentro de outra closure perde a referencia de variaveis do
  # escopo avo (bug real confirmado com teste minimo em segundo plano
  # de longa duracao); criando aqui a captura fica confiavel.
  $callbackStatus = {
    param($resultado, $erro)
    if ($erro) {
      "ERRO no BtnStatus: $erro" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao ler status -- veja o log.") | Out-Null
      return
    }
    foreach ($nome in $resultado.Keys) {
      if ($null -ne $resultado[$nome] -and $checkboxesPorItem.ContainsKey($nome)) {
        $checkboxesPorItem[$nome].IsChecked = [bool]$resultado[$nome]
      }
    }
    $setStatus.Invoke("Status atualizado.") | Out-Null
  }.GetNewClosure()

  $callbackAplicar = {
    param($resultado, $erro)
    if ($erro) {
      "ERRO no BtnAplicar: $erro" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao aplicar -- veja o log.") | Out-Null
      return
    }
    $setStatus.Invoke("Pronto: $resultado item(ns) aplicado(s).") | Out-Null
  }.GetNewClosure()

  $callbackReverter = {
    param($resultado, $erro)
    if ($erro) {
      "ERRO no BtnReverter: $erro" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao reverter -- veja o log.") | Out-Null
      return
    }
    $setStatus.Invoke("Pronto: $resultado item(ns) revertido(s).") | Out-Null
  }.GetNewClosure()

  $btnStatus.Add_Click({
    try {
      $itensComStatus = @($checkboxesPorItem.Values | ForEach-Object { $_.Tag } | Where-Object { $_.Conv -eq "toggle" -or $_.Conv -eq "onoff" })
      $setStatus.Invoke("Lendo status atual de cada item em segundo plano...") | Out-Null

      $trabalho = {
        param($itens, $dirScripts)
        $resultados = @{}
        $i = 0
        foreach ($item in $itens) {
          $i++
          $progresso.Texto = "Lendo status ($i/$($itens.Count)): $($item.Nome)..."
          $caminho = Join-Path $dirScripts $item.Script
          try {
            $ligado = $null
            switch ($item.Conv) {
              "toggle" { $ligado = ((& $caminho -Action Status 2>&1 | Select-Object -First 1) -match "^LIGADO") }
              "onoff"  { $ligado = (((& $caminho -Action Status 2>&1) -join " ") -match "Ligado") }
            }
            $resultados[$item.Nome] = $ligado
          } catch { $resultados[$item.Nome] = $null }
        }
        return $resultados
      }

      $emSegundoPlano.Invoke(@($btnStatus, $btnAplicar, $btnReverter), $trabalho, @($itensComStatus, $scriptsDir), $callbackStatus, $setStatus)
    } catch {
      "ERRO no BtnStatus: $_`n$($_.ScriptStackTrace)" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao ler status -- veja o log.") | Out-Null
    }
  }.GetNewClosure())

  $btnAplicar.Add_Click({
    try {
      $marcados = @($checkboxesPorItem.Values | Where-Object { $_.IsChecked -eq $true })
      if ($marcados.Count -eq 0) { $setStatus.Invoke("Nenhum item marcado.") | Out-Null; return }
      $itens = @($marcados | ForEach-Object { $_.Tag })
      $setStatus.Invoke("Aplicando $($itens.Count) item(ns) em segundo plano -- a janela continua funcionando normal...") | Out-Null

      $trabalho = {
        param($itens, $dirScripts)
        $i = 0
        foreach ($item in $itens) {
          $i++
          $progresso.Texto = "Aplicando ($i/$($itens.Count)): $($item.Nome)..."
          $caminho = Join-Path $dirScripts $item.Script
          try {
            switch ($item.Conv) {
              "toggle"       { & $caminho -Action Aplicar 2>&1 | Out-Null }
              "onoff"        { & $caminho -Action On 2>&1 | Out-Null }
              "onoffdireto"  { & $caminho -Action Off 2>&1 | Out-Null }
              default        { & $caminho 2>&1 | Out-Null }
            }
          } catch {}
        }
        return $itens.Count
      }

      $emSegundoPlano.Invoke(@($btnStatus, $btnAplicar, $btnReverter), $trabalho, @($itens, $scriptsDir), $callbackAplicar, $setStatus)
    } catch {
      "ERRO no BtnAplicar: $_`n$($_.ScriptStackTrace)" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao aplicar -- veja o log.") | Out-Null
    }
  }.GetNewClosure())

  $btnReverter.Add_Click({
    try {
      $marcados = @($checkboxesPorItem.Values | Where-Object { $_.IsChecked -eq $true })
      if ($marcados.Count -eq 0) { $setStatus.Invoke("Nenhum item marcado.") | Out-Null; return }
      $itens = @($marcados | Where-Object { $_.Tag.Conv -eq "toggle" -or $_.Tag.Conv -eq "onoff" } | ForEach-Object { $_.Tag })
      $setStatus.Invoke("Revertendo $($itens.Count) item(ns) em segundo plano -- a janela continua funcionando normal...") | Out-Null

      $trabalho = {
        param($itens, $dirScripts)
        $i = 0
        foreach ($item in $itens) {
          $i++
          $progresso.Texto = "Revertendo ($i/$($itens.Count)): $($item.Nome)..."
          $caminho = Join-Path $dirScripts $item.Script
          try {
            if ($item.Conv -eq "toggle") { & $caminho -Action Reverter 2>&1 | Out-Null }
            else { & $caminho -Action Off 2>&1 | Out-Null }
          } catch {}
        }
        return $itens.Count
      }

      $emSegundoPlano.Invoke(@($btnStatus, $btnAplicar, $btnReverter), $trabalho, @($itens, $scriptsDir), $callbackReverter, $setStatus)
    } catch {
      "ERRO no BtnReverter: $_`n$($_.ScriptStackTrace)" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao reverter -- veja o log.") | Out-Null
    }
  }.GetNewClosure())

  return $raiz
}
