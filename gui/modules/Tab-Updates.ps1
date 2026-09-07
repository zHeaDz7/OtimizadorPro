# Aba "Atualizacoes" -- 3 perfis de Windows Update, igual o WinUtil:
# Recomendado (adia atualizacao de recurso, mantem seguranca em dia),
# Padrao do Windows (desfaz tudo isso), e Desativado (pausa por
# completo -- avisamos claramente o risco de seguranca).
function Build-UpdatesTab {
  param($window, $setStatus)

  $raiz = New-Object System.Windows.Controls.StackPanel
  $raiz.Margin = "0,0,20,0"

  $titulo = New-Object System.Windows.Controls.TextBlock
  $titulo.Text = "Perfis de Windows Update"
  $titulo.Foreground = $window.FindResource("BrushInk")
  $titulo.FontSize = 18
  $titulo.FontWeight = "Bold"
  $titulo.Margin = "0,0,0,4"
  $raiz.Children.Add($titulo) | Out-Null

  $sub = New-Object System.Windows.Controls.TextBlock
  $sub.Text = "Cada perfil troca a configuracao de update de uma vez. Reinicie o Windows depois de trocar."
  $sub.Foreground = $window.FindResource("BrushMuted")
  $sub.Margin = "0,0,0,20"
  $raiz.Children.Add($sub) | Out-Null

  $grade = New-Object System.Windows.Controls.Primitives.UniformGrid
  $grade.Columns = 3

  $wuPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
  $auPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

  function New-CartaoPerfil($window, $titulo, $desc, $itens, $corBotao, $acao, $nomeBotao) {
    $borda = New-Object System.Windows.Controls.Border
    $borda.BorderBrush = $window.FindResource("BrushBorder")
    $borda.BorderThickness = 1
    $borda.CornerRadius = 8
    $borda.Margin = "0,0,16,0"
    $borda.Padding = 18
    $painel = New-Object System.Windows.Controls.StackPanel
    $borda.Child = $painel

    $t = New-Object System.Windows.Controls.TextBlock
    $t.Text = $titulo
    $t.Foreground = $window.FindResource("BrushInk")
    $t.FontWeight = "Bold"
    $t.FontSize = 15
    $t.Margin = "0,0,0,6"
    $painel.Children.Add($t) | Out-Null

    $d = New-Object System.Windows.Controls.TextBlock
    $d.Text = $desc
    $d.Foreground = $window.FindResource("BrushMuted")
    $d.TextWrapping = "Wrap"
    $d.FontSize = 12.5
    $d.Margin = "0,0,0,12"
    $painel.Children.Add($d) | Out-Null

    foreach ($linha in $itens) {
      $li = New-Object System.Windows.Controls.TextBlock
      $li.Text = "- $linha"
      $li.Foreground = $window.FindResource("BrushMuted")
      $li.TextWrapping = "Wrap"
      $li.FontSize = 12
      $li.Margin = "0,0,0,4"
      $painel.Children.Add($li) | Out-Null
    }

    $btn = New-Object System.Windows.Controls.Button
    $btn.Name = $nomeBotao
    $btn.Content = "Aplicar este perfil"
    $btn.Style = $window.FindResource($corBotao)
    $btn.Margin = "0,14,0,0"
    $btn.Add_Click($acao)
    $painel.Children.Add($btn) | Out-Null

    return $borda
  }

  $acaoRecomendado = {
    try {
      if (-not (Test-Path $auPath)) { New-Item -Path $auPath -Force | Out-Null }
      if (-not (Test-Path $wuPath)) { New-Item -Path $wuPath -Force | Out-Null }
      Set-ItemProperty -Path $wuPath -Name "DeferFeatureUpdatesPeriodInDays" -Value 365 -Type DWord -Force
      Set-ItemProperty -Path $wuPath -Name "DeferQualityUpdatesPeriodInDays" -Value 4 -Type DWord -Force
      Set-ItemProperty -Path $wuPath -Name "ExcludeWUDriversInQualityUpdate" -Value 1 -Type DWord -Force
      Set-ItemProperty -Path $auPath -Name "NoAutoRebootWithLoggedOnUsers" -Value 1 -Type DWord -Force
      $setStatus.Invoke("on: perfil Recomendado aplicado. Reinicie pra valer.") | Out-Null
    } catch {
      $setStatus.Invoke("AVISO: precisa ser Administrador pra essa parte.") | Out-Null
    }
  }.GetNewClosure()

  $acaoPadrao = {
    try {
      Remove-Item -Path $wuPath -Recurse -Force -ErrorAction SilentlyContinue
      $setStatus.Invoke("on: politicas do OtimizadorPro removidas -- Windows Update volta ao padrao de fabrica.") | Out-Null
    } catch {
      $setStatus.Invoke("AVISO: precisa ser Administrador pra essa parte.") | Out-Null
    }
  }.GetNewClosure()

  $acaoDesativar = {
    try {
      if (-not (Test-Path $wuPath)) { New-Item -Path $wuPath -Force | Out-Null }
      if (-not (Test-Path $auPath)) { New-Item -Path $auPath -Force | Out-Null }
      Set-ItemProperty -Path $auPath -Name "NoAutoUpdate" -Value 1 -Type DWord -Force
      Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
      Set-Service -Name wuauserv -StartupType Disabled -ErrorAction SilentlyContinue
      $setStatus.Invoke("on: Windows Update pausado. AVISO: voce fica sem atualizacao de seguranca enquanto isso -- use 'Padrao do Windows' pra reverter quando quiser.") | Out-Null
    } catch {
      $setStatus.Invoke("AVISO: precisa ser Administrador pra essa parte.") | Out-Null
    }
  }.GetNewClosure()

  $cartao1 = New-CartaoPerfil $window "Recomendado" "Equilibrio entre seguranca e estabilidade." @(
    "Adia atualizacao de recurso por 365 dias"
    "Adia atualizacao de qualidade por 4 dias"
    "Exclui driver da atualizacao automatica"
    "Evita reiniciar sozinho com voce logado"
  ) "BtnPrimary" $acaoRecomendado "BtnUpdatePerfilRecomendado"

  $cartao2 = New-CartaoPerfil $window "Padrao do Windows" "Remove as politicas do OtimizadorPro, devolve controle total ao Windows." @(
    "Restaura comportamento padrao de fabrica"
    "Use pra desfazer o perfil Recomendado ou Desativado"
  ) "BtnGhost" $acaoPadrao "BtnUpdatePerfilPadrao"

  $cartao3 = New-CartaoPerfil $window "Desativar" "AVANCADO -- pausa atualizacao por completo." @(
    "Desliga o servico de Windows Update"
    "Voce PARA de receber correcao de seguranca"
    "So recomendado por um periodo curto e especifico"
  ) "BtnGhost" $acaoDesativar "BtnUpdatePerfilDesativar"

  $grade.Children.Add($cartao1) | Out-Null
  $grade.Children.Add($cartao2) | Out-Null
  $grade.Children.Add($cartao3) | Out-Null
  $raiz.Children.Add($grade) | Out-Null

  $sv = New-Object System.Windows.Controls.ScrollViewer
  $sv.Content = $raiz
  return $sv
}
