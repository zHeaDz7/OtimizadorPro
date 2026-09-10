# OtimizadorPro GUI -- janela grafica (WPF) que reaproveita os scripts
# .ps1 ja testados no menu de texto (Otimizar.bat). E um programa NOVO,
# separado -- o menu de texto continua funcionando exatamente como
# antes. Continua tudo em PowerShell puro, sem compilar nada: o .xaml
# fica embutido como texto legivel dentro deste mesmo arquivo.
#
# Layout em sidebar (barra lateral de navegacao + area de conteudo),
# nao mais em abas horizontais -- cada secao (Instalar, Ajustes, etc)
# continua sendo construida por Build-XTab exatamente como antes, so
# muda ONDE esse conteudo aparece na tela.
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing

# Esconde a janela de console que o Windows cria sozinho quando um
# .ps1 roda via powershell.exe -- ela nunca mostra nada (toda a
# interface e a janela WPF abaixo), so ficava parada e vazia atras da
# GUI, confundindo com "travado". Isso NAO afeta as janelas novas que
# operacoes como DISM/SFC/robocopy abrem de proposito (essas sao
# processos separados, com titulo proprio, pra pessoa acompanhar).
try {
  Add-Type -Name JanelaConsole -Namespace OtimizadorPro -MemberDefinition '
    [System.Runtime.InteropServices.DllImport("kernel32.dll")]
    public static extern System.IntPtr GetConsoleWindow();
    [System.Runtime.InteropServices.DllImport("user32.dll")]
    public static extern bool ShowWindow(System.IntPtr hWnd, int nCmdShow);
  '
  $handleConsole = [OtimizadorPro.JanelaConsole]::GetConsoleWindow()
  if ($handleConsole -ne [IntPtr]::Zero) {
    [OtimizadorPro.JanelaConsole]::ShowWindow($handleConsole, 0) | Out-Null  # 0 = SW_HIDE
  }
} catch {}

$dir = $PSScriptRoot
$scriptsDir = Join-Path (Split-Path $dir -Parent) "scripts"

# ============================================================
# XAML -- janela principal + tema escuro (mesma paleta ambar/
# grafite do site do produto, pra manter a identidade visual)
# ============================================================
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Otimizador Pro" Height="820" Width="1360" MinHeight="640" MinWidth="1100"
        WindowStartupLocation="CenterScreen" Background="#14181A" FontFamily="Segoe UI">
  <Window.Resources>
    <SolidColorBrush x:Key="BrushBg" Color="#14181A"/>
    <SolidColorBrush x:Key="BrushSurface" Color="#1B2023"/>
    <SolidColorBrush x:Key="BrushSurface2" Color="#21272A"/>
    <SolidColorBrush x:Key="BrushBorder" Color="#313A3E"/>
    <SolidColorBrush x:Key="BrushInk" Color="#EDEFEF"/>
    <SolidColorBrush x:Key="BrushMuted" Color="#93A0A4"/>
    <SolidColorBrush x:Key="BrushAccent" Color="#E7A94C"/>
    <SolidColorBrush x:Key="BrushAccentInk" Color="#FFD699"/>
    <SolidColorBrush x:Key="BrushAccentSoft" Color="#3A2F1A"/>
    <SolidColorBrush x:Key="BrushGood" Color="#7FD19F"/>
    <SolidColorBrush x:Key="BrushBad" Color="#E08B73"/>

    <Style x:Key="NavItem" TargetType="RadioButton">
      <Setter Property="GroupName" Value="Navegacao"/>
      <Setter Property="Foreground" Value="{StaticResource BrushMuted}"/>
      <Setter Property="FontSize" Value="13.5"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Padding" Value="16,11"/>
      <Setter Property="Margin" Value="0,2"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="RadioButton">
            <Border x:Name="Bd" Background="Transparent" CornerRadius="6" BorderThickness="3,0,0,0" BorderBrush="Transparent" Padding="{TemplateBinding Padding}">
              <ContentPresenter VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsChecked" Value="True">
                <Setter TargetName="Bd" Property="Background" Value="{StaticResource BrushSurface2}"/>
                <Setter TargetName="Bd" Property="BorderBrush" Value="{StaticResource BrushAccent}"/>
                <Setter Property="Foreground" Value="{StaticResource BrushInk}"/>
              </Trigger>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter Property="Foreground" Value="{StaticResource BrushAccentInk}"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="BtnPrimary" TargetType="Button">
      <Setter Property="Background" Value="{StaticResource BrushAccent}"/>
      <Setter Property="Foreground" Value="#1B1200"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Padding" Value="16,9"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border Background="{TemplateBinding Background}" CornerRadius="6" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter Property="Opacity" Value="0.88"/>
              </Trigger>
              <Trigger Property="IsEnabled" Value="False">
                <Setter Property="Opacity" Value="0.4"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="BtnGhost" TargetType="Button" BasedOn="{StaticResource BtnPrimary}">
      <Setter Property="Background" Value="{StaticResource BrushSurface2}"/>
      <Setter Property="Foreground" Value="{StaticResource BrushInk}"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border Background="{TemplateBinding Background}" BorderBrush="{StaticResource BrushBorder}" BorderThickness="1" CornerRadius="6" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter Property="Background" Value="{StaticResource BrushBorder}"/>
              </Trigger>
              <Trigger Property="IsEnabled" Value="False">
                <Setter Property="Opacity" Value="0.4"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style TargetType="CheckBox">
      <Setter Property="Foreground" Value="{StaticResource BrushInk}"/>
      <Setter Property="FontSize" Value="13"/>
      <Setter Property="Margin" Value="0,3"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="CheckBox">
            <StackPanel Orientation="Horizontal">
              <Border x:Name="Box" Width="16" Height="16" CornerRadius="3" BorderThickness="1.4" BorderBrush="{StaticResource BrushMuted}" Background="Transparent" VerticalAlignment="Center">
                <Path x:Name="Check" Data="M2,7 L6,11 L14,2" Stroke="#1B1200" StrokeThickness="2" Visibility="Collapsed" StrokeStartLineCap="Round" StrokeEndLineCap="Round" StrokeLineJoin="Round"/>
              </Border>
              <ContentPresenter Margin="8,0,0,0" VerticalAlignment="Center"/>
            </StackPanel>
            <ControlTemplate.Triggers>
              <Trigger Property="IsChecked" Value="True">
                <Setter TargetName="Box" Property="Background" Value="{StaticResource BrushAccent}"/>
                <Setter TargetName="Box" Property="BorderBrush" Value="{StaticResource BrushAccent}"/>
                <Setter TargetName="Check" Property="Visibility" Value="Visible"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style TargetType="ToggleButton" x:Key="Switch">
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="ToggleButton">
            <Border x:Name="Track" Width="38" Height="20" CornerRadius="10" Background="{StaticResource BrushSurface2}" BorderBrush="{StaticResource BrushBorder}" BorderThickness="1">
              <Border x:Name="Knob" Width="14" Height="14" CornerRadius="7" Background="{StaticResource BrushMuted}" HorizontalAlignment="Left" Margin="2,0,0,0"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsChecked" Value="True">
                <Setter TargetName="Track" Property="Background" Value="{StaticResource BrushAccent}"/>
                <Setter TargetName="Track" Property="BorderBrush" Value="{StaticResource BrushAccent}"/>
                <Setter TargetName="Knob" Property="HorizontalAlignment" Value="Right"/>
                <Setter TargetName="Knob" Property="Margin" Value="0,0,2,0"/>
                <Setter TargetName="Knob" Property="Background" Value="#1B1200"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style TargetType="ScrollViewer">
      <Setter Property="VerticalScrollBarVisibility" Value="Auto"/>
    </Style>
    <Style TargetType="TextBox">
      <Setter Property="Background" Value="{StaticResource BrushSurface2}"/>
      <Setter Property="Foreground" Value="{StaticResource BrushInk}"/>
      <Setter Property="BorderBrush" Value="{StaticResource BrushBorder}"/>
      <Setter Property="Padding" Value="10,7"/>
      <Setter Property="CaretBrush" Value="{StaticResource BrushInk}"/>
    </Style>
    <Style x:Key="Rotulo" TargetType="TextBlock">
      <Setter Property="Foreground" Value="{StaticResource BrushMuted}"/>
      <Setter Property="FontSize" Value="11.5"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
    </Style>
  </Window.Resources>

  <DockPanel LastChildFill="True">
    <!-- Rodape de status (sempre visivel, largura total) -->
    <Border DockPanel.Dock="Bottom" Background="{StaticResource BrushSurface}" BorderBrush="{StaticResource BrushBorder}" BorderThickness="0,1,0,0" Padding="16,8">
      <TextBlock x:Name="TxtStatus" Text="Pronto." Foreground="{StaticResource BrushMuted}" FontSize="12"/>
    </Border>

    <Grid>
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="232"/>
        <ColumnDefinition Width="*"/>
      </Grid.ColumnDefinitions>

      <!-- Sidebar de navegacao -->
      <Border Grid.Column="0" Background="{StaticResource BrushSurface}" BorderBrush="{StaticResource BrushBorder}" BorderThickness="0,0,1,0">
        <DockPanel LastChildFill="True">
          <StackPanel DockPanel.Dock="Top" Orientation="Horizontal" Margin="20,22,20,26">
            <Ellipse Width="9" Height="9" Fill="{StaticResource BrushAccent}" Margin="0,0,10,0"/>
            <TextBlock Text="OTIMIZADOR PRO" Foreground="{StaticResource BrushInk}" FontWeight="Bold" FontSize="14"/>
          </StackPanel>
          <StackPanel Margin="10,0,10,10">
            <RadioButton x:Name="NavInstalar" Content="Instalar" Style="{StaticResource NavItem}" IsChecked="True"/>
            <RadioButton x:Name="NavAjustes" Content="Ajustes" Style="{StaticResource NavItem}"/>
            <RadioButton x:Name="NavConfig" Content="Config" Style="{StaticResource NavItem}"/>
            <RadioButton x:Name="NavUpdates" Content="Atualizações" Style="{StaticResource NavItem}"/>
            <RadioButton x:Name="NavWin11" Content="Criador Win11" Style="{StaticResource NavItem}"/>
            <RadioButton x:Name="NavDiagnostico" Content="Diagnóstico" Style="{StaticResource NavItem}"/>
            <RadioButton x:Name="NavInicializacao" Content="Inicialização" Style="{StaticResource NavItem}"/>
          </StackPanel>
        </DockPanel>
      </Border>

      <!-- Area de conteudo -->
      <DockPanel Grid.Column="1" LastChildFill="True">
        <Border DockPanel.Dock="Top" Background="{StaticResource BrushSurface}" BorderBrush="{StaticResource BrushBorder}" BorderThickness="0,0,0,1" Padding="24,16">
          <Grid>
            <Grid.ColumnDefinitions>
              <ColumnDefinition Width="*"/>
              <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <TextBlock x:Name="TxtTituloSecao" Text="Instalar" Foreground="{StaticResource BrushInk}" FontWeight="Bold" FontSize="18" VerticalAlignment="Center"/>
            <TextBox x:Name="TxtBusca" Grid.Column="1" Width="280" Padding="10,7" Text="Buscar (nome, categoria)..." Foreground="{StaticResource BrushMuted}"/>
          </Grid>
        </Border>
        <Border x:Name="AreaConteudo" Padding="24,20,24,20"/>
      </DockPanel>
    </Grid>
  </DockPanel>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# Referencias rapidas
$txtStatus = $window.FindName("TxtStatus")
function Set-Status([string]$msg) { $txtStatus.Text = $msg }

# "Bombeia" a fila do Dispatcher do WPF -- Start-Sleep sozinho trava a
# thread da UI e nunca deixa o evento de clique (agendado pelo
# AutomationPeer) ser processado de verdade. System.Windows.Forms.
# Application.DoEvents() bombeia a fila de mensagens do WinForms, NAO a
# do WPF -- o jeito certo no WPF e empurrar um DispatcherFrame. So usado
# nos testes automatizados (-TesteClicarBotao), nunca no uso normal.
function Wait-EventosUI([int]$ms) {
  $frame = New-Object System.Windows.Threading.DispatcherFrame
  $timer = New-Object System.Windows.Threading.DispatcherTimer
  $timer.Interval = [TimeSpan]::FromMilliseconds($ms)
  $timer.Add_Tick({ $frame.Continue = $false; $timer.Stop() }.GetNewClosure())
  $timer.Start()
  [System.Windows.Threading.Dispatcher]::PushFrame($frame)
}

# Roda trabalho pesado (winget, DISM, SFC, scripts que chamam programa
# externo) numa runspace separada, pra janela NUNCA travar/"nao
# responder" enquanto o usuario espera. $trabalho NAO pode tocar em
# nenhum objeto WPF (roda em outra thread) -- so recebe dados simples
# (caminho, texto, lista) via $argumentos e devolve dados simples. Quem
# atualiza a tela e o $aoTerminar, que roda de volta na thread da UI.
#
# Progresso em tempo real: dentro de $trabalho, a variavel $progresso
# (hashtable "sincronizada" -- thread-safe) ja esta disponivel sem
# precisar declarar em param(). Escrever $progresso.Texto = "mensagem"
# a qualquer momento faz a barra de status atualizar na hora (o timer
# abaixo confere a cada 200ms, mesmo antes do trabalho terminar).
function Invoke-EmSegundoPlano {
  param(
    [array]$botoesDesabilitar,
    [scriptblock]$trabalho,
    [array]$argumentos = @(),
    [scriptblock]$aoTerminar,
    [scriptblock]$setStatus = $null
  )

  foreach ($b in $botoesDesabilitar) { if ($b) { $b.IsEnabled = $false } }

  $progresso = [hashtable]::Synchronized(@{ Texto = $null })

  $runspace = [runspacefactory]::CreateRunspace()
  $runspace.ApartmentState = "MTA"
  $runspace.Open()
  $runspace.SessionStateProxy.SetVariable("progresso", $progresso)
  $runspace.SessionStateProxy.SetVariable("comandoVisivel", ${function:Invoke-ComandoVisivel})

  $ps = [powershell]::Create()
  $ps.Runspace = $runspace
  $ps.AddScript($trabalho) | Out-Null
  foreach ($a in $argumentos) { $ps.AddArgument($a) | Out-Null }

  $asyncResult = $ps.BeginInvoke()

  $ultimoTexto = $null
  $timer = New-Object System.Windows.Threading.DispatcherTimer
  $timer.Interval = [TimeSpan]::FromMilliseconds(200)
  $timer.Add_Tick({
    if ($setStatus -and $progresso.Texto -and $progresso.Texto -ne $ultimoTexto) {
      $ultimoTexto = $progresso.Texto
      $setStatus.Invoke($ultimoTexto) | Out-Null
    }
    if ($asyncResult.IsCompleted) {
      $timer.Stop()
      $resultado = $null
      $erro = $null
      try { $resultado = $ps.EndInvoke($asyncResult) } catch { $erro = $_ }
      $ps.Dispose()
      $runspace.Close()
      foreach ($b in $botoesDesabilitar) { if ($b) { $b.IsEnabled = $true } }
      try {
        $aoTerminar.Invoke($resultado, $erro)
      } catch {
        $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
        "ERRO no aoTerminar (Invoke-EmSegundoPlano): $_`n$($_.ScriptStackTrace)" | Out-File $debugLog -Append
      }
    }
  }.GetNewClosure())
  $timer.Start()
}

# Roda um programa externo (DISM, SFC, robocopy...) numa janela de
# console PROPRIA, NOVA e VISIVEL, com titulo dizendo o que esta
# rodando -- pra pessoa ver com os proprios olhos o comando de verdade
# acontecendo ao vivo (barra de progresso do proprio DISM/SFC etc), em
# vez de so confiar num texto de status. Antes essa janela nao existia
# e o programa "pintava" sem querer na janela de PowerShell elevada
# escondida atras da GUI, que fica em branco -- parecia travado. Agora
# ganha janela propria, so pra essa tarefa, que fecha sozinha quando
# termina.
function Invoke-ComandoVisivel {
  param([string]$titulo, [string]$exe, [string[]]$argumentos)
  $linhaComando = "title $titulo && `"$exe`" $($argumentos -join ' ')"
  $p = Start-Process -FilePath "cmd.exe" -ArgumentList @("/c", $linhaComando) -Wait -PassThru
  return @{ CodigoSaida = $p.ExitCode }
}

function Find-CheckBoxByContent($pai, [string]$texto) {
  $n = [System.Windows.Media.VisualTreeHelper]::GetChildrenCount($pai)
  for ($i = 0; $i -lt $n; $i++) {
    $filho = [System.Windows.Media.VisualTreeHelper]::GetChild($pai, $i)
    if ($filho -is [System.Windows.Controls.CheckBox] -and "$($filho.Content)" -eq $texto) { return $filho }
    $achado = Find-CheckBoxByContent $filho $texto
    if ($achado) { return $achado }
  }
  return $null
}

function Find-VisualChildByName($pai, [string]$nome) {
  $n = [System.Windows.Media.VisualTreeHelper]::GetChildrenCount($pai)
  for ($i = 0; $i -lt $n; $i++) {
    $filho = [System.Windows.Media.VisualTreeHelper]::GetChild($pai, $i)
    if ($filho -is [System.Windows.FrameworkElement] -and $filho.Name -eq $nome) { return $filho }
    $achado = Find-VisualChildByName $filho $nome
    if ($achado) { return $achado }
  }
  return $null
}

. (Join-Path $dir "modules\Tab-Ajustes.ps1")
$conteudoAjustes = Build-AjustesTab -window $window -scriptsDir $scriptsDir -setStatus ${function:Set-Status} -emSegundoPlano ${function:Invoke-EmSegundoPlano}

. (Join-Path $dir "modules\Tab-Diagnostico.ps1")
$conteudoDiagnostico = Build-DiagnosticoTab -window $window -scriptsDir $scriptsDir -setStatus ${function:Set-Status} -emSegundoPlano ${function:Invoke-EmSegundoPlano}

. (Join-Path $dir "modules\Tab-Inicializacao.ps1")
$conteudoInicializacao = Build-InicializacaoTab -window $window -scriptsDir $scriptsDir -setStatus ${function:Set-Status} -emSegundoPlano ${function:Invoke-EmSegundoPlano}

. (Join-Path $dir "modules\Tab-Instalar.ps1")
$conteudoInstalar = Build-InstalarTab -window $window -setStatus ${function:Set-Status} -emSegundoPlano ${function:Invoke-EmSegundoPlano}

. (Join-Path $dir "modules\Tab-Config.ps1")
$conteudoConfig = Build-ConfigTab -window $window -scriptsDir $scriptsDir -setStatus ${function:Set-Status} -emSegundoPlano ${function:Invoke-EmSegundoPlano}

. (Join-Path $dir "modules\Tab-Updates.ps1")
$conteudoUpdates = Build-UpdatesTab -window $window -setStatus ${function:Set-Status}

. (Join-Path $dir "modules\Tab-Win11.ps1")
$conteudoWin11 = Build-Win11Tab -window $window -setStatus ${function:Set-Status} -emSegundoPlano ${function:Invoke-EmSegundoPlano}

# --- Navegacao lateral -- troca o conteudo da area principal sem
# reconstruir nada (cada Build-XTab ja rodou uma unica vez acima; aqui
# so mostramos/escondemos qual arvore visual aparece). As chaves
# mantem o nome "TabX" por compatibilidade com os testes automatizados
# ja escritos (-TesteAba TabAjustes etc).
$areaConteudo = $window.FindName("AreaConteudo")
$txtTituloSecao = $window.FindName("TxtTituloSecao")

$secoes = [ordered]@{
  "TabInstalar"    = @{ Titulo = "Instalar"; Elemento = $conteudoInstalar; NomeNav = "NavInstalar" }
  "TabAjustes"     = @{ Titulo = "Ajustes"; Elemento = $conteudoAjustes; NomeNav = "NavAjustes" }
  "TabConfig"      = @{ Titulo = "Config"; Elemento = $conteudoConfig; NomeNav = "NavConfig" }
  "TabUpdates"     = @{ Titulo = "Atualizações"; Elemento = $conteudoUpdates; NomeNav = "NavUpdates" }
  "TabWin11"       = @{ Titulo = "Criador Win11"; Elemento = $conteudoWin11; NomeNav = "NavWin11" }
  "TabDiagnostico" = @{ Titulo = "Diagnóstico"; Elemento = $conteudoDiagnostico; NomeNav = "NavDiagnostico" }
  "TabInicializacao" = @{ Titulo = "Inicialização"; Elemento = $conteudoInicializacao; NomeNav = "NavInicializacao" }
}

function Mostrar-Secao([string]$chave) {
  $info = $secoes[$chave]
  if (-not $info) { return }
  $areaConteudo.Child = $info.Elemento
  $txtTituloSecao.Text = $info.Titulo
  $navBtn = $window.FindName($info.NomeNav)
  if ($navBtn -and -not $navBtn.IsChecked) { $navBtn.IsChecked = $true }
}

foreach ($chave in $secoes.Keys) {
  $navBtn = $window.FindName($secoes[$chave].NomeNav)
  $navBtn.Tag = $chave
  $navBtn.Add_Checked({
    param($s, $e)
    Mostrar-Secao $s.Tag
  })
}

Mostrar-Secao "TabInstalar"

$idxTeste = $args.IndexOf("-TesteAba")
if ($idxTeste -ge 0 -and $args.Count -gt ($idxTeste + 1)) {
  Mostrar-Secao $args[$idxTeste + 1]
}

$idxChk = $args.IndexOf("-TesteMarcarCheckbox")
$checkboxTeste = if ($idxChk -ge 0 -and $args.Count -gt ($idxChk + 1)) { $args[$idxChk + 1] } else { $null }

$idxEspera = $args.IndexOf("-TesteEsperaMs")
$esperaMs = if ($idxEspera -ge 0 -and $args.Count -gt ($idxEspera + 1)) { [int]$args[$idxEspera + 1] } else { 3000 }

$idxBtn = $args.IndexOf("-TesteClicarBotao")
$botoesTeste = @()
if ($idxBtn -ge 0) {
  for ($k = $idxBtn + 1; $k -lt $args.Count -and $args[$k] -notmatch "^-"; $k++) { $botoesTeste += $args[$k] }
}

if ($args -contains "-TesteScreenshot") {
  # Renderiza SO a arvore visual desta janela pra um bitmap em memoria --
  # nunca captura a tela real (CopyFromScreen pegaria qualquer coisa que
  # estivesse aberta no desktop do usuario, o que seria um problema serio
  # de privacidade -- ja aconteceu uma vez aqui, nao repete).
  $window.Add_ContentRendered({
    Start-Sleep -Milliseconds 300
    $window.UpdateLayout()
    $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
    if ($checkboxTeste) {
      try {
        $cb = Find-CheckBoxByContent $window $checkboxTeste
        "checkbox '$checkboxTeste' encontrado: $($null -ne $cb)" | Out-File $debugLog -Append
        if ($cb) { $cb.IsChecked = $true }
      } catch {
        "ERRO ao marcar checkbox: $_" | Out-File $debugLog -Append
      }
    }
    foreach ($nomeBtnTeste in $botoesTeste) {
      try {
        $botao = Find-VisualChildByName $window $nomeBtnTeste
        "[$nomeBtnTeste] botao encontrado: $($null -ne $botao)" | Out-File $debugLog -Append
        if ($botao -is [System.Windows.Controls.Primitives.ToggleButton]) {
          # RadioButton/CheckBox (ex: itens de navegacao da sidebar) --
          # nao derivam de Button, ButtonAutomationPeer nao serve.
          $peer = [System.Windows.Automation.Peers.RadioButtonAutomationPeer]::new($botao)
          $toggleProv = $peer.GetPattern([System.Windows.Automation.Peers.PatternInterface]::SelectionItem)
          if ($toggleProv) { $toggleProv.Select() } else { $botao.IsChecked = $true }
          "[$nomeBtnTeste] selecionado com sucesso" | Out-File $debugLog -Append
          Wait-EventosUI $esperaMs
          $window.UpdateLayout()
        } elseif ($botao) {
          $peer = [System.Windows.Automation.Peers.ButtonAutomationPeer]::new($botao)
          $invokeProv = $peer.GetPattern([System.Windows.Automation.Peers.PatternInterface]::Invoke)
          $invokeProv.Invoke()
          "[$nomeBtnTeste] invoke chamado com sucesso" | Out-File $debugLog -Append
          Wait-EventosUI $esperaMs
          $window.UpdateLayout()
        }
      } catch {
        "[$nomeBtnTeste] ERRO: $_" | Out-File $debugLog -Append
        "$($_.ScriptStackTrace)" | Out-File $debugLog -Append
      }
    }
    $largura = [int]$window.ActualWidth
    $altura = [int]$window.ActualHeight
    $rtb = New-Object System.Windows.Media.Imaging.RenderTargetBitmap $largura, $altura, 96, 96, ([System.Windows.Media.PixelFormats]::Pbgra32)
    $rtb.Render($window)
    $encoder = New-Object System.Windows.Media.Imaging.PngBitmapEncoder
    $encoder.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($rtb))
    $caminho = Join-Path $env:TEMP "otimizadorpro_gui_screenshot.png"
    $stream = [System.IO.File]::Open($caminho, [System.IO.FileMode]::Create)
    $encoder.Save($stream)
    $stream.Close()
    $window.Close()
  })
}

$window.ShowDialog() | Out-Null
