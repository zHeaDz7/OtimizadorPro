# Aba "Instalar" -- catálogo de programas via winget (Windows Package
# Manager, oficial da Microsoft, já vem no Windows 10/11 atualizado).
# Cada ID abaixo foi conferido rodando "winget show --id X --exact" de
# verdade antes de entrar aqui. Cada app tem uma descrição curta em
# português simples, pra quem não conhece o programa saber o que é
# antes de marcar o checkbox.
$Global:CatalogoApps = @(
  # --- Jogos e Launchers ---
  @{ Nome = "Steam"; Id = "Valve.Steam"; Cat = "Jogos e Launchers"; Desc = "Loja de jogos mais usada do mundo (Valve)." }
  @{ Nome = "Epic Games Launcher"; Id = "EpicGames.EpicGamesLauncher"; Cat = "Jogos e Launchers"; Desc = "Loja de jogos da Epic -- jogo grátis toda semana." }
  @{ Nome = "GOG Galaxy"; Id = "GOG.Galaxy"; Cat = "Jogos e Launchers"; Desc = "Loja de jogos sem proteção anticópia (GOG)." }
  @{ Nome = "Battle.net"; Id = "Blizzard.BattleNet"; Cat = "Jogos e Launchers"; Desc = "Loja de jogos da Blizzard (WoW, Overwatch, Diablo)." }
  @{ Nome = "EA App"; Id = "ElectronicArts.EADesktop"; Cat = "Jogos e Launchers"; Desc = "Loja de jogos da EA (FIFA/EA Sports FC, Battlefield)." }
  @{ Nome = "Ubisoft Connect"; Id = "Ubisoft.Connect"; Cat = "Jogos e Launchers"; Desc = "Loja de jogos da Ubisoft (Assassin's Creed, Far Cry)." }
  @{ Nome = "Rockstar Games Launcher"; Id = "RockstarGames.Launcher"; Cat = "Jogos e Launchers"; Desc = "Loja de jogos da Rockstar (GTA, Red Dead Redemption)." }
  @{ Nome = "Playnite"; Id = "Playnite.Playnite"; Cat = "Jogos e Launchers"; Desc = "Junta jogos de várias lojas numa biblioteca só." }

  # --- Navegadores ---
  @{ Nome = "Google Chrome"; Id = "Google.Chrome"; Cat = "Navegadores"; Desc = "Navegador de internet mais usado do mundo." }
  @{ Nome = "Mozilla Firefox"; Id = "Mozilla.Firefox"; Cat = "Navegadores"; Desc = "Navegador de internet focado em privacidade." }
  @{ Nome = "Microsoft Edge"; Id = "Microsoft.Edge"; Cat = "Navegadores"; Desc = "Navegador oficial que já vem com o Windows." }
  @{ Nome = "Brave"; Id = "Brave.Brave"; Cat = "Navegadores"; Desc = "Navegador que bloqueia anúncio e rastreador sozinho." }
  @{ Nome = "Opera GX"; Id = "Opera.OperaGX"; Cat = "Navegadores"; Desc = "Navegador com recursos voltados pra jogo." }

  # --- Comunicação ---
  @{ Nome = "Discord"; Id = "Discord.Discord"; Cat = "Comunicação"; Desc = "Chat de voz e texto mais usado por jogador." }
  @{ Nome = "Telegram"; Id = "Telegram.TelegramDesktop"; Cat = "Comunicação"; Desc = "Mensagens rápidas e grupos grandes." }
  @{ Nome = "Zoom"; Id = "Zoom.Zoom"; Cat = "Comunicação"; Desc = "Videochamada, o mais usado pra reunião/aula online." }
  @{ Nome = "Microsoft Teams"; Id = "Microsoft.Teams"; Cat = "Comunicação"; Desc = "Videochamada e chat de trabalho da Microsoft." }
  @{ Nome = "Slack"; Id = "SlackTechnologies.Slack"; Cat = "Comunicação"; Desc = "Chat de equipe/trabalho organizado por canal." }
  @{ Nome = "Signal"; Id = "OpenWhisperSystems.Signal"; Cat = "Comunicação"; Desc = "Mensagens com criptografia forte, alternativa ao WhatsApp." }
  @{ Nome = "Mozilla Thunderbird"; Id = "Mozilla.Thunderbird"; Cat = "Comunicação"; Desc = "Programa pra ler e organizar e-mail no PC." }

  # --- Multimídia ---
  @{ Nome = "VLC Media Player"; Id = "VideoLAN.VLC"; Cat = "Multimídia"; Desc = "Toca qualquer formato de vídeo/áudio sem precisar de codec extra." }
  @{ Nome = "OBS Studio"; Id = "OBSProject.OBSStudio"; Cat = "Multimídia"; Desc = "Gravar tela e fazer live -- o mais usado do mundo." }
  @{ Nome = "Spotify"; Id = "Spotify.Spotify"; Cat = "Multimídia"; Desc = "Streaming de música mais usado do mundo." }
  @{ Nome = "foobar2000"; Id = "PeterPawlowski.foobar2000"; Cat = "Multimídia"; Desc = "Tocador de música leve e personalizável." }
  @{ Nome = "Audacity"; Id = "Audacity.Audacity"; Cat = "Multimídia"; Desc = "Editor de áudio gratuito." }
  @{ Nome = "HandBrake"; Id = "HandBrake.HandBrake"; Cat = "Multimídia"; Desc = "Converte vídeo pra outro formato ou tamanho menor." }
  @{ Nome = "ShareX"; Id = "ShareX.ShareX"; Cat = "Multimídia"; Desc = "Print de tela e gravação com edição rápida." }
  @{ Nome = "IrfanView"; Id = "IrfanSkiljan.IrfanView"; Cat = "Multimídia"; Desc = "Visualizador de imagem leve e rápido." }
  @{ Nome = "Paint.NET"; Id = "dotPDN.PaintDotNet"; Cat = "Multimídia"; Desc = "Editor de imagem simples, tipo Paint melhorado." }
  @{ Nome = "GIMP"; Id = "GIMP.GIMP"; Cat = "Multimídia"; Desc = "Editor de imagem avançado e gratuito (tipo Photoshop)." }
  @{ Nome = "Blender"; Id = "BlenderFoundation.Blender"; Cat = "Multimídia"; Desc = "Modelagem e animação 3D, gratuito." }

  # --- Ferramentas / Sistema ---
  @{ Nome = "PowerToys"; Id = "Microsoft.PowerToys"; Cat = "Ferramentas e Sistema"; Desc = "Utilitários extras oficiais da Microsoft pro Windows." }
  @{ Nome = "Windows Terminal"; Id = "Microsoft.WindowsTerminal"; Cat = "Ferramentas e Sistema"; Desc = "Terminal moderno do Windows (PowerShell/CMD)." }
  @{ Nome = "7-Zip"; Id = "7zip.7zip"; Cat = "Ferramentas e Sistema"; Desc = "Compacta/descompacta arquivo .zip, .rar, .7z." }
  @{ Nome = "WinRAR"; Id = "RARLab.WinRAR"; Cat = "Ferramentas e Sistema"; Desc = "Compacta/descompacta arquivo, o mais conhecido." }
  @{ Nome = "Process Explorer"; Id = "Microsoft.Sysinternals.ProcessExplorer"; Cat = "Ferramentas e Sistema"; Desc = "Gerenciador de tarefas avançado, oficial da Microsoft." }
  @{ Nome = "Autoruns"; Id = "Microsoft.Sysinternals.Autoruns"; Cat = "Ferramentas e Sistema"; Desc = "Mostra tudo que inicia com o Windows -- oficial da Microsoft." }
  @{ Nome = "GPU-Z"; Id = "TechPowerUp.GPU-Z"; Cat = "Ferramentas e Sistema"; Desc = "Mostra informação detalhada da placa de vídeo." }
  @{ Nome = "CPU-Z"; Id = "CPUID.CPU-Z"; Cat = "Ferramentas e Sistema"; Desc = "Mostra informação detalhada do processador." }
  @{ Nome = "HWiNFO"; Id = "REALiX.HWiNFO"; Cat = "Ferramentas e Sistema"; Desc = "Mostra informação detalhada de todo o hardware do PC." }
  @{ Nome = "CrystalDiskInfo"; Id = "CrystalDewWorld.CrystalDiskInfo"; Cat = "Ferramentas e Sistema"; Desc = "Mostra a saúde do seu SSD/HD." }
  @{ Nome = "MSI Afterburner"; Id = "Guru3D.Afterburner"; Cat = "Ferramentas e Sistema"; Desc = "Overclock e monitoramento da placa de vídeo." }
  @{ Nome = "Notepad++"; Id = "Notepad++.Notepad++"; Cat = "Ferramentas e Sistema"; Desc = "Editor de texto avançado, o mais usado pra programar." }
  @{ Nome = "Everything (busca de arquivo)"; Id = "voidtools.Everything"; Cat = "Ferramentas e Sistema"; Desc = "Busca arquivo no PC instantaneamente." }
  @{ Nome = "TeamViewer"; Id = "TeamViewer.TeamViewer"; Cat = "Ferramentas e Sistema"; Desc = "Acessar/controlar outro PC à distância." }
  @{ Nome = "AnyDesk"; Id = "AnyDesk.AnyDesk"; Cat = "Ferramentas e Sistema"; Desc = "Acessar/controlar outro PC à distância (alternativa ao TeamViewer)." }
  @{ Nome = "CCleaner"; Id = "Piriform.CCleaner"; Cat = "Ferramentas e Sistema"; Desc = "Limpeza de arquivo temporário e registro do Windows." }
  @{ Nome = "Malwarebytes"; Id = "Malwarebytes.Malwarebytes"; Cat = "Ferramentas e Sistema"; Desc = "Remove vírus/malware que o antivírus normal pode deixar passar." }
  @{ Nome = "qBittorrent"; Id = "qBittorrent.qBittorrent"; Cat = "Ferramentas e Sistema"; Desc = "Programa de torrent (compartilhamento de arquivo)." }
  @{ Nome = "KeePass"; Id = "DominikReichl.KeePass"; Cat = "Ferramentas e Sistema"; Desc = "Guarda suas senhas de forma segura e criptografada." }

  # --- Desenvolvimento ---
  @{ Nome = "Git"; Id = "Git.Git"; Cat = "Desenvolvimento"; Desc = "Controle de versão de código, usado por quase todo programador." }
  @{ Nome = "Visual Studio Code"; Id = "Microsoft.VisualStudioCode"; Cat = "Desenvolvimento"; Desc = "Editor de código mais usado do mundo." }
  @{ Nome = "Python 3.12"; Id = "Python.Python.3.12"; Cat = "Desenvolvimento"; Desc = "Linguagem de programação Python." }
  @{ Nome = "Node.js LTS"; Id = "OpenJS.NodeJS.LTS"; Cat = "Desenvolvimento"; Desc = "Roda JavaScript fora do navegador." }
  @{ Nome = "Docker Desktop"; Id = "Docker.DockerDesktop"; Cat = "Desenvolvimento"; Desc = "Roda programa isolado em container." }
  @{ Nome = "WinSCP"; Id = "WinSCP.WinSCP"; Cat = "Desenvolvimento"; Desc = "Transferir arquivo com servidor remoto (SFTP/FTP)." }
  @{ Nome = "PuTTY"; Id = "PuTTY.PuTTY"; Cat = "Desenvolvimento"; Desc = "Conectar em servidor remoto via terminal (SSH)." }
  @{ Nome = "Oracle VirtualBox"; Id = "Oracle.VirtualBox"; Cat = "Desenvolvimento"; Desc = "Roda outro sistema operacional dentro de uma janela (máquina virtual)." }
  @{ Nome = "Postman"; Id = "Postman.Postman"; Cat = "Desenvolvimento"; Desc = "Testar chamada de API -- ferramenta de programador." }

  # --- Produtividade ---
  @{ Nome = "Notion"; Id = "Notion.Notion"; Cat = "Produtividade"; Desc = "Anotação, organização e banco de dados, tudo em um." }
  @{ Nome = "Obsidian"; Id = "Obsidian.Obsidian"; Cat = "Produtividade"; Desc = "Anotação com link entre páginas (segunda memória)." }
  @{ Nome = "LibreOffice"; Id = "TheDocumentFoundation.LibreOffice"; Cat = "Produtividade"; Desc = "Pacote de escritório gratuito (alternativa ao Office)." }
  @{ Nome = "Microsoft Office"; Id = "Microsoft.Office"; Cat = "Produtividade"; Desc = "Word, Excel, PowerPoint -- pacote oficial da Microsoft." }
  @{ Nome = "Adobe Acrobat Reader"; Id = "Adobe.Acrobat.Reader.64-bit"; Cat = "Produtividade"; Desc = "Leitor de PDF oficial da Adobe." }
  @{ Nome = "Google Drive"; Id = "Google.GoogleDrive"; Cat = "Produtividade"; Desc = "Sincroniza seus arquivos com o Google Drive." }
  @{ Nome = "Dropbox"; Id = "Dropbox.Dropbox"; Cat = "Produtividade"; Desc = "Sincroniza seus arquivos com o Dropbox." }
)

function Test-AppInstalado($id) {
  try {
    $r = (winget list --id $id --exact --accept-source-agreements 2>&1) -join "`n"
    return ($r -match [regex]::Escape($id))
  } catch { return $false }
}

function Build-InstalarTab {
  param($window, $setStatus, $emSegundoPlano)

  $raiz = New-Object System.Windows.Controls.DockPanel

  $barra = New-Object System.Windows.Controls.StackPanel
  $barra.Orientation = "Horizontal"
  $barra.Margin = "0,0,0,14"
  [System.Windows.Controls.DockPanel]::SetDock($barra, "Top")

  $btnInstalar = New-Object System.Windows.Controls.Button
  $btnInstalar.Name = "BtnInstalarSelecionados"
  $btnInstalar.Content = "Instalar selecionados"
  $btnInstalar.Style = $window.FindResource("BtnPrimary")
  $btnInstalar.Margin = "0,0,10,0"

  $btnDesinstalar = New-Object System.Windows.Controls.Button
  $btnDesinstalar.Name = "BtnDesinstalarSelecionados"
  $btnDesinstalar.Content = "Desinstalar selecionados"
  $btnDesinstalar.Style = $window.FindResource("BtnGhost")
  $btnDesinstalar.Margin = "0,0,10,0"

  $btnVerInstalados = New-Object System.Windows.Controls.Button
  $btnVerInstalados.Name = "BtnVerInstalados"
  $btnVerInstalados.Content = "Marcar já instalados"
  $btnVerInstalados.Style = $window.FindResource("BtnGhost")

  $barra.Children.Add($btnInstalar) | Out-Null
  $barra.Children.Add($btnDesinstalar) | Out-Null
  $barra.Children.Add($btnVerInstalados) | Out-Null
  $raiz.Children.Add($barra) | Out-Null

  $scroll = New-Object System.Windows.Controls.ScrollViewer
  $painelCategorias = New-Object System.Windows.Controls.StackPanel
  $scroll.Content = $painelCategorias

  $checkboxesPorApp = @{}
  $categorias = $Global:CatalogoApps.Cat | Select-Object -Unique
  foreach ($cat in $categorias) {
    $tituloCat = New-Object System.Windows.Controls.TextBlock
    $tituloCat.Text = $cat.ToUpper()
    $tituloCat.Style = $window.FindResource("Rotulo")
    $tituloCat.Margin = "2,14,0,6"
    $painelCategorias.Children.Add($tituloCat) | Out-Null

    $grade = New-Object System.Windows.Controls.WrapPanel
    foreach ($app in ($Global:CatalogoApps | Where-Object { $_.Cat -eq $cat })) {
      $borda = New-Object System.Windows.Controls.Border
      $borda.BorderBrush = $window.FindResource("BrushBorder")
      $borda.BorderThickness = 1
      $borda.CornerRadius = 6
      $borda.Margin = "0,0,10,10"
      $borda.Padding = "12,10"
      $borda.Width = 268

      $painelApp = New-Object System.Windows.Controls.StackPanel
      $borda.Child = $painelApp

      $cb = New-Object System.Windows.Controls.CheckBox
      $cb.Content = $app.Nome
      $cb.Tag = $app
      $painelApp.Children.Add($cb) | Out-Null

      $txtDesc = New-Object System.Windows.Controls.TextBlock
      $txtDesc.Text = $app.Desc
      $txtDesc.Foreground = $window.FindResource("BrushMuted")
      $txtDesc.FontSize = 11
      $txtDesc.TextWrapping = "Wrap"
      $txtDesc.Margin = "26,3,0,0"
      $painelApp.Children.Add($txtDesc) | Out-Null

      $checkboxesPorApp[$app.Id] = $cb
      $grade.Children.Add($borda) | Out-Null
    }
    $painelCategorias.Children.Add($grade) | Out-Null
  }
  $raiz.Children.Add($scroll) | Out-Null

  # Callbacks criados com GetNewClosure() UMA vez, aqui no escopo direto
  # de Build-InstalarTab -- nao aninhados dentro do Add_Click (que ja e
  # ele mesmo uma closure). GetNewClosure() aninhado dentro de outra
  # closure perde a referencia de variaveis do escopo avo (bug real
  # encontrado e confirmado com um teste minimo); criando aqui, no
  # escopo de primeira ordem, a captura fica confiavel mesmo depois de
  # dezenas de segundos rodando em segundo plano.
  $callbackVerInstalados = {
    param($resultado, $erro)
    if ($erro) {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnVerInstalados: $erro" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao verificar -- veja o log.") | Out-Null
      return
    }
    foreach ($id in $resultado) { if ($checkboxesPorApp.ContainsKey($id)) { $checkboxesPorApp[$id].IsChecked = $true } }
    $setStatus.Invoke("Verificação concluída: $($resultado.Count) app(s) já instalado(s) marcado(s).") | Out-Null
  }.GetNewClosure()

  $callbackInstalar = {
    param($resultado, $erro)
    if ($erro) {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnInstalar: $erro" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao instalar -- veja o log.") | Out-Null
      return
    }
    if ($resultado.Falhas -eq 0) {
      $setStatus.Invoke("Pronto: $($resultado.Sucessos) app(s) instalado(s) com sucesso.") | Out-Null
    } else {
      $setStatus.Invoke("$($resultado.Sucessos) instalado(s), $($resultado.Falhas) falharam (sem admin? abra como Administrador e tente de novo).") | Out-Null
    }
  }.GetNewClosure()

  $callbackDesinstalar = {
    param($resultado, $erro)
    if ($erro) {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnDesinstalar: $erro" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao desinstalar -- veja o log.") | Out-Null
      return
    }
    if ($resultado.Falhas -eq 0) {
      $setStatus.Invoke("Pronto: $($resultado.Sucessos) app(s) desinstalado(s) com sucesso.") | Out-Null
    } else {
      $setStatus.Invoke("$($resultado.Sucessos) desinstalado(s), $($resultado.Falhas) falharam (sem admin? abra como Administrador e tente de novo).") | Out-Null
    }
  }.GetNewClosure()

  $btnVerInstalados.Add_Click({
    try {
      $setStatus.Invoke("Verificando o que já está instalado em segundo plano...") | Out-Null
      $todosIds = @($checkboxesPorApp.Keys)
      $trabalho = {
        param($ids)
        $instalados = @()
        $i = 0
        foreach ($id in $ids) {
          $i++
          $progresso.Texto = "Verificando ($i/$($ids.Count)): $id..."
          try {
            $r = (winget list --id $id --exact --accept-source-agreements 2>&1) -join "`n"
            if ($r -match [regex]::Escape($id)) { $instalados += $id }
          } catch {}
        }
        return $instalados
      }
      $emSegundoPlano.Invoke(@($btnInstalar, $btnDesinstalar, $btnVerInstalados), $trabalho, @(,$todosIds), $callbackVerInstalados, $setStatus)
    } catch {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnVerInstalados: $_" | Out-File $debugLog -Append
    }
  }.GetNewClosure())

  $btnInstalar.Add_Click({
    try {
      $marcados = @($checkboxesPorApp.Values | Where-Object { $_.IsChecked -eq $true })
      if ($marcados.Count -eq 0) { $setStatus.Invoke("Nenhum app marcado.") | Out-Null; return }
      $listaApps = @($marcados | ForEach-Object { $_.Tag })
      $setStatus.Invoke("Instalando $($listaApps.Count) app(s) em segundo plano -- a janela continua funcionando normal...") | Out-Null

      $trabalho = {
        param($apps)
        $sucessos = 0; $falhas = 0
        $i = 0
        foreach ($app in $apps) {
          $i++
          $progresso.Texto = "Instalando ($i/$($apps.Count)): $($app.Nome)..."
          winget install --id $app.Id --exact --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
          if ($LASTEXITCODE -eq 0) { $sucessos++ } else { $falhas++ }
        }
        return @{ Sucessos = $sucessos; Falhas = $falhas }
      }

      $emSegundoPlano.Invoke(@($btnInstalar, $btnDesinstalar, $btnVerInstalados), $trabalho, @(,$listaApps), $callbackInstalar, $setStatus)
    } catch {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnInstalar: $_" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao instalar -- veja o log.") | Out-Null
    }
  }.GetNewClosure())

  $btnDesinstalar.Add_Click({
    try {
      $marcados = @($checkboxesPorApp.Values | Where-Object { $_.IsChecked -eq $true })
      if ($marcados.Count -eq 0) { $setStatus.Invoke("Nenhum app marcado.") | Out-Null; return }
      $listaApps = @($marcados | ForEach-Object { $_.Tag })
      $setStatus.Invoke("Desinstalando $($listaApps.Count) app(s) em segundo plano -- a janela continua funcionando normal...") | Out-Null

      $trabalho = {
        param($apps)
        $sucessos = 0; $falhas = 0
        $i = 0
        foreach ($app in $apps) {
          $i++
          $progresso.Texto = "Desinstalando ($i/$($apps.Count)): $($app.Nome)..."
          winget uninstall --id $app.Id --exact --silent 2>&1 | Out-Null
          if ($LASTEXITCODE -eq 0) { $sucessos++ } else { $falhas++ }
        }
        return @{ Sucessos = $sucessos; Falhas = $falhas }
      }

      $emSegundoPlano.Invoke(@($btnInstalar, $btnDesinstalar, $btnVerInstalados), $trabalho, @(,$listaApps), $callbackDesinstalar, $setStatus)
    } catch {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnDesinstalar: $_" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao desinstalar -- veja o log.") | Out-Null
    }
  }.GetNewClosure())

  return $raiz
}
