# Aba "Atualizações" -- 3 perfis de Windows Update, igual o WinUtil:
# Recomendado (adia atualização de recurso, mantém segurança em dia),
# Padrão do Windows (desfaz tudo isso), e Desativado (pausa por
# completo -- avisamos claramente o risco de segurança). Cada perfil
# mostra o que muda tecnicamente, pra pessoa saber exatamente o que
# vai acontecer antes de clicar.
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
  $sub.Text = "Cada perfil troca a configuração de update de uma vez. É sempre reversível -- clique em 'Padrão do Windows' a qualquer momento pra desfazer. Reinicie o Windows depois de trocar."
  $sub.Foreground = $window.FindResource("BrushMuted")
  $sub.TextWrapping = "Wrap"
  $sub.Margin = "0,0,0,20"
  $raiz.Children.Add($sub) | Out-Null

  $grade = New-Object System.Windows.Controls.Primitives.UniformGrid
  $grade.Columns = 3

  $wuPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
  $auPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

  function New-CartaoPerfil($window, $titulo, $desc, $itens, $corBotao, $acao, $nomeBotao, $detalhes) {
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
    $btn.Margin = "0,14,0,10"
    $btn.Add_Click($acao)
    $painel.Children.Add($btn) | Out-Null

    $expander = New-Object System.Windows.Controls.Expander
    $expander.Header = "Ver o que muda tecnicamente"
    $expander.Foreground = $window.FindResource("BrushMuted")
    $expander.FontSize = 11.5
    $txtDetalhes = New-Object System.Windows.Controls.TextBlock
    $txtDetalhes.Text = ($detalhes -join "`n")
    $txtDetalhes.Foreground = $window.FindResource("BrushMuted")
    $txtDetalhes.FontSize = 11
    $txtDetalhes.TextWrapping = "Wrap"
    $txtDetalhes.Margin = "0,8,0,0"
    $expander.Content = $txtDetalhes
    $painel.Children.Add($expander) | Out-Null

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
      $setStatus.Invoke("on: políticas do OtimizadorPro removidas -- Windows Update volta ao padrão de fábrica.") | Out-Null
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
      $setStatus.Invoke("on: Windows Update pausado. AVISO: você fica sem atualização de segurança enquanto isso -- use 'Padrão do Windows' pra reverter quando quiser.") | Out-Null
    } catch {
      $setStatus.Invoke("AVISO: precisa ser Administrador pra essa parte.") | Out-Null
    }
  }.GetNewClosure()

  $cartao1 = New-CartaoPerfil $window "Recomendado" "Equilíbrio entre segurança e estabilidade. Atualização de segurança continua chegando, só a de recurso (que costuma trazer bug novo) é adiada." @(
    "Adia atualização de recurso por 365 dias"
    "Adia atualização de qualidade (segurança) por só 4 dias -- tempo de deixar passar o pior bug"
    "Exclui driver da atualização automática (você escolhe quando trocar driver)"
    "Evita reiniciar sozinho enquanto você está logado/jogando"
  ) "BtnPrimary" $acaoRecomendado "BtnUpdatePerfilRecomendado" @(
    "Cria/edita HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate:"
    "  DeferFeatureUpdatesPeriodInDays = 365"
    "  DeferQualityUpdatesPeriodInDays = 4"
    "  ExcludeWUDriversInQualityUpdate = 1"
    "Cria/edita HKLM\...\WindowsUpdate\AU:"
    "  NoAutoRebootWithLoggedOnUsers = 1"
    "O serviço do Windows Update continua ligado o tempo todo."
  )

  $cartao2 = New-CartaoPerfil $window "Padrão do Windows" "Remove as políticas do OtimizadorPro, devolve controle total ao Windows." @(
    "Restaura comportamento padrão de fábrica"
    "Use pra desfazer o perfil Recomendado ou Desativado a qualquer momento"
  ) "BtnGhost" $acaoPadrao "BtnUpdatePerfilPadrao" @(
    "Apaga por completo a chave HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    "e tudo dentro dela (incluindo a subchave AU)."
    "Sem essas chaves, o Windows usa o comportamento de fábrica: baixa e instala"
    "atualização de recurso e de segurança no tempo normal da Microsoft."
  )

  $cartao3 = New-CartaoPerfil $window "Desativar" "AVANÇADO -- pausa atualização por completo. Só recomendado por um período curto e específico (ex: gravação/campeonato), nunca deixado ligado por muito tempo." @(
    "Desliga o serviço de Windows Update (wuauserv)"
    "Você PARA de receber TODA correção de segurança, não só a de recurso"
  ) "BtnGhost" $acaoDesativar "BtnUpdatePerfilDesativar" @(
    "Cria/edita HKLM\...\WindowsUpdate\AU: NoAutoUpdate = 1"
    "Para o serviço 'wuauserv' (Windows Update) e muda o tipo de"
    "inicialização dele pra Desabilitado -- não volta a rodar nem no"
    "próximo boot, até você aplicar 'Padrão do Windows' de novo."
  )

  $grade.Children.Add($cartao1) | Out-Null
  $grade.Children.Add($cartao2) | Out-Null
  $grade.Children.Add($cartao3) | Out-Null
  $raiz.Children.Add($grade) | Out-Null

  $avisoFinal = New-Object System.Windows.Controls.TextBlock
  $avisoFinal.Text = "Nenhum perfil desliga o Windows Defender. Antivírus continua funcionando em qualquer um dos três."
  $avisoFinal.Foreground = $window.FindResource("BrushMuted")
  $avisoFinal.FontSize = 11.5
  $avisoFinal.TextWrapping = "Wrap"
  $avisoFinal.Margin = "0,16,0,0"
  $raiz.Children.Add($avisoFinal) | Out-Null

  $sv = New-Object System.Windows.Controls.ScrollViewer
  $sv.Content = $raiz
  return $sv
}
