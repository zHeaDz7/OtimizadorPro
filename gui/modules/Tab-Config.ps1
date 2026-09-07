# Aba "Config" -- recursos opcionais do Windows (Hyper-V, WSL, etc),
# atalhos pros paineis classicos de controle, e ferramentas de reparo
# (reaproveitando scripts ja existentes onde da).
$Global:CatalogoFeatures = @(
  @{ Nome = ".NET Framework 3.5 (necessario pra jogo antigo)"; Feature = "NetFx3" }
  @{ Nome = "Hyper-V (maquina virtual oficial do Windows)"; Feature = "Microsoft-Hyper-V-All" }
  @{ Nome = "Windows Subsystem for Linux (WSL)"; Feature = "Microsoft-Windows-Subsystem-Linux" }
  @{ Nome = "Windows Sandbox (ambiente isolado descartavel)"; Feature = "Containers-DisposableClientVM" }
  @{ Nome = "Componentes de midia legado (WMP, DirectPlay)"; Feature = "WindowsMediaPlayer,DirectPlay" }
)

$Global:CatalogoPaineis = @(
  @{ Nome = "Programas e Recursos"; Comando = "appwiz.cpl" }
  @{ Nome = "Opcoes de Energia"; Comando = "powercfg.cpl" }
  @{ Nome = "Conexoes de Rede"; Comando = "ncpa.cpl" }
  @{ Nome = "Propriedades do Mouse"; Comando = "main.cpl" }
  @{ Nome = "Propriedades do Sistema"; Comando = "sysdm.cpl" }
  @{ Nome = "Som"; Comando = "mmsys.cpl" }
  @{ Nome = "Firewall do Windows Defender"; Comando = "firewall.cpl" }
  @{ Nome = "Gerenciamento de Disco"; Comando = "diskmgmt.msc" }
  @{ Nome = "Editor de Politicas de Grupo Local"; Comando = "gpedit.msc" }
  @{ Nome = "Servicos do Windows"; Comando = "services.msc" }
  @{ Nome = "Agendador de Tarefas"; Comando = "taskschd.msc" }
  @{ Nome = "Gerenciador de Dispositivos"; Comando = "devmgmt.msc" }
)

function Build-ConfigTab {
  param($window, $scriptsDir, $setStatus)

  $raiz = New-Object System.Windows.Controls.ScrollViewer
  $painel = New-Object System.Windows.Controls.StackPanel
  $painel.Margin = "0,0,20,0"
  $raiz.Content = $painel

  # --- Recursos opcionais do Windows ---
  $t1 = New-Object System.Windows.Controls.TextBlock
  $t1.Text = "RECURSOS OPCIONAIS DO WINDOWS"
  $t1.Style = $window.FindResource("Rotulo")
  $t1.Margin = "2,0,0,8"
  $painel.Children.Add($t1) | Out-Null

  $checkboxesFeature = @{}
  $gradeFeatures = New-Object System.Windows.Controls.WrapPanel
  foreach ($f in $Global:CatalogoFeatures) {
    $cb = New-Object System.Windows.Controls.CheckBox
    $cb.Content = $f.Nome
    $cb.Width = 400
    $cb.Margin = "2,4,10,4"
    $cb.Tag = $f
    $checkboxesFeature[$f.Feature] = $cb
    $gradeFeatures.Children.Add($cb) | Out-Null
  }
  $painel.Children.Add($gradeFeatures) | Out-Null

  $barraFeatures = New-Object System.Windows.Controls.StackPanel
  $barraFeatures.Orientation = "Horizontal"
  $barraFeatures.Margin = "0,10,0,24"
  $btnInstalarFeatures = New-Object System.Windows.Controls.Button
  $btnInstalarFeatures.Name = "BtnInstalarFeatures"
  $btnInstalarFeatures.Content = "Instalar recursos marcados (precisa reiniciar)"
  $btnInstalarFeatures.Style = $window.FindResource("BtnPrimary")
  $barraFeatures.Children.Add($btnInstalarFeatures) | Out-Null
  $painel.Children.Add($barraFeatures) | Out-Null

  $btnInstalarFeatures.Add_Click({
    try {
      $marcados = @($checkboxesFeature.Values | Where-Object { $_.IsChecked -eq $true })
      if ($marcados.Count -eq 0) { $setStatus.Invoke("Nenhum recurso marcado.") | Out-Null; return }
      $ok = 0; $falha = 0
      foreach ($cb in $marcados) {
        $f = $cb.Tag
        $setStatus.Invoke("Instalando: $($f.Nome)...") | Out-Null
        foreach ($nomeFeat in ($f.Feature -split ",")) {
          try {
            Enable-WindowsOptionalFeature -Online -FeatureName $nomeFeat -All -NoRestart -ErrorAction Stop | Out-Null
            $ok++
          } catch { $falha++ }
        }
      }
      $setStatus.Invoke("$ok recurso(s) instalado(s), $falha falharam. Reinicie o PC pra valer.") | Out-Null
    } catch {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnInstalarFeatures: $_" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro -- veja o log.") | Out-Null
    }
  }.GetNewClosure())

  # --- Paineis classicos ---
  $t2 = New-Object System.Windows.Controls.TextBlock
  $t2.Text = "PAINEIS CLASSICOS (ATALHO RAPIDO)"
  $t2.Style = $window.FindResource("Rotulo")
  $t2.Margin = "2,0,0,8"
  $painel.Children.Add($t2) | Out-Null

  $gradePaineis = New-Object System.Windows.Controls.WrapPanel
  foreach ($p in $Global:CatalogoPaineis) {
    $btn = New-Object System.Windows.Controls.Button
    $txtBtn = New-Object System.Windows.Controls.TextBlock
    $txtBtn.Text = $p.Nome
    $txtBtn.TextWrapping = "Wrap"
    $txtBtn.TextAlignment = "Center"
    $btn.Content = $txtBtn
    $btn.Style = $window.FindResource("BtnGhost")
    $btn.Width = 240
    $btn.MinHeight = 44
    $btn.Margin = "0,0,10,10"
    $btn.Tag = $p.Comando
    $btn.Add_Click({
      param($s, $e)
      try { Start-Process $s.Tag } catch {}
    })
    $gradePaineis.Children.Add($btn) | Out-Null
  }
  $painel.Children.Add($gradePaineis) | Out-Null

  # --- Reparos ---
  $t3 = New-Object System.Windows.Controls.TextBlock
  $t3.Text = "REPAROS"
  $t3.Style = $window.FindResource("Rotulo")
  $t3.Margin = "2,20,0,8"
  $painel.Children.Add($t3) | Out-Null

  function New-BotaoTexto($texto, $window) {
    $b = New-Object System.Windows.Controls.Button
    $t = New-Object System.Windows.Controls.TextBlock
    $t.Text = $texto
    $t.TextWrapping = "Wrap"
    $t.TextAlignment = "Center"
    $b.Content = $t
    $b.Style = $window.FindResource("BtnGhost")
    $b.Width = 240
    $b.MinHeight = 44
    $b.Margin = "0,0,10,10"
    return $b
  }

  $gradeReparos = New-Object System.Windows.Controls.WrapPanel

  $btnReparo1 = New-BotaoTexto "Reparar rede (Winsock/TCP-IP)" $window
  $btnReparo1.Add_Click({
    try {
      $setStatus.Invoke("Reparando rede...") | Out-Null
      $r = (& (Join-Path $scriptsDir "_net_repair.ps1") 2>&1) -join " | "
      $setStatus.Invoke($r) | Out-Null
    } catch {}
  }.GetNewClosure())
  $gradeReparos.Children.Add($btnReparo1) | Out-Null

  $btnReparo2 = New-BotaoTexto "Verificar arquivos do sistema (SFC)" $window
  $btnReparo2.Add_Click({
    try {
      $setStatus.Invoke("Rodando SFC -- isso demora alguns minutos, aguarde...") | Out-Null
      $r = (sfc /scannow 2>&1) -join " "
      $setStatus.Invoke("SFC concluido.") | Out-Null
    } catch {}
  }.GetNewClosure())
  $gradeReparos.Children.Add($btnReparo2) | Out-Null

  $btnReparo3 = New-BotaoTexto "Resetar Windows Update" $window
  $btnReparo3.Add_Click({
    try {
      $setStatus.Invoke("Resetando Windows Update...") | Out-Null
      Stop-Service -Name wuauserv, bits -Force -ErrorAction SilentlyContinue
      Remove-Item -Path "$env:WINDIR\SoftwareDistribution" -Recurse -Force -ErrorAction SilentlyContinue
      Start-Service -Name wuauserv, bits -ErrorAction SilentlyContinue
      $setStatus.Invoke("Windows Update resetado.") | Out-Null
    } catch {
      $setStatus.Invoke("Erro -- precisa ser Administrador.") | Out-Null
    }
  }.GetNewClosure())
  $gradeReparos.Children.Add($btnReparo3) | Out-Null

  $painel.Children.Add($gradeReparos) | Out-Null

  return $raiz
}
