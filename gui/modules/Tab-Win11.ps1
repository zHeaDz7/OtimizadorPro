# Aba "Criador Win11" -- só trabalha com mídia OFICIAL da Microsoft.
# Nada de ISO modificada/"gamer edition" de terceiro -- e por isso que
# a opcao 1 manda pro site oficial, e a opcao 2 so aceita uma ISO que o
# usuario ja baixou (presumivelmente da Microsoft) pra gravar num pendrive.

function Build-Win11Tab {
  param($window, $setStatus, $emSegundoPlano)

  $raiz = New-Object System.Windows.Controls.ScrollViewer
  $painel = New-Object System.Windows.Controls.StackPanel
  $painel.Margin = "0,0,20,0"
  $raiz.Content = $painel

  $titulo = New-Object System.Windows.Controls.TextBlock
  $titulo.Text = "Criador de mídia do Windows 11"
  $titulo.Foreground = $window.FindResource("BrushInk")
  $titulo.FontSize = 18
  $titulo.FontWeight = "Bold"
  $titulo.Margin = "0,0,0,4"
  $painel.Children.Add($titulo) | Out-Null

  $sub = New-Object System.Windows.Controls.TextBlock
  $sub.Text = "Só trabalha com mídia OFICIAL da Microsoft. Nada de ISO alterada ou de terceiro."
  $sub.Foreground = $window.FindResource("BrushMuted")
  $sub.TextWrapping = "Wrap"
  $sub.Margin = "0,0,0,20"
  $painel.Children.Add($sub) | Out-Null

  # --- Passo 1: baixar a ferramenta oficial ---
  $b1 = New-Object System.Windows.Controls.Border
  $b1.BorderBrush = $window.FindResource("BrushBorder")
  $b1.BorderThickness = 1
  $b1.CornerRadius = 8
  $b1.Padding = 18
  $b1.Margin = "0,0,0,16"
  $p1 = New-Object System.Windows.Controls.StackPanel
  $b1.Child = $p1

  $t1 = New-Object System.Windows.Controls.TextBlock
  $t1.Text = "1. Baixar a ferramenta oficial da Microsoft"
  $t1.Foreground = $window.FindResource("BrushInk")
  $t1.FontWeight = "Bold"
  $t1.FontSize = 15
  $t1.Margin = "0,0,0,6"
  $p1.Children.Add($t1) | Out-Null

  $d1 = New-Object System.Windows.Controls.TextBlock
  $d1.Text = "Abre a página oficial da Microsoft (microsoft.com) onde você baixa a Media Creation Tool ou a ISO direto -- do jeito que a própria Microsoft recomenda. Não baixamos nada por conta própria nessa etapa, só abrimos o navegador."
  $d1.Foreground = $window.FindResource("BrushMuted")
  $d1.TextWrapping = "Wrap"
  $d1.FontSize = 12.5
  $d1.Margin = "0,0,0,12"
  $p1.Children.Add($d1) | Out-Null

  $barra1 = New-Object System.Windows.Controls.StackPanel
  $barra1.Orientation = "Horizontal"
  $btnAbrirSite = New-Object System.Windows.Controls.Button
  $btnAbrirSite.Name = "BtnWin11AbrirSite"
  $btnAbrirSite.Content = "Abrir página oficial de download do Windows 11"
  $btnAbrirSite.Style = $window.FindResource("BtnPrimary")
  $barra1.Children.Add($btnAbrirSite) | Out-Null
  $p1.Children.Add($barra1) | Out-Null

  $btnAbrirSite.Add_Click({
    try {
      Start-Process "https://www.microsoft.com/software-download/windows11"
      $setStatus.Invoke("Página oficial da Microsoft aberta no navegador.") | Out-Null
    } catch {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnWin11AbrirSite: $_" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao abrir o navegador.") | Out-Null
    }
  }.GetNewClosure())

  $painel.Children.Add($b1) | Out-Null

  # --- Passo 2: gravar ISO num pendrive ---
  $b2 = New-Object System.Windows.Controls.Border
  $b2.BorderBrush = $window.FindResource("BrushBorder")
  $b2.BorderThickness = 1
  $b2.CornerRadius = 8
  $b2.Padding = 18
  $p2 = New-Object System.Windows.Controls.StackPanel
  $b2.Child = $p2

  $t2 = New-Object System.Windows.Controls.TextBlock
  $t2.Text = "2. Gravar uma ISO oficial num pendrive bootável"
  $t2.Foreground = $window.FindResource("BrushInk")
  $t2.FontWeight = "Bold"
  $t2.FontSize = 15
  $t2.Margin = "0,0,0,6"
  $p2.Children.Add($t2) | Out-Null

  $d2 = New-Object System.Windows.Controls.TextBlock
  $d2.Text = "Use depois de já ter baixado o arquivo .iso oficial da Microsoft (passo 1). Isso APAGA TUDO que tiver no pendrive escolhido -- formata e copia os arquivos da ISO. Só funciona pra PC com boot UEFI (praticamente todo PC feito depois de 2013). PC muito antigo com BIOS Legacy: use a Media Creation Tool oficial no passo 1 em vez desse gravador."
  $d2.Foreground = $window.FindResource("BrushMuted")
  $d2.TextWrapping = "Wrap"
  $d2.FontSize = 12.5
  $d2.Margin = "0,0,0,12"
  $p2.Children.Add($d2) | Out-Null

  # Linha: caminho da ISO
  $linhaIso = New-Object System.Windows.Controls.StackPanel
  $linhaIso.Orientation = "Horizontal"
  $linhaIso.Margin = "0,0,0,10"
  $txtIso = New-Object System.Windows.Controls.TextBox
  $txtIso.Name = "TxtWin11CaminhoIso"
  $txtIso.Width = 480
  $txtIso.IsReadOnly = $true
  $txtIso.Text = ""
  $txtIso.Tag = "(nenhuma ISO selecionada)"
  $txtIso.Text = $txtIso.Tag
  $btnEscolherIso = New-Object System.Windows.Controls.Button
  $btnEscolherIso.Name = "BtnWin11EscolherIso"
  $btnEscolherIso.Content = "Escolher arquivo .iso..."
  $btnEscolherIso.Style = $window.FindResource("BtnGhost")
  $btnEscolherIso.Margin = "10,0,0,0"
  $linhaIso.Children.Add($txtIso) | Out-Null
  $linhaIso.Children.Add($btnEscolherIso) | Out-Null
  $p2.Children.Add($linhaIso) | Out-Null

  $btnEscolherIso.Add_Click({
    try {
      $dlg = New-Object Microsoft.Win32.OpenFileDialog
      $dlg.Filter = "Imagem ISO (*.iso)|*.iso"
      $dlg.Title = "Escolha a ISO oficial do Windows 11"
      if ($dlg.ShowDialog()) {
        $txtIso.Text = $dlg.FileName
        $setStatus.Invoke("ISO selecionada: $($dlg.FileName)") | Out-Null
      }
    } catch {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnWin11EscolherIso: $_" | Out-File $debugLog -Append
    }
  }.GetNewClosure())

  # Linha: escolher pendrive
  $linhaUsb = New-Object System.Windows.Controls.StackPanel
  $linhaUsb.Orientation = "Horizontal"
  $linhaUsb.Margin = "0,0,0,10"
  $lblUsb = New-Object System.Windows.Controls.TextBlock
  $lblUsb.Text = "Pendrive:"
  $lblUsb.Foreground = $window.FindResource("BrushMuted")
  $lblUsb.VerticalAlignment = "Center"
  $lblUsb.Margin = "0,0,10,0"
  $comboUsb = New-Object System.Windows.Controls.ComboBox
  $comboUsb.Name = "ComboWin11Pendrive"
  $comboUsb.Width = 420
  $btnAtualizarUsb = New-Object System.Windows.Controls.Button
  $btnAtualizarUsb.Name = "BtnWin11AtualizarPendrives"
  $btnAtualizarUsb.Content = "Atualizar lista"
  $btnAtualizarUsb.Style = $window.FindResource("BtnGhost")
  $btnAtualizarUsb.Margin = "10,0,0,0"
  $linhaUsb.Children.Add($lblUsb) | Out-Null
  $linhaUsb.Children.Add($comboUsb) | Out-Null
  $linhaUsb.Children.Add($btnAtualizarUsb) | Out-Null
  $p2.Children.Add($linhaUsb) | Out-Null

  function Carregar-Pendrives($combo) {
    $combo.Items.Clear()
    try {
      $discos = Get-Disk | Where-Object { $_.BusType -eq "USB" }
      foreach ($disco in $discos) {
        $particoes = Get-Partition -DiskNumber $disco.Number -ErrorAction SilentlyContinue | Where-Object { $_.DriveLetter }
        $letra = ($particoes | Select-Object -First 1).DriveLetter
        $tamanhoGB = [math]::Round($disco.Size / 1GB, 1)
        $rotulo = if ($letra) { "$($letra): -- $($disco.FriendlyName) ($tamanhoGB GB)" } else { "(sem letra) -- $($disco.FriendlyName) ($tamanhoGB GB)" }
        $item = New-Object System.Windows.Controls.ComboBoxItem
        $item.Content = $rotulo
        $item.Tag = @{ DiskNumber = $disco.Number; DriveLetter = $letra; Tamanho = $tamanhoGB }
        $combo.Items.Add($item) | Out-Null
      }
      if ($combo.Items.Count -eq 0) {
        $item = New-Object System.Windows.Controls.ComboBoxItem
        $item.Content = "(nenhum pendrive USB encontrado -- conecte um e clique em Atualizar)"
        $combo.Items.Add($item) | Out-Null
      }
      $combo.SelectedIndex = 0
    } catch {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO ao listar pendrives: $_" | Out-File $debugLog -Append
    }
  }

  $btnAtualizarUsb.Add_Click({
    Carregar-Pendrives $comboUsb
    $setStatus.Invoke("Lista de pendrives atualizada.") | Out-Null
  }.GetNewClosure())

  Carregar-Pendrives $comboUsb

  # Linha: confirmar apagando tudo
  $avisoApagar = New-Object System.Windows.Controls.TextBlock
  $avisoApagar.Text = "ATENÇÃO: gravar vai APAGAR TUDO no pendrive escolhido. Pra confirmar, digite a letra do drive (ex: E) na caixa abaixo."
  $avisoApagar.Foreground = $window.FindResource("BrushBad")
  $avisoApagar.TextWrapping = "Wrap"
  $avisoApagar.FontSize = 12.5
  $avisoApagar.Margin = "0,4,0,8"
  $p2.Children.Add($avisoApagar) | Out-Null

  $linhaConfirma = New-Object System.Windows.Controls.StackPanel
  $linhaConfirma.Orientation = "Horizontal"
  $linhaConfirma.Margin = "0,0,0,4"
  $txtConfirma = New-Object System.Windows.Controls.TextBox
  $txtConfirma.Name = "TxtWin11Confirma"
  $txtConfirma.Width = 80
  $btnGravar = New-Object System.Windows.Controls.Button
  $btnGravar.Name = "BtnWin11Gravar"
  $btnGravar.Content = "Formatar e gravar pendrive"
  $btnGravar.Style = $window.FindResource("BtnPrimary")
  $btnGravar.Margin = "10,0,0,0"
  $linhaConfirma.Children.Add($txtConfirma) | Out-Null
  $linhaConfirma.Children.Add($btnGravar) | Out-Null
  $p2.Children.Add($linhaConfirma) | Out-Null

  # Callback criado com GetNewClosure() UMA vez, aqui no escopo direto
  # de Build-Win11Tab -- nao aninhado dentro do Add_Click (evita o bug
  # de GetNewClosure() aninhado perder variavel do escopo avo depois de
  # rodar varios minutos em segundo plano, confirmado com teste real).
  $callbackGravar = {
    param($resultado, $erro)
    if ($erro) {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnWin11Gravar: $erro" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao gravar -- precisa ser Administrador. Veja o log.") | Out-Null
      return
    }
    $setStatus.Invoke($resultado) | Out-Null
  }.GetNewClosure()

  $btnGravar.Add_Click({
    try {
      $isoPath = $txtIso.Text
      if (-not $isoPath -or $isoPath -eq "(nenhuma ISO selecionada)" -or -not (Test-Path $isoPath)) {
        $setStatus.Invoke("Escolha um arquivo .iso válido primeiro.") | Out-Null
        return
      }
      $itemSel = $comboUsb.SelectedItem
      if (-not $itemSel -or -not $itemSel.Tag) {
        $setStatus.Invoke("Escolha um pendrive válido primeiro.") | Out-Null
        return
      }
      $infoDisco = $itemSel.Tag
      if (-not $infoDisco.DriveLetter) {
        $setStatus.Invoke("Esse pendrive não tem letra de unidade atribuída -- use o Gerenciamento de Disco pra atribuir uma letra primeiro.") | Out-Null
        return
      }
      if ($txtConfirma.Text.Trim().ToUpper() -ne "$($infoDisco.DriveLetter)".ToUpper()) {
        $setStatus.Invoke("Confirmação não bate com a letra do drive selecionado ($($infoDisco.DriveLetter)). Nada foi feito.") | Out-Null
        return
      }

      $setStatus.Invoke("Formatando e gravando o pendrive $($infoDisco.DriveLetter): em segundo plano -- a janela continua funcionando normal. Isso pode demorar alguns minutos...") | Out-Null

      $trabalho = {
        param($diskNumber, $driveLetter, $isoPath)
        try {
          $particao = Get-Partition -DiskNumber $diskNumber | Where-Object { $_.DriveLetter -eq $driveLetter }
          Format-Volume -Partition $particao -FileSystem NTFS -NewFileSystemLabel "WIN11" -Confirm:$false -Force | Out-Null

          $img = Mount-DiskImage -ImagePath $isoPath -PassThru
          $volIso = ($img | Get-Volume).DriveLetter

          $origem = "$($volIso):\"
          $destino = "$($driveLetter):\"
          robocopy $origem $destino /E /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
          $codigoRobocopy = $LASTEXITCODE

          Dismount-DiskImage -ImagePath $isoPath | Out-Null

          if ($codigoRobocopy -lt 8) {
            return "Pronto: pendrive $($driveLetter): gravado com a mídia oficial do Windows 11."
          } else {
            return "Cópia terminou com avisos (código robocopy $codigoRobocopy) -- confira o pendrive antes de usar."
          }
        } catch {
          return "AVISO: precisa ser Administrador pra gravar o pendrive ($_)"
        }
      }

      $emSegundoPlano.Invoke(@($btnGravar), $trabalho, @($infoDisco.DiskNumber, $infoDisco.DriveLetter, $isoPath), $callbackGravar)
    } catch {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnWin11Gravar: $_" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao gravar -- precisa ser Administrador. Veja o log.") | Out-Null
    }
  }.GetNewClosure())

  $painel.Children.Add($b2) | Out-Null

  return $raiz
}
