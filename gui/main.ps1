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

# _Icons.ps1 precisa estar carregado antes de qualquer icone da
# sidebar ser construido (feito logo apos o XamlReader.Load, mais
# abaixo neste arquivo).
. (Join-Path $dir "modules\_Icons.ps1")

# ============================================================
# Tema claro/escuro -- os dois conjuntos de cor completos. A sidebar
# fica sempre com um tom quente/escuro nos dois modos (decisao de
# design: contraste forte contra o conteudo, ver commit do redesign
# visual) -- so o CONTEUDO troca de claro pra escuro de verdade.
# BrushAccent (ambar da marca) e BrushOnAccent (texto em cima do
# ambar) ficam iguais nos dois -- e a cor de identidade do produto,
# nao muda com o tema.
# ============================================================
$Global:TemaClaro = [ordered]@{
  BrushBg              = "#F2EFE9"
  BrushSurface         = "#FFFFFF"
  BrushSurface2        = "#EAE5DC"
  BrushBorder          = "#DEDAD0"
  BrushInk             = "#26221C"
  BrushMuted           = "#736C60"
  BrushAccent          = "#E7A94C"
  BrushAccentInk       = "#8A5714"
  BrushAccentSoft      = "#F7E6C4"
  BrushGood            = "#2F9160"
  BrushBad             = "#C24E3A"
  BrushOnAccent        = "#241A0D"
  BrushSidebarBg       = "#211B14"
  BrushSidebarInk      = "#F3EEE6"
  BrushSidebarMuted    = "#9A907C"
  BrushSidebarHoverBg  = "#2D2620"
}
# Mesma paleta ambar/grafite que o app usava antes do redesign visual
# claro (recuperada do historico do git) -- reaproveitada aqui como o
# "modo escuro" oficial, ja testada e aprovada antes.
$Global:TemaEscuro = [ordered]@{
  BrushBg              = "#14181A"
  BrushSurface         = "#1B2023"
  BrushSurface2        = "#21272A"
  BrushBorder          = "#313A3E"
  BrushInk             = "#EDEFEF"
  BrushMuted           = "#93A0A4"
  BrushAccent          = "#E7A94C"
  BrushAccentInk       = "#FFD699"
  BrushAccentSoft      = "#3A2F1A"
  BrushGood            = "#7FD19F"
  BrushBad             = "#E08B73"
  BrushOnAccent        = "#1B1200"
  BrushSidebarBg       = "#1B2023"
  BrushSidebarInk      = "#EDEFEF"
  BrushSidebarMuted    = "#93A0A4"
  BrushSidebarHoverBg  = "#21272A"
}

# Preferencia salva fica em Logs\tema.txt (pasta que ja existe e ja e
# usada por outros scripts do projeto pra dado local que nao vai pro
# git -- ver .gitignore). Se nao existir ou der erro, cai no claro
# (comportamento de sempre) -- nunca trava a abertura do app por causa
# disso.
$caminhoPrefTema = Join-Path (Split-Path $dir -Parent) "Logs\tema.txt"
$Global:modoAtual = "claro"
try {
  if (Test-Path $caminhoPrefTema) {
    $lido = (Get-Content -LiteralPath $caminhoPrefTema -Raw -Encoding UTF8).Trim()
    if ($lido -eq "escuro") { $Global:modoAtual = "escuro" }
  }
} catch {}
$temaInicial = if ($Global:modoAtual -eq "escuro") { $Global:TemaEscuro } else { $Global:TemaClaro }

# ============================================================
# XAML -- janela principal + tema claro/escuro (ver hashtables acima).
# Os valores de cor abaixo vem interpolados de $temaInicial (a
# preferencia salva, ou claro por padrao) -- so pra pintar a janela
# certa desde o primeiro frame, sem flash de uma cor errada. Depois
# disso, toda troca de tema em tempo real passa por Set-Tema (mais
# abaixo), que troca os brushes no dicionario de recursos -- por isso
# todo StaticResource de cor abaixo virou DynamicResource: StaticResource
# resolve uma vez so e nunca mais muda, DynamicResource re-resolve
# sozinho sempre que o valor no dicionario troca (confirmado testando
# isolado: SolidColorBrush vindo de XAML fica read-only/"frozen" depois
# de carregado, entao mutar a cor destrava um erro -- trocar o brush
# inteiro no dicionario via DynamicResource e o jeito que funciona).
# ============================================================
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Otimizador Pro" Height="820" Width="1360" MinHeight="640" MinWidth="1100"
        WindowStartupLocation="CenterScreen" Background="{DynamicResource BrushBg}" FontFamily="Segoe UI">
  <Window.Resources>
    <SolidColorBrush x:Key="BrushBg" Color="$($temaInicial.BrushBg)"/>
    <SolidColorBrush x:Key="BrushSurface" Color="$($temaInicial.BrushSurface)"/>
    <SolidColorBrush x:Key="BrushSurface2" Color="$($temaInicial.BrushSurface2)"/>
    <SolidColorBrush x:Key="BrushBorder" Color="$($temaInicial.BrushBorder)"/>
    <SolidColorBrush x:Key="BrushInk" Color="$($temaInicial.BrushInk)"/>
    <SolidColorBrush x:Key="BrushMuted" Color="$($temaInicial.BrushMuted)"/>
    <SolidColorBrush x:Key="BrushAccent" Color="$($temaInicial.BrushAccent)"/>
    <SolidColorBrush x:Key="BrushAccentInk" Color="$($temaInicial.BrushAccentInk)"/>
    <SolidColorBrush x:Key="BrushAccentSoft" Color="$($temaInicial.BrushAccentSoft)"/>
    <SolidColorBrush x:Key="BrushGood" Color="$($temaInicial.BrushGood)"/>
    <SolidColorBrush x:Key="BrushBad" Color="$($temaInicial.BrushBad)"/>
    <SolidColorBrush x:Key="BrushOnAccent" Color="$($temaInicial.BrushOnAccent)"/>

    <!-- Sidebar continua escura/quente de proposito nos dois temas,
         contraste com o conteudo (que troca de claro pra escuro) -->
    <SolidColorBrush x:Key="BrushSidebarBg" Color="$($temaInicial.BrushSidebarBg)"/>
    <SolidColorBrush x:Key="BrushSidebarInk" Color="$($temaInicial.BrushSidebarInk)"/>
    <SolidColorBrush x:Key="BrushSidebarMuted" Color="$($temaInicial.BrushSidebarMuted)"/>
    <SolidColorBrush x:Key="BrushSidebarHoverBg" Color="$($temaInicial.BrushSidebarHoverBg)"/>

    <Style x:Key="NavItem" TargetType="RadioButton">
      <Setter Property="GroupName" Value="Navegacao"/>
      <Setter Property="Foreground" Value="{DynamicResource BrushSidebarMuted}"/>
      <Setter Property="FontSize" Value="13.5"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Padding" Value="14,10"/>
      <Setter Property="Margin" Value="4,3"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="RadioButton">
            <Border x:Name="Bd" Background="Transparent" CornerRadius="10" Padding="{TemplateBinding Padding}">
              <ContentPresenter VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <!-- IsMouseOver vem ANTES de IsChecked de proposito: quando os
                   dois estao ativos ao mesmo tempo (mouse sobre o item ja
                   selecionado), o trigger listado por ULTIMO e que vence no
                   WPF, entao IsChecked (pill ambar) precisa ficar depois,
                   senao passar o mouse no item ativo apagaria o pill. -->
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="Bd" Property="Background" Value="{DynamicResource BrushSidebarHoverBg}"/>
                <Setter Property="Foreground" Value="{DynamicResource BrushSidebarInk}"/>
              </Trigger>
              <Trigger Property="IsChecked" Value="True">
                <Setter TargetName="Bd" Property="Background" Value="{DynamicResource BrushAccent}"/>
                <Setter Property="Foreground" Value="{DynamicResource BrushOnAccent}"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="BtnPrimary" TargetType="Button">
      <Setter Property="Background" Value="{DynamicResource BrushAccent}"/>
      <Setter Property="Foreground" Value="{DynamicResource BrushOnAccent}"/>
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
      <Setter Property="Background" Value="{DynamicResource BrushSurface2}"/>
      <Setter Property="Foreground" Value="{DynamicResource BrushInk}"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border Background="{TemplateBinding Background}" BorderBrush="{DynamicResource BrushBorder}" BorderThickness="1" CornerRadius="6" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter Property="Background" Value="{DynamicResource BrushBorder}"/>
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
      <Setter Property="Foreground" Value="{DynamicResource BrushInk}"/>
      <Setter Property="FontSize" Value="13"/>
      <Setter Property="Margin" Value="0,3"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="CheckBox">
            <StackPanel Orientation="Horizontal">
              <Border x:Name="Box" Width="16" Height="16" CornerRadius="3" BorderThickness="1.4" BorderBrush="{DynamicResource BrushMuted}" Background="Transparent" VerticalAlignment="Center">
                <Path x:Name="Check" Data="M2,7 L6,11 L14,2" Stroke="{DynamicResource BrushOnAccent}" StrokeThickness="2" Visibility="Collapsed" StrokeStartLineCap="Round" StrokeEndLineCap="Round" StrokeLineJoin="Round"/>
              </Border>
              <ContentPresenter Margin="8,0,0,0" VerticalAlignment="Center"/>
            </StackPanel>
            <ControlTemplate.Triggers>
              <Trigger Property="IsChecked" Value="True">
                <Setter TargetName="Box" Property="Background" Value="{DynamicResource BrushAccent}"/>
                <Setter TargetName="Box" Property="BorderBrush" Value="{DynamicResource BrushAccent}"/>
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
            <Border x:Name="Track" Width="38" Height="20" CornerRadius="10" Background="{DynamicResource BrushSurface2}" BorderBrush="{DynamicResource BrushBorder}" BorderThickness="1">
              <Border x:Name="Knob" Width="14" Height="14" CornerRadius="7" Background="{DynamicResource BrushMuted}" HorizontalAlignment="Left" Margin="2,0,0,0"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsChecked" Value="True">
                <Setter TargetName="Track" Property="Background" Value="{DynamicResource BrushAccent}"/>
                <Setter TargetName="Track" Property="BorderBrush" Value="{DynamicResource BrushAccent}"/>
                <Setter TargetName="Knob" Property="HorizontalAlignment" Value="Right"/>
                <Setter TargetName="Knob" Property="Margin" Value="0,0,2,0"/>
                <Setter TargetName="Knob" Property="Background" Value="{DynamicResource BrushOnAccent}"/>
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
      <Setter Property="Background" Value="{DynamicResource BrushSurface2}"/>
      <Setter Property="Foreground" Value="{DynamicResource BrushInk}"/>
      <Setter Property="BorderBrush" Value="{DynamicResource BrushBorder}"/>
      <Setter Property="Padding" Value="10,7"/>
      <Setter Property="CaretBrush" Value="{DynamicResource BrushInk}"/>
    </Style>
    <Style x:Key="Rotulo" TargetType="TextBlock">
      <Setter Property="Foreground" Value="{DynamicResource BrushMuted}"/>
      <Setter Property="FontSize" Value="11.5"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
    </Style>
  </Window.Resources>

  <DockPanel LastChildFill="True">
    <!-- Rodape de status (sempre visivel, largura total) -->
    <Border DockPanel.Dock="Bottom" Background="{DynamicResource BrushSurface}" BorderBrush="{DynamicResource BrushBorder}" BorderThickness="0,1,0,0" Padding="16,8">
      <TextBlock x:Name="TxtStatus" Text="Pronto." Foreground="{DynamicResource BrushMuted}" FontSize="12"/>
    </Border>

    <Grid>
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="208"/>
        <ColumnDefinition Width="*"/>
      </Grid.ColumnDefinitions>

      <!-- Sidebar de navegacao -->
      <Border Grid.Column="0" Background="{DynamicResource BrushSidebarBg}">
        <DockPanel LastChildFill="True">
          <StackPanel DockPanel.Dock="Top" Orientation="Horizontal" Margin="20,22,20,26">
            <Ellipse Width="9" Height="9" Fill="{DynamicResource BrushAccent}" Margin="0,0,10,0"/>
            <TextBlock Text="OTIMIZADOR PRO" Foreground="{DynamicResource BrushSidebarInk}" FontWeight="Bold" FontSize="13.5"/>
          </StackPanel>
          <StackPanel Margin="10,0,10,10">
            <!-- Conteudo (icone+rotulo) de cada item e montado em codigo
                 logo apos o XamlReader.Load, mais abaixo. So o
                 x:Name/Style/IsChecked ficam aqui no XAML. -->
            <RadioButton x:Name="NavInstalar" Style="{StaticResource NavItem}" IsChecked="True"/>
            <RadioButton x:Name="NavAjustes" Style="{StaticResource NavItem}"/>
            <RadioButton x:Name="NavConfig" Style="{StaticResource NavItem}"/>
            <RadioButton x:Name="NavUpdates" Style="{StaticResource NavItem}"/>
            <RadioButton x:Name="NavWin11" Style="{StaticResource NavItem}"/>
            <RadioButton x:Name="NavDiagnostico" Style="{StaticResource NavItem}"/>
            <RadioButton x:Name="NavInicializacao" Style="{StaticResource NavItem}"/>
            <RadioButton x:Name="NavGPU" Style="{StaticResource NavItem}"/>
            <RadioButton x:Name="NavPerfis" Style="{StaticResource NavItem}"/>
            <RadioButton x:Name="NavInternet" Style="{StaticResource NavItem}"/>
          </StackPanel>
        </DockPanel>
      </Border>

      <!-- Area de conteudo -->
      <DockPanel Grid.Column="1" LastChildFill="True">
        <Border DockPanel.Dock="Top" Background="{DynamicResource BrushSurface}" BorderBrush="{DynamicResource BrushBorder}" BorderThickness="0,0,0,1" Padding="24,16">
          <Grid>
            <Grid.ColumnDefinitions>
              <ColumnDefinition Width="*"/>
              <ColumnDefinition Width="Auto"/>
              <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <TextBlock x:Name="TxtTituloSecao" Text="Instalar" Foreground="{DynamicResource BrushInk}" FontWeight="Bold" FontSize="18" VerticalAlignment="Center"/>
            <Border Grid.Column="1" Background="{DynamicResource BrushSurface2}" BorderBrush="{DynamicResource BrushBorder}" BorderThickness="1" CornerRadius="8" Padding="10,0" Width="280">
              <StackPanel Orientation="Horizontal">
                <Viewbox Width="14" Height="14" Margin="0,0,8,0">
                  <Canvas Width="24" Height="24">
                    <Ellipse Canvas.Left="4" Canvas.Top="4" Width="12" Height="12" Stroke="{DynamicResource BrushMuted}" StrokeThickness="1.8"/>
                    <Line X1="14.5" Y1="14.5" X2="20" Y2="20" Stroke="{DynamicResource BrushMuted}" StrokeThickness="1.8" StrokeStartLineCap="Round"/>
                  </Canvas>
                </Viewbox>
                <TextBox x:Name="TxtBusca" Width="220" Padding="0,7" Text="Buscar (nome, categoria)..." Foreground="{DynamicResource BrushMuted}" Background="Transparent" BorderThickness="0"/>
              </StackPanel>
            </Border>
            <Button x:Name="BtnAlternarTema" Grid.Column="2" Style="{StaticResource BtnGhost}" Width="38" Height="38" Padding="0" Margin="10,0,0,0"/>
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

# --- Icone + rotulo de cada item da sidebar --------------------------
# O RadioButton.Content vira um StackPanel horizontal (icone + texto),
# montado aqui em codigo (nao no XAML) -- assim o icone e um objeto
# Shape de verdade (New-Icone, ver _Icons.ps1), sem precisar interpolar
# geometria de path dentro do heredoc do XAML.
#
# O estado "ativo" muda o FUNDO do item via trigger no proprio Style
# (NavItem, no XAML acima) -- mas a COR DO ICONE precisa ser trocada
# aqui em codigo, porque Shape.Stroke nao e propriedade herdada do
# Foreground do RadioButton (diferente de TextBlock, que ja segue
# sozinho). Set-IconeNavCor faz essa troca sempre que a selecao muda
# (chamado de dentro de Mostrar-Secao, mais abaixo).
$Global:IconesNav = @{
  NavInstalar       = "instalar"
  NavAjustes        = "ajustes"
  NavConfig         = "config"
  NavUpdates        = "atualizacoes"
  NavWin11          = "win11"
  NavDiagnostico    = "diagnostico"
  NavInicializacao  = "inicializacao"
  NavGPU            = "gpu"
  NavPerfis         = "perfis"
  NavInternet       = "internet"
}
$rotulosNav = @{
  NavInstalar       = "Instalar"
  NavAjustes        = "Ajustes"
  NavConfig         = "Config"
  NavUpdates        = "Atualizações"
  NavWin11          = "Criador Win11"
  NavDiagnostico    = "Diagnóstico"
  NavInicializacao  = "Inicialização"
  NavGPU            = "Placa de Vídeo"
  NavPerfis         = "Perfis"
  NavInternet       = "Internet"
}
$Global:ViewboxesNav = @{}

function Set-IconeNavCor($viewbox, $corBrush) {
  if (-not $viewbox) { return }
  $tela = $viewbox.Child
  foreach ($filho in $tela.Children) {
    if ($filho -isnot [System.Windows.Shapes.Shape]) { continue }
    if ($null -ne $filho.Stroke) { $filho.Stroke = $corBrush }
    if ($filho.Fill -is [System.Windows.Media.SolidColorBrush] -and $filho.Fill.Color.A -ne 0) { $filho.Fill = $corBrush }
  }
}

foreach ($nomeNav in $Global:IconesNav.Keys) {
  $btnNav = $window.FindName($nomeNav)
  $conteudoNav = New-Object System.Windows.Controls.StackPanel
  $conteudoNav.Orientation = "Horizontal"
  $iconeNav = New-Icone $window $Global:IconesNav[$nomeNav] 17 $window.FindResource("BrushSidebarMuted")
  $iconeNav.Margin = "0,0,12,0"
  $Global:ViewboxesNav[$nomeNav] = $iconeNav
  $conteudoNav.Children.Add($iconeNav) | Out-Null
  $txtNav = New-Object System.Windows.Controls.TextBlock
  $txtNav.Text = $rotulosNav[$nomeNav]
  $txtNav.VerticalAlignment = "Center"
  $conteudoNav.Children.Add($txtNav) | Out-Null
  $btnNav.Content = $conteudoNav
}

# --- Alternar tema claro/escuro ---------------------------------------
# O botao mostra o icone do modo que ele VAI ATIVAR se clicado (lua =
# "clique pra ir pro escuro", sol = "clique pra ir pro claro") -- padrao
# comum de toggle. O icone tambem precisa ser reconstruido a cada troca
# (mesmo motivo do Set-IconeNavCor: Shape.Stroke/Fill nao acompanha
# Foreground sozinho).
$btnAlternarTema = $window.FindName("BtnAlternarTema")

function ConvertTo-Brush([string]$hex) {
  $brush = New-Object System.Windows.Media.SolidColorBrush
  $brush.Color = [System.Windows.Media.ColorConverter]::ConvertFromString($hex)
  return $brush
}

# Os dois icones (sol e lua) sao construidos UMA UNICA VEZ, sobrepostos
# no mesmo Content do botao (um Grid com os dois), e so a Visibility
# troca a cada clique -- nunca mais reconstruimos a arvore visual do
# botao depois disso.
#
# Bug real encontrado com clique de MOUSE DE VERDADE (o harness de
# teste automatizado, que dispara o evento Click direto via
# AutomationPeer.Invoke() sem simular mouse nenhum, nunca reproduziu
# isso): trocar o CONTEUDO de um botao enquanto o cursor ainda esta em
# cima dele, no meio do proprio processamento do evento Click
# (MouseLeftButtonDown captura o mouse -> MouseLeftButtonUp solta a
# captura e decide se dispara Click conferindo se o mouse ainda esta
# por cima do elemento), pode deixar o hit-testing desatualizado ate o
# proximo MouseMove de verdade -- que pode nao acontecer entre dois
# cliques rapidos no mesmo pixel, fazendo o SEGUNDO clique simplesmente
# nao disparar Click nenhum (sem excecao, sem log -- bate exatamente
# com "escuro -> claro funciona, mas nao volta pra escuro"). So
# alternar Visibility de elementos que ja existem evita esse problema
# pela raiz -- nao tem mais troca de arvore visual embaixo do cursor,
# entao nao tem como o hit-testing ficar desatualizado.
$script:iconeSol = New-Icone $window "sol" 17 $window.FindResource("BrushInk")
$script:iconeLua = New-Icone $window "lua" 17 $window.FindResource("BrushInk")
$painelIconeTema = New-Object System.Windows.Controls.Grid
$painelIconeTema.Children.Add($script:iconeSol) | Out-Null
$painelIconeTema.Children.Add($script:iconeLua) | Out-Null
$btnAlternarTema.Content = $painelIconeTema

function Atualizar-IconeTema {
  # Recolore os dois (Stroke/Fill sao fixados na hora que o icone foi
  # construido, nao acompanham BrushInk sozinhos -- mesmo motivo do
  # Set-IconeNavCor, reaproveitado aqui) e so alterna qual fica visivel.
  $corInk = $window.FindResource("BrushInk")
  Set-IconeNavCor $script:iconeSol $corInk
  Set-IconeNavCor $script:iconeLua $corInk
  if ($Global:modoAtual -eq "escuro") {
    $script:iconeSol.Visibility = "Visible"
    $script:iconeLua.Visibility = "Collapsed"
  } else {
    $script:iconeSol.Visibility = "Collapsed"
    $script:iconeLua.Visibility = "Visible"
  }
}

# Troca TODAS as cores do app em tempo real (sidebar, botoes, checkbox,
# switch, e o conteudo de cada aba) -- ver o comentario grande antes do
# heredoc do XAML pra entender por que precisa desse jeito (StaticResource
# nao atualiza sozinho, e o brush original do XAML fica travado/"frozen"
# depois de carregado, entao so da pra trocar o brush INTEIRO no
# dicionario, nunca so a cor dele). O conteudo de cada aba (cards, texto)
# e construido lendo $window.FindResource(...) na hora -- por isso
# reconstruir cada aba do zero (Reconstruir-Conteudo, definida mais
# abaixo) e o jeito confiavel de fazer ela pegar as cores novas tambem,
# em vez de tentar re-colorir centenas de elementos ja existentes um por
# um.
#
# A troca de cor em si (rapida, nao mexe em arvore visual nenhuma) roda
# na hora. Reconstruir-Conteudo (pesado -- reconstroi 10 abas) e ADIADO
# via Dispatcher.BeginInvoke em prioridade Background: assim o evento
# Click termina de processar (mouse solto, captura liberada) igual a
# qualquer clique normal, ANTES de qualquer reconstrucao pesada da
# arvore visual comecar -- protecao extra contra qualquer instabilidade
# de clique-durante-troca-de-UI, alem do que ja foi resolvido no item 1.
function Set-Tema([string]$modo) {
  $valores = if ($modo -eq "escuro") { $Global:TemaEscuro } else { $Global:TemaClaro }
  foreach ($chave in $valores.Keys) {
    # .set_Item() explicito, NUNCA o indexador $window.Resources[$chave] = ...
    # -- confirmado com teste isolado que o indexador do PowerShell tem um
    # bug real de dynamic-binding contra ResourceDictionary aqui: mesmo
    # passando um SolidColorBrush valido e destravado (IsFrozen=False,
    # tipo certo confirmado), o indexador lanca "'#FF14181A' nao e um
    # valor valido pra propriedade Background" na hora que o WPF invalida
    # os DynamicResource dependentes. set_Item() com o mesmo objeto
    # funciona sem erro -- so o caminho do indexador que quebra.
    $novoBrush = ConvertTo-Brush $valores[$chave]
    $window.Resources.set_Item($chave, $novoBrush)
  }
  $Global:modoAtual = $modo
  Atualizar-IconeTema

  try {
    $pastaLogs = Split-Path $caminhoPrefTema -Parent
    if (-not (Test-Path $pastaLogs)) { New-Item -ItemType Directory -Path $pastaLogs -Force | Out-Null }
    [System.IO.File]::WriteAllText($caminhoPrefTema, $modo, (New-Object System.Text.UTF8Encoding($false)))
  } catch {}

  if (Get-Command Reconstruir-Conteudo -ErrorAction SilentlyContinue) {
    $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
    $window.Dispatcher.BeginInvoke([action]{
      try {
        Reconstruir-Conteudo
        Mostrar-Secao $Global:chaveSecaoAtual
      } catch {
        "ERRO ao reconstruir conteudo apos troca de tema: $_`n$($_.ScriptStackTrace)" | Out-File $debugLog -Append
      }
    }.GetNewClosure(), [System.Windows.Threading.DispatcherPriority]::Background) | Out-Null
  }
}

# $modoAtual e $chaveSecaoAtual sao $Global: (nao $script:) DE PROPOSITO.
# Bug real confirmado nesse projeto: um scriptblock que passa por
# .GetNewClosure() (como o Add_Click do botao de tema, criado UMA vez e
# reusado em TODO clique, e o rebuild adiado dentro de Set-Tema, criado
# de novo a cada troca) ganha seu proprio pseudo-modulo isolado -- uma
# leitura de "$script:algo" la dentro NAO enxerga a variavel de script
# de verdade do main.ps1: ou fica presa pra sempre no valor que tinha na
# hora que o closure foi criado (foi assim que o botao de tema, quando
# clicado duas vezes seguidas, sempre recalculava o MESMO proximo modo
# -- nunca alternava de verdade, exatamente o bug relatado de "nao volta
# pro escuro"), ou fica simplesmente vazia (foi assim que Mostrar-Secao
# recebia uma chave vazia ao trocar de tema, nao achava nenhuma secao e
# saia sem fazer nada -- os cartoes/textos construidos em codigo ficavam
# presos na cor do tema anterior). "$Global:" e o unico escopo que
# continua sendo o MESMO de verdade visto de dentro de qualquer closure
# -- confirmado com teste isolado depois de achar o bug. NUNCA volte a
# usar "$script:" pra esse tipo de estado lido/escrito de dentro de um
# scriptblock com .GetNewClosure().
$btnAlternarTema.Add_Click({
  try {
    $novoModo = if ($Global:modoAtual -eq "escuro") { "claro" } else { "escuro" }
    Set-Tema $novoModo
  } catch {
    $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
    "ERRO no BtnAlternarTema: $_`n$($_.ScriptStackTrace)`n$($_.Exception.ToString())" | Out-File $debugLog -Append
  }
}.GetNewClosure())

Atualizar-IconeTema

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

# So usada em -TesteRolarAteTexto, pra achar um TextBlock/CheckBox pelo
# texto visivel e trazer ele pra vista antes da foto -- util pra
# verificar item especifico numa lista longa sem depender de scroll cego.
function Find-VisualChildByText($pai, [string]$texto) {
  $n = [System.Windows.Media.VisualTreeHelper]::GetChildrenCount($pai)
  for ($i = 0; $i -lt $n; $i++) {
    $filho = [System.Windows.Media.VisualTreeHelper]::GetChild($pai, $i)
    $conteudo = $null
    if ($filho -is [System.Windows.Controls.TextBlock]) { $conteudo = $filho.Text }
    elseif ($filho -is [System.Windows.Controls.ContentControl]) { $conteudo = "$($filho.Content)" }
    if ($conteudo -and $conteudo -match [regex]::Escape($texto)) { return $filho }
    $achado = Find-VisualChildByText $filho $texto
    if ($achado) { return $achado }
  }
  return $null
}

# So usada em -TesteScreenshot, pra rolar todo ScrollViewer visivel ate o
# fim antes de tirar a foto -- senao o conteudo que fica depois do botao
# clicado (ex: resultado de um card no fim da aba) sai cortado da imagem.
function Rolar-ScrollViewersParaFim($pai) {
  $n = [System.Windows.Media.VisualTreeHelper]::GetChildrenCount($pai)
  for ($i = 0; $i -lt $n; $i++) {
    $filho = [System.Windows.Media.VisualTreeHelper]::GetChild($pai, $i)
    if ($filho -is [System.Windows.Controls.ScrollViewer]) { $filho.ScrollToBottom() }
    Rolar-ScrollViewersParaFim $filho
  }
}

# Dot-source dos 10 modulos de aba -- UMA UNICA VEZ, aqui no nivel raiz
# do script (nunca dentro de uma funcao). Isso e CRITICO: toda funcao de
# "nivel de modulo" que cada Tab-*.ps1 define (ex: Invoke-Perfil,
# Open-NvidiaAppGUI) so fica visivel PRA SEMPRE se for definida aqui.
# Bug real confirmado (com teste isolado E com o app de verdade -- clicar
# "Aplicar este perfil" lancava "Invoke-Perfil nao e reconhecido"): se
# esse dot-source rodasse DENTRO de Reconstruir-Conteudo (uma funcao),
# toda funcao de nivel de modulo ficava presa no escopo TRANSITORIO
# daquela chamada de funcao -- e um closure de botao (Add_Click) criado
# durante essa chamada NAO consegue mais resolver o nome dessa funcao
# depois que Reconstruir-Conteudo ja retornou (GetNewClosure() so
# "engarrafa" VARIAVEL do escopo, nunca funcao aninhada do escopo pai --
# mesma regra ja documentada varias vezes nesse projeto, so que dessa vez
# o "escopo pai" era a propria chamada de Reconstruir-Conteudo). Por
# isso Reconstruir-Conteudo (mais abaixo) so CHAMA as funcoes Build-XTab
# -- nao dot-sourca nada.
. (Join-Path $dir "modules\Tab-Ajustes.ps1")
. (Join-Path $dir "modules\Tab-Diagnostico.ps1")
. (Join-Path $dir "modules\Tab-Inicializacao.ps1")
. (Join-Path $dir "modules\Tab-GPU.ps1")
. (Join-Path $dir "modules\Tab-Perfis.ps1")
. (Join-Path $dir "modules\Tab-Internet.ps1")
. (Join-Path $dir "modules\Tab-Instalar.ps1")
. (Join-Path $dir "modules\Tab-Config.ps1")
. (Join-Path $dir "modules\Tab-Updates.ps1")
. (Join-Path $dir "modules\Tab-Win11.ps1")

# Constroi (ou RE-constroi) o conteudo das 10 abas do zero, lendo as
# cores atuais do dicionario de recursos ($window.FindResource dentro de
# cada Build-XTab). Chamada uma vez no arranque, e de novo dentro de
# Set-Tema toda vez que o tema troca -- e o jeito confiavel de fazer
# TODO o conteudo de aba (cards, texto, tudo construido em codigo, sem
# DynamicResource) pegar a cor nova, sem precisar re-colorir centenas de
# elementos ja existentes um por um. Efeito colateral aceito: dado
# transitorio de uma aba (ex: resultado do "Verificar meu PC agora" no
# Diagnostico) reseta ao trocar de tema -- preferencias salvas em disco
# (perfil de GPU, apps instalados etc) continuam lendo normal, so o que
# só existia na tela em memoria some.
function Reconstruir-Conteudo {
  param([bool]$primeiraCarga = $false)

  $conteudoAjustes = Build-AjustesTab -window $window -scriptsDir $scriptsDir -setStatus ${function:Set-Status} -emSegundoPlano ${function:Invoke-EmSegundoPlano}
  $conteudoDiagnostico = Build-DiagnosticoTab -window $window -scriptsDir $scriptsDir -setStatus ${function:Set-Status} -emSegundoPlano ${function:Invoke-EmSegundoPlano}
  $conteudoInicializacao = Build-InicializacaoTab -window $window -scriptsDir $scriptsDir -setStatus ${function:Set-Status} -emSegundoPlano ${function:Invoke-EmSegundoPlano}
  $conteudoGPU = Build-GPUTab -window $window -scriptsDir $scriptsDir -setStatus ${function:Set-Status} -emSegundoPlano ${function:Invoke-EmSegundoPlano}
  $conteudoPerfis = Build-PerfisTab -window $window -scriptsDir $scriptsDir -setStatus ${function:Set-Status} -emSegundoPlano ${function:Invoke-EmSegundoPlano} -verificarAoAbrir $primeiraCarga
  $conteudoInternet = Build-InternetTab -window $window -scriptsDir $scriptsDir -setStatus ${function:Set-Status} -emSegundoPlano ${function:Invoke-EmSegundoPlano}
  $conteudoInstalar = Build-InstalarTab -window $window -setStatus ${function:Set-Status} -emSegundoPlano ${function:Invoke-EmSegundoPlano}
  $conteudoConfig = Build-ConfigTab -window $window -scriptsDir $scriptsDir -setStatus ${function:Set-Status} -emSegundoPlano ${function:Invoke-EmSegundoPlano}
  $conteudoUpdates = Build-UpdatesTab -window $window -setStatus ${function:Set-Status}
  $conteudoWin11 = Build-Win11Tab -window $window -setStatus ${function:Set-Status} -emSegundoPlano ${function:Invoke-EmSegundoPlano}

  $script:secoes = [ordered]@{
    "TabInstalar"    = @{ Titulo = "Instalar"; Elemento = $conteudoInstalar; NomeNav = "NavInstalar" }
    "TabAjustes"     = @{ Titulo = "Ajustes"; Elemento = $conteudoAjustes; NomeNav = "NavAjustes" }
    "TabConfig"      = @{ Titulo = "Config"; Elemento = $conteudoConfig; NomeNav = "NavConfig" }
    "TabUpdates"     = @{ Titulo = "Atualizações"; Elemento = $conteudoUpdates; NomeNav = "NavUpdates" }
    "TabWin11"       = @{ Titulo = "Criador Win11"; Elemento = $conteudoWin11; NomeNav = "NavWin11" }
    "TabDiagnostico" = @{ Titulo = "Diagnóstico"; Elemento = $conteudoDiagnostico; NomeNav = "NavDiagnostico" }
    "TabInicializacao" = @{ Titulo = "Inicialização"; Elemento = $conteudoInicializacao; NomeNav = "NavInicializacao" }
    "TabGPU"         = @{ Titulo = "Placa de Vídeo"; Elemento = $conteudoGPU; NomeNav = "NavGPU" }
    "TabPerfis"      = @{ Titulo = "Perfis"; Elemento = $conteudoPerfis; NomeNav = "NavPerfis" }
    "TabInternet"    = @{ Titulo = "Internet"; Elemento = $conteudoInternet; NomeNav = "NavInternet" }
  }
}

Reconstruir-Conteudo -primeiraCarga $true

# --- Navegacao lateral -- troca o conteudo da area principal sem
# reconstruir nada (cada Build-XTab ja rodou pelo menos uma vez; aqui so
# mostramos/escondemos qual arvore visual aparece). As chaves mantem o
# nome "TabX" por compatibilidade com os testes automatizados ja
# escritos (-TesteAba TabAjustes etc).
$areaConteudo = $window.FindName("AreaConteudo")
$txtTituloSecao = $window.FindName("TxtTituloSecao")
$Global:chaveSecaoAtual = "TabInstalar"

function Mostrar-Secao([string]$chave) {
  $info = $secoes[$chave]
  if (-not $info) { return }
  $Global:chaveSecaoAtual = $chave
  $areaConteudo.Child = $info.Elemento
  $txtTituloSecao.Text = $info.Titulo
  $navBtn = $window.FindName($info.NomeNav)
  if ($navBtn -and -not $navBtn.IsChecked) { $navBtn.IsChecked = $true }

  # Recolore o icone de cada item conforme selecao atual -- ver
  # comentario acima de Set-IconeNavCor (Shape.Stroke nao segue o
  # Foreground do RadioButton sozinho).
  foreach ($nomeNav in $Global:ViewboxesNav.Keys) {
    $btnAtual = $window.FindName($nomeNav)
    $corAlvo = if ($btnAtual.IsChecked) { $window.FindResource("BrushOnAccent") } else { $window.FindResource("BrushSidebarMuted") }
    Set-IconeNavCor $Global:ViewboxesNav[$nomeNav] $corAlvo
  }
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

$idxRolarTexto = $args.IndexOf("-TesteRolarAteTexto")
$textoRolarTeste = if ($idxRolarTexto -ge 0 -and $args.Count -gt ($idxRolarTexto + 1)) { $args[$idxRolarTexto + 1] } else { $null }

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
    if ($botoesTeste.Count -gt 0) {
      Rolar-ScrollViewersParaFim $window
      $window.UpdateLayout()
    }
    if ($textoRolarTeste) {
      $alvo = Find-VisualChildByText $window $textoRolarTeste
      "[TesteRolarAteTexto '$textoRolarTeste'] achado: $($null -ne $alvo)" | Out-File $debugLog -Append
      if ($alvo) { $alvo.BringIntoView(); $window.UpdateLayout() }
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
