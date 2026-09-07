# Aba "Instalar" -- catalogo de programas via winget (Windows Package
# Manager, oficial da Microsoft, ja vem no Windows 10/11 atualizado).
# Cada ID abaixo foi conferido rodando "winget show --id X --exact" de
# verdade antes de entrar aqui.
$Global:CatalogoApps = @(
  # --- Jogos e Launchers ---
  @{ Nome = "Steam"; Id = "Valve.Steam"; Cat = "Jogos e Launchers" }
  @{ Nome = "Epic Games Launcher"; Id = "EpicGames.EpicGamesLauncher"; Cat = "Jogos e Launchers" }
  @{ Nome = "GOG Galaxy"; Id = "GOG.Galaxy"; Cat = "Jogos e Launchers" }
  @{ Nome = "Battle.net"; Id = "Blizzard.BattleNet"; Cat = "Jogos e Launchers" }
  @{ Nome = "EA App"; Id = "ElectronicArts.EADesktop"; Cat = "Jogos e Launchers" }
  @{ Nome = "Ubisoft Connect"; Id = "Ubisoft.Connect"; Cat = "Jogos e Launchers" }
  @{ Nome = "Rockstar Games Launcher"; Id = "RockstarGames.Launcher"; Cat = "Jogos e Launchers" }
  @{ Nome = "Playnite"; Id = "Playnite.Playnite"; Cat = "Jogos e Launchers" }

  # --- Navegadores ---
  @{ Nome = "Google Chrome"; Id = "Google.Chrome"; Cat = "Navegadores" }
  @{ Nome = "Mozilla Firefox"; Id = "Mozilla.Firefox"; Cat = "Navegadores" }
  @{ Nome = "Microsoft Edge"; Id = "Microsoft.Edge"; Cat = "Navegadores" }
  @{ Nome = "Brave"; Id = "Brave.Brave"; Cat = "Navegadores" }
  @{ Nome = "Opera GX"; Id = "Opera.OperaGX"; Cat = "Navegadores" }

  # --- Comunicacao ---
  @{ Nome = "Discord"; Id = "Discord.Discord"; Cat = "Comunicacao" }
  @{ Nome = "Telegram"; Id = "Telegram.TelegramDesktop"; Cat = "Comunicacao" }
  @{ Nome = "Zoom"; Id = "Zoom.Zoom"; Cat = "Comunicacao" }
  @{ Nome = "Microsoft Teams"; Id = "Microsoft.Teams"; Cat = "Comunicacao" }

  # --- Multimidia ---
  @{ Nome = "VLC Media Player"; Id = "VideoLAN.VLC"; Cat = "Multimidia" }
  @{ Nome = "OBS Studio"; Id = "OBSProject.OBSStudio"; Cat = "Multimidia" }
  @{ Nome = "Spotify"; Id = "Spotify.Spotify"; Cat = "Multimidia" }
  @{ Nome = "foobar2000"; Id = "PeterPawlowski.foobar2000"; Cat = "Multimidia" }
  @{ Nome = "Audacity"; Id = "Audacity.Audacity"; Cat = "Multimidia" }
  @{ Nome = "HandBrake"; Id = "HandBrake.HandBrake"; Cat = "Multimidia" }
  @{ Nome = "ShareX"; Id = "ShareX.ShareX"; Cat = "Multimidia" }
  @{ Nome = "IrfanView"; Id = "IrfanSkiljan.IrfanView"; Cat = "Multimidia" }
  @{ Nome = "Paint.NET"; Id = "dotPDN.PaintDotNet"; Cat = "Multimidia" }
  @{ Nome = "GIMP"; Id = "GIMP.GIMP"; Cat = "Multimidia" }
  @{ Nome = "Blender"; Id = "BlenderFoundation.Blender"; Cat = "Multimidia" }

  # --- Ferramentas / Sistema ---
  @{ Nome = "PowerToys"; Id = "Microsoft.PowerToys"; Cat = "Ferramentas e Sistema" }
  @{ Nome = "Windows Terminal"; Id = "Microsoft.WindowsTerminal"; Cat = "Ferramentas e Sistema" }
  @{ Nome = "7-Zip"; Id = "7zip.7zip"; Cat = "Ferramentas e Sistema" }
  @{ Nome = "WinRAR"; Id = "RARLab.WinRAR"; Cat = "Ferramentas e Sistema" }
  @{ Nome = "Process Explorer"; Id = "Microsoft.Sysinternals.ProcessExplorer"; Cat = "Ferramentas e Sistema" }
  @{ Nome = "Autoruns"; Id = "Microsoft.Sysinternals.Autoruns"; Cat = "Ferramentas e Sistema" }
  @{ Nome = "GPU-Z"; Id = "TechPowerUp.GPU-Z"; Cat = "Ferramentas e Sistema" }
  @{ Nome = "CPU-Z"; Id = "CPUID.CPU-Z"; Cat = "Ferramentas e Sistema" }
  @{ Nome = "HWiNFO"; Id = "REALiX.HWiNFO"; Cat = "Ferramentas e Sistema" }
  @{ Nome = "CrystalDiskInfo"; Id = "CrystalDewWorld.CrystalDiskInfo"; Cat = "Ferramentas e Sistema" }
  @{ Nome = "MSI Afterburner"; Id = "Guru3D.Afterburner"; Cat = "Ferramentas e Sistema" }
  @{ Nome = "Notepad++"; Id = "Notepad++.Notepad++"; Cat = "Ferramentas e Sistema" }
  @{ Nome = "Everything (busca de arquivo)"; Id = "voidtools.Everything"; Cat = "Ferramentas e Sistema" }

  # --- Desenvolvimento ---
  @{ Nome = "Git"; Id = "Git.Git"; Cat = "Desenvolvimento" }
  @{ Nome = "Visual Studio Code"; Id = "Microsoft.VisualStudioCode"; Cat = "Desenvolvimento" }
  @{ Nome = "Python 3.12"; Id = "Python.Python.3.12"; Cat = "Desenvolvimento" }
  @{ Nome = "Node.js LTS"; Id = "OpenJS.NodeJS.LTS"; Cat = "Desenvolvimento" }
  @{ Nome = "Docker Desktop"; Id = "Docker.DockerDesktop"; Cat = "Desenvolvimento" }

  # --- Produtividade ---
  @{ Nome = "Notion"; Id = "Notion.Notion"; Cat = "Produtividade" }
  @{ Nome = "Obsidian"; Id = "Obsidian.Obsidian"; Cat = "Produtividade" }
  @{ Nome = "LibreOffice"; Id = "TheDocumentFoundation.LibreOffice"; Cat = "Produtividade" }
  @{ Nome = "Adobe Acrobat Reader"; Id = "Adobe.Acrobat.Reader.64-bit"; Cat = "Produtividade" }
)

function Test-AppInstalado($id) {
  try {
    $r = (winget list --id $id --exact --accept-source-agreements 2>&1) -join "`n"
    return ($r -match [regex]::Escape($id))
  } catch { return $false }
}

function Build-InstalarTab {
  param($window, $setStatus)

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
  $btnVerInstalados.Content = "Marcar ja instalados"
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
      $borda.Width = 220

      $cb = New-Object System.Windows.Controls.CheckBox
      $cb.Content = $app.Nome
      $cb.Tag = $app
      $borda.Child = $cb
      $checkboxesPorApp[$app.Id] = $cb
      $grade.Children.Add($borda) | Out-Null
    }
    $painelCategorias.Children.Add($grade) | Out-Null
  }
  $raiz.Children.Add($scroll) | Out-Null

  $btnVerInstalados.Add_Click({
    try {
      $setStatus.Invoke("Verificando o que ja esta instalado (pode demorar um pouco)...") | Out-Null
      foreach ($id in @($checkboxesPorApp.Keys)) {
        if (Test-AppInstalado $id) { $checkboxesPorApp[$id].IsChecked = $true }
      }
      $setStatus.Invoke("Verificacao concluida.") | Out-Null
    } catch {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnVerInstalados: $_" | Out-File $debugLog -Append
    }
  }.GetNewClosure())

  $btnInstalar.Add_Click({
    try {
      $marcados = @($checkboxesPorApp.Values | Where-Object { $_.IsChecked -eq $true })
      if ($marcados.Count -eq 0) { $setStatus.Invoke("Nenhum app marcado.") | Out-Null; return }
      $i = 0
      $sucessos = 0
      $falhas = 0
      foreach ($cb in $marcados) {
        $i++
        $app = $cb.Tag
        $setStatus.Invoke("Instalando ($i/$($marcados.Count)): $($app.Nome)...") | Out-Null
        winget install --id $app.Id --exact --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
        # winget devolve exit code != 0 quando falha (ex: precisa de
        # Administrador) -- reportar "processado" pra tudo sem checar
        # isso seria informar sucesso falso.
        if ($LASTEXITCODE -eq 0) { $sucessos++ } else { $falhas++ }
      }
      if ($falhas -eq 0) {
        $setStatus.Invoke("Pronto: $sucessos app(s) instalado(s) com sucesso.") | Out-Null
      } else {
        $setStatus.Invoke("$sucessos instalado(s), $falhas falharam (sem admin? abra como Administrador e tente de novo).") | Out-Null
      }
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
      $i = 0
      $sucessos = 0
      $falhas = 0
      foreach ($cb in $marcados) {
        $i++
        $app = $cb.Tag
        $setStatus.Invoke("Desinstalando ($i/$($marcados.Count)): $($app.Nome)...") | Out-Null
        winget uninstall --id $app.Id --exact --silent 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $sucessos++ } else { $falhas++ }
      }
      if ($falhas -eq 0) {
        $setStatus.Invoke("Pronto: $sucessos app(s) desinstalado(s) com sucesso.") | Out-Null
      } else {
        $setStatus.Invoke("$sucessos desinstalado(s), $falhas falharam (sem admin? abra como Administrador e tente de novo).") | Out-Null
      }
    } catch {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnDesinstalar: $_" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao desinstalar -- veja o log.") | Out-Null
    }
  }.GetNewClosure())

  return $raiz
}
