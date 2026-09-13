# Aba "Internet" -- diagnostico real de ping/latencia (nao so promessa),
# teste de velocidade de verdade (baixa/envia bytes reais, mede tempo),
# e ajuda com a causa mais comum e menos conhecida de "download lento"
# em launcher de jogo: o LIMITADOR DE BANDA que Steam/Epic/Xbox tem
# dentro das proprias configuracoes deles. Nao mexe direto no arquivo de
# configuracao desses launchers (formato interno pode mudar a qualquer
# hora sem aviso -- arriscado demais editar as cegas), so abre o app
# certo e mostra exatamente onde procurar.

function Test-SteamInstalado {
  try {
    $steamPath = (Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue).SteamPath
    if ($steamPath -and (Test-Path (Join-Path $steamPath "steam.exe"))) { return (Join-Path $steamPath "steam.exe") }
  } catch {}
  foreach ($p in @("C:\Program Files (x86)\Steam\steam.exe", "C:\Program Files\Steam\steam.exe")) {
    if (Test-Path $p) { return $p }
  }
  return $null
}

function Test-EpicInstalado {
  try {
    $chave = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Epic Games\EpicGamesLauncher" -ErrorAction SilentlyContinue
    if ($chave -and $chave.AppDataPath) { return $true }
  } catch {}
  return (Test-Path "C:\Program Files (x86)\Epic Games\Launcher\Portal\Binaries\Win64\EpicGamesLauncher.exe")
}

function Open-XboxAppGUI {
  try {
    $pacote = Get-AppxPackage -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "GamingApp|XboxApp" } | Select-Object -First 1
    if ($pacote) {
      $manifest = Get-AppxPackageManifest $pacote -ErrorAction Stop
      $appId = $manifest.Package.Applications.Application.Id | Select-Object -First 1
      if ($appId) { Start-Process "shell:AppsFolder\$($pacote.PackageFamilyName)!$appId"; return $true }
    }
  } catch {}
  return $false
}

function Build-InternetTab {
  param($window, $scriptsDir, $setStatus, $emSegundoPlano)

  $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
  $raiz = New-Object System.Windows.Controls.DockPanel
  $raiz.Margin = "0,0,20,0"

  $titulo = New-Object System.Windows.Controls.TextBlock
  $titulo.Text = "Internet"
  $titulo.Foreground = $window.FindResource("BrushInk")
  $titulo.FontSize = 18
  $titulo.FontWeight = "Bold"
  $titulo.Margin = "0,0,0,4"
  [System.Windows.Controls.DockPanel]::SetDock($titulo, "Top")
  $raiz.Children.Add($titulo) | Out-Null

  $sub = New-Object System.Windows.Controls.TextBlock
  $sub.Text = "Diagnóstico real de ping/conexão, teste de velocidade de verdade (baixa/envia dados reais, não inventa número), e ajuda pra achar o limitador de banda escondido nas configurações do Steam/Epic/Xbox -- causa comum de download lento que quase ninguém sabe que existe."
  $sub.Foreground = $window.FindResource("BrushMuted")
  $sub.TextWrapping = "Wrap"
  $sub.Margin = "0,0,0,16"
  [System.Windows.Controls.DockPanel]::SetDock($sub, "Top")
  $raiz.Children.Add($sub) | Out-Null

  $scroll = New-Object System.Windows.Controls.ScrollViewer
  $painelRaiz = New-Object System.Windows.Controls.StackPanel
  $scroll.Content = $painelRaiz
  $raiz.Children.Add($scroll) | Out-Null

  function New-CardBase() {
    $cartao = New-Object System.Windows.Controls.Border
    $cartao.BorderBrush = $window.FindResource("BrushBorder")
    $cartao.BorderThickness = 1
    $cartao.CornerRadius = 8
    $cartao.Padding = 18
    $cartao.Margin = "0,0,0,16"
    $painel = New-Object System.Windows.Controls.StackPanel
    $cartao.Child = $painel
    return @{ Cartao = $cartao; Painel = $painel }
  }

  # --- Card: Diagnostico de ping/latencia ---
  $cPing = New-CardBase
  $tPing = New-Object System.Windows.Controls.TextBlock
  $tPing.Text = "Diagnóstico de ping e conexão"
  $tPing.Foreground = $window.FindResource("BrushInk")
  $tPing.FontWeight = "Bold"
  $tPing.FontSize = 15
  $tPing.Margin = "0,0,0,10"
  $cPing.Painel.Children.Add($tPing) | Out-Null

  $btnPing = New-Object System.Windows.Controls.Button
  $btnPing.Name = "BtnInternetPing"
  $btnPing.Content = "Verificar ping e conexão agora"
  $btnPing.Style = $window.FindResource("BtnPrimary")
  $btnPing.HorizontalAlignment = "Left"
  $cPing.Painel.Children.Add($btnPing) | Out-Null

  $txtPing = New-Object System.Windows.Controls.TextBlock
  $txtPing.TextWrapping = "Wrap"
  $txtPing.FontFamily = "Consolas"
  $txtPing.FontSize = 12
  $txtPing.Margin = "0,10,0,0"
  $txtPing.Foreground = $window.FindResource("BrushMuted")
  $txtPing.Visibility = "Collapsed"
  $cPing.Painel.Children.Add($txtPing) | Out-Null
  $painelRaiz.Children.Add($cPing.Cartao) | Out-Null

  # Callback criado UMA vez aqui, no escopo direto de Build-InternetTab --
  # nao aninhado dentro do Add_Click (que ja e ele mesmo uma closure).
  # GetNewClosure() aninhado dentro de outra closure perde a referencia
  # de variavel do escopo avo (bug real confirmado testando ao vivo:
  # "$txtPing" chegava null dentro do callback quando o GetNewClosure()
  # dele ficava aninhado dentro do GetNewClosure() do Add_Click -- mesma
  # causa raiz ja documentada em Tab-Ajustes.ps1/Tab-Diagnostico.ps1).
  $callbackPing = {
    param($resultado, $erro)
    if ($erro) {
      "ERRO no BtnInternetPing: $erro" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao verificar -- veja o log.") | Out-Null
      return
    }
    $txtPing.Text = "$resultado"
    $txtPing.Visibility = "Visible"
    $setStatus.Invoke("Diagnóstico de conexão concluído.") | Out-Null
  }.GetNewClosure()

  $btnPing.Add_Click({
    try {
      $setStatus.Invoke("Testando ping e conexão em segundo plano...") | Out-Null
      $trabalho = {
        param($dirScripts)
        $linhas = @()
        foreach ($nome in @("_ping_diagnostico.ps1", "_diag_wifi.ps1", "_diag_vpn.ps1")) {
          try { $linhas += @(& (Join-Path $dirScripts $nome) 2>&1) } catch { $linhas += "Erro ao rodar $nome`: $_" }
          $linhas += ""
        }
        return ($linhas -join "`n")
      }
      $emSegundoPlano.Invoke(@($btnPing), $trabalho, @($scriptsDir), $callbackPing, $setStatus)
    } catch {
      "ERRO no BtnInternetPing: $_`n$($_.ScriptStackTrace)" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao verificar -- veja o log.") | Out-Null
    }
  }.GetNewClosure())

  # --- Card: Teste de velocidade ---
  $cVel = New-CardBase
  $tVel = New-Object System.Windows.Controls.TextBlock
  $tVel.Text = "Teste de velocidade"
  $tVel.Foreground = $window.FindResource("BrushInk")
  $tVel.FontWeight = "Bold"
  $tVel.FontSize = 15
  $tVel.Margin = "0,0,0,4"
  $cVel.Painel.Children.Add($tVel) | Out-Null

  $dVel = New-Object System.Windows.Controls.TextBlock
  $dVel.Text = "Baixa e envia dados reais pra Cloudflare e cronometra -- mede a velocidade de verdade, não é estimativa."
  $dVel.Foreground = $window.FindResource("BrushMuted")
  $dVel.TextWrapping = "Wrap"
  $dVel.FontSize = 12
  $dVel.Margin = "0,0,0,10"
  $cVel.Painel.Children.Add($dVel) | Out-Null

  $btnVel = New-Object System.Windows.Controls.Button
  $btnVel.Name = "BtnInternetVelocidade"
  $btnVel.Content = "Testar velocidade agora"
  $btnVel.Style = $window.FindResource("BtnPrimary")
  $btnVel.HorizontalAlignment = "Left"
  $cVel.Painel.Children.Add($btnVel) | Out-Null

  $txtVel = New-Object System.Windows.Controls.TextBlock
  $txtVel.TextWrapping = "Wrap"
  $txtVel.FontSize = 13
  $txtVel.FontWeight = "Bold"
  $txtVel.Margin = "0,10,0,0"
  $txtVel.Visibility = "Collapsed"
  $cVel.Painel.Children.Add($txtVel) | Out-Null
  $painelRaiz.Children.Add($cVel.Cartao) | Out-Null

  $callbackVelocidade = {
    param($resultado, $erro)
    if ($erro -or "$resultado" -match "^Erro:") {
      $txtVel.Text = "Não consegui medir agora. $resultado"
      $txtVel.Foreground = $window.FindResource("BrushMuted")
      $txtVel.Visibility = "Visible"
      $setStatus.Invoke("Erro ao medir velocidade.") | Out-Null
      return
    }
    $txtVel.Text = "$resultado" -replace "`n", "   |   "
    $txtVel.Foreground = $window.FindResource("BrushGood")
    $txtVel.Visibility = "Visible"
    $setStatus.Invoke("Teste de velocidade concluído.") | Out-Null
  }.GetNewClosure()

  $btnVel.Add_Click({
    try {
      $setStatus.Invoke("Medindo velocidade em segundo plano (baixando/enviando dados reais)...") | Out-Null
      $trabalho = {
        param($caminhoScript)
        $saida = @(& $caminhoScript 2>&1)
        return ($saida -join "`n")
      }
      $emSegundoPlano.Invoke(@($btnVel), $trabalho, @((Join-Path $scriptsDir "_speed_test.ps1")), $callbackVelocidade, $setStatus)
    } catch {
      "ERRO no BtnInternetVelocidade: $_`n$($_.ScriptStackTrace)" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao medir velocidade -- veja o log.") | Out-Null
    }
  }.GetNewClosure())

  # --- Card: Downloads de launcher mais rapidos ---
  $cLauncher = New-CardBase
  $tLauncher = New-Object System.Windows.Controls.TextBlock
  $tLauncher.Text = "Downloads de Steam/Epic/Xbox mais rápidos"
  $tLauncher.Foreground = $window.FindResource("BrushInk")
  $tLauncher.FontWeight = "Bold"
  $tLauncher.FontSize = 15
  $tLauncher.Margin = "0,0,0,4"
  $cLauncher.Painel.Children.Add($tLauncher) | Out-Null

  $dLauncher = New-Object System.Windows.Controls.TextBlock
  $dLauncher.Text = "Causa muito comum de 'download lento' que quase ninguém sabe que existe: Steam, Epic Games e o app Xbox têm um limitador de banda PRÓPRIO, escondido nas configurações de cada um -- às vezes fica ligado sem querer (ou já veio assim). O Otimizador não mexe nesse arquivo direto (formato interno de cada launcher muda sem aviso, arriscado demais editar às cegas) -- mas abre o app certo e mostra exatamente onde procurar."
  $dLauncher.Foreground = $window.FindResource("BrushMuted")
  $dLauncher.TextWrapping = "Wrap"
  $dLauncher.FontSize = 12
  $dLauncher.Margin = "0,0,0,14"
  $cLauncher.Painel.Children.Add($dLauncher) | Out-Null

  function Add-LinhaLauncher($painelPai, $nomeApp, $instrucao, $acaoAbrir) {
    $linha = New-Object System.Windows.Controls.StackPanel
    $linha.Margin = "0,0,0,14"
    $tNome = New-Object System.Windows.Controls.TextBlock
    $tNome.Text = $nomeApp
    $tNome.Foreground = $window.FindResource("BrushInk")
    $tNome.FontWeight = "Bold"
    $tNome.FontSize = 13
    $linha.Children.Add($tNome) | Out-Null

    $tInstrucao = New-Object System.Windows.Controls.TextBlock
    $tInstrucao.Text = $instrucao
    $tInstrucao.Foreground = $window.FindResource("BrushMuted")
    $tInstrucao.TextWrapping = "Wrap"
    $tInstrucao.FontSize = 11.5
    $tInstrucao.Margin = "0,3,0,6"
    $linha.Children.Add($tInstrucao) | Out-Null

    $btnAbrir = New-Object System.Windows.Controls.Button
    $btnAbrir.Content = "Abrir $nomeApp"
    $btnAbrir.Style = $window.FindResource("BtnGhost")
    $btnAbrir.HorizontalAlignment = "Left"
    $btnAbrir.Add_Click($acaoAbrir)
    $linha.Children.Add($btnAbrir) | Out-Null

    $painelPai.Children.Add($linha) | Out-Null
  }

  Add-LinhaLauncher $cLauncher.Painel "Steam" `
    "Configurações > Downloads > 'Limitar taxa de download a' -- deixe em 'Sem limite'." `
    ({
      try {
        $exe = Test-SteamInstalado
        if ($exe) { Start-Process $exe } else { $setStatus.Invoke("Não encontrei o Steam instalado nessa máquina.") | Out-Null }
      } catch {}
    }.GetNewClosure())

  Add-LinhaLauncher $cLauncher.Painel "Epic Games Launcher" `
    "Ícone do perfil (canto superior direito) > Configurações > procure 'Velocidade máxima de download' -- deixe em 0 (sem limite)." `
    ({
      try {
        if (Test-EpicInstalado) { Start-Process "com.epicgames.launcher://" } else { $setStatus.Invoke("Não encontrei o Epic Games Launcher instalado nessa máquina.") | Out-Null }
      } catch {}
    }.GetNewClosure())

  Add-LinhaLauncher $cLauncher.Painel "App Xbox / Microsoft Store" `
    "Configurações do Windows > Apps > Configurações avançadas de apps -- procure por 'largura de banda' pra downloads de app/jogo em segundo plano." `
    ({
      try {
        if (-not (Open-XboxAppGUI)) { $setStatus.Invoke("Não encontrei o app Xbox instalado -- a configuração de banda fica em Configurações do Windows > Apps.") | Out-Null }
      } catch {}
    }.GetNewClosure())

  $painelRaiz.Children.Add($cLauncher.Cartao) | Out-Null

  # --- Card: Guia do roteador ---
  $cRoteador = New-CardBase
  $tRoteador = New-Object System.Windows.Controls.TextBlock
  $tRoteador.Text = "Guia do roteador (QoS, Wi-Fi, bufferbloat)"
  $tRoteador.Foreground = $window.FindResource("BrushInk")
  $tRoteador.FontWeight = "Bold"
  $tRoteador.FontSize = 15
  $tRoteador.Margin = "0,0,0,4"
  $cRoteador.Painel.Children.Add($tRoteador) | Out-Null

  $dRoteador = New-Object System.Windows.Controls.TextBlock
  $dRoteador.Text = "Dicas do lado do roteador que não dá pra automatizar por aqui (cada roteador tem painel diferente) -- QoS, canal de Wi-Fi, bufferbloat, e mais."
  $dRoteador.Foreground = $window.FindResource("BrushMuted")
  $dRoteador.TextWrapping = "Wrap"
  $dRoteador.FontSize = 12
  $dRoteador.Margin = "0,0,0,10"
  $cRoteador.Painel.Children.Add($dRoteador) | Out-Null

  $btnRoteador = New-Object System.Windows.Controls.Button
  $btnRoteador.Name = "BtnInternetGuiaRoteador"
  $btnRoteador.Content = "Ver guia do roteador"
  $btnRoteador.Style = $window.FindResource("BtnGhost")
  $btnRoteador.HorizontalAlignment = "Left"
  $cRoteador.Painel.Children.Add($btnRoteador) | Out-Null

  $txtRoteador = New-Object System.Windows.Controls.TextBlock
  $txtRoteador.TextWrapping = "Wrap"
  $txtRoteador.FontFamily = "Consolas"
  $txtRoteador.FontSize = 11.5
  $txtRoteador.Margin = "0,10,0,0"
  $txtRoteador.Foreground = $window.FindResource("BrushMuted")
  $txtRoteador.Visibility = "Collapsed"
  $cRoteador.Painel.Children.Add($txtRoteador) | Out-Null
  $painelRaiz.Children.Add($cRoteador.Cartao) | Out-Null

  $btnRoteador.Add_Click({
    try {
      & (Join-Path $scriptsDir "_guia_rede.ps1") 2>&1 | Out-Null
      $caminhoGuia = Join-Path (Split-Path $scriptsDir -Parent) "Guia-Rede.txt"
      if (Test-Path $caminhoGuia) {
        $txtRoteador.Text = Get-Content -LiteralPath $caminhoGuia -Raw
        $txtRoteador.Visibility = "Visible"
        $setStatus.Invoke("Guia gerado.") | Out-Null
      } else {
        $setStatus.Invoke("Não consegui gerar o guia.") | Out-Null
      }
    } catch {
      "ERRO no BtnInternetGuiaRoteador: $_" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao gerar guia -- veja o log.") | Out-Null
    }
  }.GetNewClosure())

  return $raiz
}
