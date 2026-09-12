# Constroi o conteudo da aba "Placa de Vídeo" -- detecta a(s) GPU(s) do
# PC (NVIDIA, AMD ou Intel), mostra driver/VRAM, oferece otimizações
# reais e reversíveis (nada de valor de registro "secreto" chutado -- só
# o que é documentado oficialmente), atalho direto pro painel de
# controle do fabricante certo, preferência de GPU por jogo específico e
# reforço de prioridade pra jogo que já está rodando agora.

# Dot-source no nivel do modulo (nao dentro de Build-GPUTab) -- precisa
# ficar visivel de dentro do Add_Click({...}.GetNewClosure()) do botao
# "Escolher jogo", e GetNewClosure() so capta funcao que ja e de nivel
# de modulo/global, nunca uma funcao aninhada dentro de outra funcao.
. (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "scripts\_lib_launchers.ps1")

# Cada item aqui usa a mesma convenção -Action Aplicar/Reverter/Status
# dos scripts de Ajustes -- nao reimplementa nada, so chama os scripts
# que ja existem em scripts\.
$Global:ListaAjustesGPU = @(
  @{ Nome = "MSI Mode da placa de vídeo"; Script = "_gpu_msi_mode.ps1"; Conv = "toggle"
     Melhora = "Jeito mais moderno da GPU avisar o processador -- pode reduzir picos de latência (DPC) e microstutter."
     Contras = "Nenhum efeito colateral conhecido -- é uma opção oficial do driver do Windows." }
  @{ Nome = "TDR Delay aumentado (8s)"; Script = "_gpu_tdr_delay.ps1"; Conv = "toggle"
     Melhora = "Menos chance do Windows reiniciar o driver de vídeo por engano numa cena muito pesada."
     Contras = "Se a GPU travar de verdade, o Windows demora mais pra perceber e recuperar." }
)

function Get-GpuVendorGUI([string]$nome) {
  if ($nome -match "NVIDIA|GeForce|RTX|GTX|Quadro") { return "NVIDIA" }
  if ($nome -match "AMD|Radeon|ATI ") { return "AMD" }
  if ($nome -match "Intel") { return "Intel" }
  return "Desconhecida"
}

function Get-GpuVramGUI([string]$nome, $adapterRam) {
  try {
    $classe = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
    $sub = Get-ChildItem $classe -ErrorAction SilentlyContinue | Where-Object {
      (Get-ItemProperty $_.PSPath -Name "DriverDesc" -ErrorAction SilentlyContinue).DriverDesc -eq $nome
    } | Select-Object -First 1
    if ($sub) {
      $qw = (Get-ItemProperty $sub.PSPath -Name "HardwareInformation.qwMemorySize" -ErrorAction SilentlyContinue)."HardwareInformation.qwMemorySize"
      if ($qw -and $qw -gt 0) { return [math]::Round($qw / 1GB, 1) }
    }
  } catch {}
  if ($adapterRam -and $adapterRam -gt 0) { return [math]::Round($adapterRam / 1GB, 1) }
  return $null
}

function Open-NvidiaPanelGUI {
  try { Start-Process "nvcplui.exe" -ErrorAction Stop; return $true } catch {}
  try {
    $legado = Join-Path $env:SystemRoot "System32\nvcplui.exe"
    if (Test-Path $legado) { Start-Process $legado; return $true }
  } catch {}
  return $false
}

function Open-AmdPanelGUI {
  try {
    $pacote = Get-AppxPackage -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "AMD|Radeon" } | Select-Object -First 1
    if ($pacote) {
      $manifest = Get-AppxPackageManifest $pacote -ErrorAction Stop
      $appId = $manifest.Package.Applications.Application.Id | Select-Object -First 1
      if ($appId) { Start-Process "shell:AppsFolder\$($pacote.PackageFamilyName)!$appId"; return $true }
    }
  } catch {}
  try {
    $legado = "C:\Program Files\AMD\CNext\CNext\RadeonSettings.exe"
    if (Test-Path $legado) { Start-Process $legado; return $true }
  } catch {}
  return $false
}

# As tres funcoes abaixo (New-CartaoGpuGUI, Atualizar-InfoGpuGUI,
# Carregar-PreferenciasGpuGUI, Carregar-ProcessosGpuGUI) ficam no nivel
# do modulo -- nao aninhadas dentro de Build-GPUTab -- porque sao
# chamadas de dentro de Add_Click({...}.GetNewClosure()). GetNewClosure()
# so "engarrafa" VARIAVEIS do escopo onde foi chamado, nunca FUNCOES
# aninhadas do escopo pai -- confirmado com erro real em teste
# automatizado ("O termo 'Atualizar-InfoGpu' nao e reconhecido..."),
# mesma causa raiz da regra ja documentada em Tab-Diagnostico.ps1 pra
# Formatar-NumeroGB. Aqui, como funcao de nivel de modulo, tudo que
# precisam recebem por parametro em vez de fechar sobre variaveis locais.

function New-CartaoGpuGUI($window, $gpu) {
  $vendor = Get-GpuVendorGUI $gpu.Name
  $vram = Get-GpuVramGUI $gpu.Name $gpu.AdapterRAM

  $cartao = New-Object System.Windows.Controls.Border
  $cartao.BorderBrush = $window.FindResource("BrushBorder")
  $cartao.BorderThickness = 1
  $cartao.CornerRadius = 6
  $cartao.Background = $window.FindResource("BrushSurface2")
  $cartao.Padding = "14,12"
  $cartao.Margin = "0,0,0,10"
  $painel = New-Object System.Windows.Controls.StackPanel
  $cartao.Child = $painel

  $linhaTitulo = New-Object System.Windows.Controls.StackPanel
  $linhaTitulo.Orientation = "Horizontal"
  $badge = New-Object System.Windows.Controls.Border
  $badge.Background = $window.FindResource("BrushAccentSoft")
  $badge.CornerRadius = 4
  $badge.Padding = "8,2"
  $badge.Margin = "0,0,10,0"
  $txtBadge = New-Object System.Windows.Controls.TextBlock
  $txtBadge.Text = $vendor.ToUpper()
  $txtBadge.FontSize = 10.5
  $txtBadge.FontWeight = "Bold"
  $txtBadge.Foreground = $window.FindResource("BrushAccentInk")
  $badge.Child = $txtBadge
  $txtNome = New-Object System.Windows.Controls.TextBlock
  $txtNome.Text = $gpu.Name
  $txtNome.FontSize = 14.5
  $txtNome.FontWeight = "Bold"
  $txtNome.Foreground = $window.FindResource("BrushInk")
  $txtNome.VerticalAlignment = "Center"
  $linhaTitulo.Children.Add($badge) | Out-Null
  $linhaTitulo.Children.Add($txtNome) | Out-Null
  $painel.Children.Add($linhaTitulo) | Out-Null

  $diasAtras = $null
  $detalhesTxt = "Driver: $($gpu.DriverVersion)"
  if ($gpu.DriverDate) {
    $dataDriver = [datetime]$gpu.DriverDate
    $diasAtras = (New-TimeSpan -Start $dataDriver -End (Get-Date)).Days
    $detalhesTxt += " -- $($dataDriver.ToString('dd/MM/yyyy')) ($diasAtras dias atrás)"
  }
  if ($vram) { $detalhesTxt += " | VRAM: $vram GB" }
  $detalhes = New-Object System.Windows.Controls.TextBlock
  $detalhes.Text = $detalhesTxt
  $detalhes.Foreground = $window.FindResource("BrushMuted")
  $detalhes.FontSize = 12
  $detalhes.Margin = "0,6,0,0"
  $detalhes.TextWrapping = "Wrap"
  $painel.Children.Add($detalhes) | Out-Null

  if ($diasAtras -and $diasAtras -gt 365) {
    $aviso = New-Object System.Windows.Controls.TextBlock
    $aviso.Text = "Driver com mais de 1 ano -- vale a pena atualizar pelo site oficial do fabricante."
    $aviso.Foreground = $window.FindResource("BrushBad")
    $aviso.FontSize = 11.5
    $aviso.Margin = "0,6,0,0"
    $aviso.TextWrapping = "Wrap"
    $painel.Children.Add($aviso) | Out-Null
  }
  return $cartao
}

# Constroi a secao "Verificar driver mais recente" -- compartilhada entre
# NVIDIA e AMD (mesmo layout, so troca qual script de lookup chamar e o
# link/instrucao de "versao mais antiga"). Nivel de modulo pela mesma
# regra de sempre: os Add_Click daqui usam GetNewClosure() sobre os
# PARAMETROS dessa funcao, nunca chamam outra funcao aninhada.
function Add-SecaoVerificarDriverGUI($window, $painelVendor, $scriptsDir, $emSegundoPlano, $setStatus, $debugLog, $principal, $nomeVendor, $scriptLookup, $nomeBotaoVerificar, $urlVersaoAntiga, $instrucaoVersaoAntiga) {
  $dataInstalado = $null
  if ($principal.DriverDate) { try { $dataInstalado = [datetime]$principal.DriverDate } catch {} }
  $versaoInstalada = $principal.DriverVersion

  $btnVerificarDriver = New-Object System.Windows.Controls.Button
  $btnVerificarDriver.Name = $nomeBotaoVerificar
  $btnVerificarDriver.Content = "Verificar driver mais recente"
  $btnVerificarDriver.Style = $window.FindResource("BtnGhost")
  $btnVerificarDriver.Margin = "0,14,0,0"
  $btnVerificarDriver.HorizontalAlignment = "Left"
  $painelVendor.Children.Add($btnVerificarDriver) | Out-Null

  $txtResultadoDriver = New-Object System.Windows.Controls.TextBlock
  $txtResultadoDriver.TextWrapping = "Wrap"
  $txtResultadoDriver.FontSize = 12
  $txtResultadoDriver.Margin = "0,8,0,0"
  $txtResultadoDriver.Visibility = "Collapsed"
  $painelVendor.Children.Add($txtResultadoDriver) | Out-Null

  $barraBotoesDriver = New-Object System.Windows.Controls.StackPanel
  $barraBotoesDriver.Orientation = "Horizontal"
  $barraBotoesDriver.Margin = "0,8,0,0"
  $barraBotoesDriver.Visibility = "Collapsed"
  $btnBaixarDriver = New-Object System.Windows.Controls.Button
  $btnBaixarDriver.Content = "Baixar driver mais recente"
  $btnBaixarDriver.Style = $window.FindResource("BtnPrimary")
  $btnBaixarDriver.Margin = "0,0,10,0"
  $btnNotasDriver = New-Object System.Windows.Controls.Button
  $btnNotasDriver.Content = "Ver notas de versão"
  $btnNotasDriver.Style = $window.FindResource("BtnGhost")
  $btnNotasDriver.Margin = "0,0,10,0"
  $barraBotoesDriver.Children.Add($btnBaixarDriver) | Out-Null
  $barraBotoesDriver.Children.Add($btnNotasDriver) | Out-Null
  $painelVendor.Children.Add($barraBotoesDriver) | Out-Null

  $btnVersaoAntiga = New-Object System.Windows.Controls.Button
  $btnVersaoAntiga.Content = "Usar uma versão mais antiga"
  $btnVersaoAntiga.Style = $window.FindResource("BtnGhost")
  $btnVersaoAntiga.Margin = "0,8,0,0"
  $btnVersaoAntiga.HorizontalAlignment = "Left"
  $btnVersaoAntiga.Add_Click({
    try { Start-Process $urlVersaoAntiga } catch {}
    $setStatus.Invoke($instrucaoVersaoAntiga) | Out-Null
  }.GetNewClosure())
  $painelVendor.Children.Add($btnVersaoAntiga) | Out-Null

  $callbackVerificarDriver = {
    param($resultado, $erro)
    $txtResultadoDriver.Visibility = "Visible"
    if ($erro -or -not $resultado -or $resultado.Erro) {
      $motivo = if ($resultado -and $resultado.Erro) { $resultado.Erro } else { "erro inesperado" }
      $txtResultadoDriver.Text = "Não consegui verificar automaticamente ($motivo). Use 'Usar uma versão mais antiga' abaixo pra abrir a página oficial e conferir manualmente."
      $txtResultadoDriver.Foreground = $window.FindResource("BrushMuted")
      return
    }

    $txtComparacao = "Driver instalado: $versaoInstalada"
    if ($dataInstalado) { $txtComparacao += " ($($dataInstalado.ToString('dd/MM/yyyy')))" }
    $txtComparacao += " | Mais recente da $nomeVendor`: $($resultado.Versao) ($($resultado.Data))"

    if ($dataInstalado -and $resultado.DataParsed -and $resultado.DataParsed -gt $dataInstalado) {
      $dias = (New-TimeSpan -Start $dataInstalado -End $resultado.DataParsed).Days
      $txtResultadoDriver.Text = "$txtComparacao`nSeu driver está desatualizado (o mais novo saiu $dias dia(s) depois do seu)."
      $txtResultadoDriver.Foreground = $window.FindResource("BrushBad")
    } elseif ($dataInstalado) {
      $txtResultadoDriver.Text = "$txtComparacao`nSeu driver já está atualizado (ou mais novo que o que a $nomeVendor retornou pra essa busca)."
      $txtResultadoDriver.Foreground = $window.FindResource("BrushGood")
    } else {
      $txtResultadoDriver.Text = "$txtComparacao`nNão consegui comparar a data do seu driver instalado."
      $txtResultadoDriver.Foreground = $window.FindResource("BrushMuted")
    }

    $barraBotoesDriver.Visibility = "Visible"
    $btnBaixarDriver.Tag = $resultado.UrlDownload
    $btnNotasDriver.Tag = $resultado.UrlNotas
    $btnNotasDriver.IsEnabled = [bool]$resultado.UrlNotas
  }.GetNewClosure()

  $btnBaixarDriver.Add_Click({
    param($s, $e)
    try { if ($s.Tag) { Start-Process $s.Tag } } catch {}
  })
  $btnNotasDriver.Add_Click({
    param($s, $e)
    try { if ($s.Tag) { Start-Process $s.Tag } } catch {}
  })

  $btnVerificarDriver.Add_Click({
    try {
      $setStatus.Invoke("Consultando o site da $nomeVendor em segundo plano...") | Out-Null
      $trabalho = {
        param($caminhoScript, $nomeGpu)
        $saida = & $caminhoScript -NomeGpu $nomeGpu 2>&1
        $linhas = @($saida)
        $primeira = "$($linhas | Select-Object -First 1)"
        if ($primeira -match "^Erro:\s*(.+)") { return @{ Erro = $matches[1] } }
        $r = @{}
        foreach ($l in $linhas) {
          if ($l -match "^Versao:\s*(.+)") { $r.Versao = $matches[1].Trim() }
          elseif ($l -match "^Data:\s*(.+)") { $r.Data = $matches[1].Trim() }
          elseif ($l -match "^UrlDownload:\s*(.+)") { $r.UrlDownload = $matches[1].Trim() }
          elseif ($l -match "^UrlNotas:\s*(.+)") { $r.UrlNotas = $matches[1].Trim() }
        }
        if (-not $r.Versao) { return @{ Erro = "resposta incompleta" } }
        # NVIDIA devolve data tipo "Wed Sep 09, 2026", AMD devolve
        # "2026-09-03" (ISO) -- tenta os dois formatos conhecidos antes
        # de desistir de comparar por data.
        $r.DataParsed = $null
        foreach ($formato in @("ddd MMM dd, yyyy", "yyyy-MM-dd")) {
          try { $r.DataParsed = [datetime]::ParseExact($r.Data, $formato, [System.Globalization.CultureInfo]::InvariantCulture); break } catch {}
        }
        return $r
      }
      $emSegundoPlano.Invoke(@($btnVerificarDriver), $trabalho, @((Join-Path $scriptsDir $scriptLookup), $principal.Name), $callbackVerificarDriver, $setStatus)
    } catch {
      "ERRO no ${nomeBotaoVerificar}: $_" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao verificar driver -- veja o log.") | Out-Null
    }
  }.GetNewClosure())
}

function Atualizar-InfoGpuGUI($window, $painelGpuInfo, $painelVendor, $setStatus, $debugLog, $scriptsDir, $emSegundoPlano) {
  $painelGpuInfo.Children.Clear()
  $painelVendor.Children.Clear()
  try {
    $gpus = @(Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch "Basic|Meta|Virtual" })
    if ($gpus.Count -eq 0) {
      $vazio = New-Object System.Windows.Controls.TextBlock
      $vazio.Text = "Não consegui identificar a placa de vídeo."
      $vazio.Foreground = $window.FindResource("BrushMuted")
      $painelGpuInfo.Children.Add($vazio) | Out-Null
      return
    }
    foreach ($g in $gpus) { $painelGpuInfo.Children.Add((New-CartaoGpuGUI $window $g)) | Out-Null }

    $integrada = $gpus | Where-Object { $_.Name -match "Intel|Radeon\(TM\) Graphics|AMD Radeon Graphics" -and $_.Name -notmatch "RTX|GTX|RX \d" }
    $dedicada = $gpus | Where-Object { $_.Name -match "RTX|GTX|RX \d|NVIDIA|Radeon RX" }
    if ($gpus.Count -ge 2 -and $integrada -and $dedicada) {
      $avisoHibrido = New-Object System.Windows.Controls.TextBlock
      $avisoHibrido.Text = "Sistema com GPU híbrida detectado -- garanta que seus jogos rodem na placa DEDICADA (veja 'Preferência de GPU por Jogo' abaixo)."
      $avisoHibrido.Foreground = $window.FindResource("BrushAccentInk")
      $avisoHibrido.FontSize = 12
      $avisoHibrido.TextWrapping = "Wrap"
      $avisoHibrido.Margin = "0,0,0,10"
      $painelGpuInfo.Children.Add($avisoHibrido) | Out-Null
    }

    $principal = ($dedicada | Select-Object -First 1)
    if (-not $principal) { $principal = $gpus[0] }
    $vendorPrincipal = Get-GpuVendorGUI $principal.Name

    $btnPainel = New-Object System.Windows.Controls.Button
    $dica = New-Object System.Windows.Controls.TextBlock
    $dica.Foreground = $window.FindResource("BrushMuted")
    $dica.FontSize = 12
    $dica.TextWrapping = "Wrap"
    $dica.Margin = "0,10,0,0"

    switch ($vendorPrincipal) {
      "NVIDIA" {
        $btnPainel.Content = "Abrir Painel de Controle NVIDIA"
        $btnPainel.Style = $window.FindResource("BtnPrimary")
        $btnPainel.Add_Click({
          if (-not (Open-NvidiaPanelGUI)) {
            $setStatus.Invoke("Não encontrei o Painel de Controle NVIDIA -- clique com o botão direito na área de trabalho e escolha 'Painel de Controle NVIDIA'.") | Out-Null
          }
        }.GetNewClosure())
        $painelVendor.Children.Add($btnPainel) | Out-Null
        $dica.Text = "Dentro do painel, pra desempenho máximo: 'Gerenciar Configurações 3D' > 'Modo de gerenciamento de energia' > 'Preferir desempenho máximo'. Em 'Modo de baixa latência', escolha 'Ultra'."
        $painelVendor.Children.Add($dica) | Out-Null

        Add-SecaoVerificarDriverGUI $window $painelVendor $scriptsDir $emSegundoPlano $setStatus $debugLog $principal "NVIDIA" "_nvidia_driver_lookup.ps1" "BtnGpuVerificarDriverNvidia" "https://www.nvidia.com/Download/index.aspx" "Na página da NVIDIA, selecione: Tipo = GeForce, Série = GeForce RTX 30 Series, Produto = $($principal.Name -replace '^NVIDIA\s+',''), Sistema = Windows 11 -- e marque 'mostrar todos os drivers' pra ver o histórico de versões."
      }
      "AMD" {
        $btnPainel.Content = "Abrir AMD Software"
        $btnPainel.Style = $window.FindResource("BtnPrimary")
        $btnPainel.Add_Click({
          if (-not (Open-AmdPanelGUI)) {
            $setStatus.Invoke("Não encontrei o AMD Software instalado -- abra pelo menu Iniciar.") | Out-Null
          }
        }.GetNewClosure())
        $painelVendor.Children.Add($btnPainel) | Out-Null
        $dica.Text = "Dentro do AMD Software, pra desempenho máximo: 'Jogos' > 'Configurações Gráficas Globais' > ative 'Radeon Anti-Lag'. Em placas mais novas, teste 'Radeon Boost' ligado e desligado pra ver qual fica melhor no seu jogo."
        $painelVendor.Children.Add($dica) | Out-Null

        Add-SecaoVerificarDriverGUI $window $painelVendor $scriptsDir $emSegundoPlano $setStatus $debugLog $principal "AMD" "_amd_driver_lookup.ps1" "BtnGpuVerificarDriverAmd" "https://www.amd.com/en/support/download/drivers.html" "Na página da AMD, procure por '$($principal.Name)' e marque a opção de ver todas as versões/histórico de drivers disponíveis."
      }
      default {
        $dica.Text = "Placa de vídeo integrada Intel -- o ganho de desempenho vem principalmente de manter o driver atualizado (veja aviso acima, se houver). Se o 'Intel Graphics Command Center' estiver instalado, abra pelo menu Iniciar pra ajustes adicionais."
        $dica.Margin = "0,0,0,0"
        $painelVendor.Children.Add($dica) | Out-Null
      }
    }
  } catch {
    "ERRO em Atualizar-InfoGpuGUI: $_" | Out-File $debugLog -Append
  }
}

function Carregar-PreferenciasGpuGUI($window, $scriptsDir, $listaPreferencias, $setStatus, $debugLog) {
  $listaPreferencias.Children.Clear()
  try {
    $caminhos = @(& (Join-Path $scriptsDir "_gpu_preferencia_jogo.ps1") -Action Listar 2>&1 | Where-Object { $_ -and $_ -notmatch "^AVISO" })
    if ($caminhos.Count -eq 0) {
      $vazio = New-Object System.Windows.Controls.TextBlock
      $vazio.Text = "Nenhum jogo configurado ainda."
      $vazio.Foreground = $window.FindResource("BrushMuted")
      $vazio.FontSize = 12
      $listaPreferencias.Children.Add($vazio) | Out-Null
      return
    }
    foreach ($c in $caminhos) {
      $linha = New-Object System.Windows.Controls.StackPanel
      $linha.Orientation = "Horizontal"
      $linha.Margin = "0,0,0,6"
      $txt = New-Object System.Windows.Controls.TextBlock
      $txt.Text = (Split-Path $c -Leaf)
      $txt.ToolTip = $c
      $txt.Width = 340
      $txt.FontSize = 12.5
      $txt.VerticalAlignment = "Center"
      $txt.Foreground = $window.FindResource("BrushInk")
      $btnRem = New-Object System.Windows.Controls.Button
      $btnRem.Content = "Remover"
      $btnRem.Style = $window.FindResource("BtnGhost")
      $btnRem.Tag = $c
      $btnRem.Add_Click({
        param($s, $e)
        try {
          & (Join-Path $scriptsDir "_gpu_preferencia_jogo.ps1") -Caminho $s.Tag -Action Remover 2>&1 | Out-Null
          Carregar-PreferenciasGpuGUI $window $scriptsDir $listaPreferencias $setStatus $debugLog
          $setStatus.Invoke("Preferência removida.") | Out-Null
        } catch {}
      }.GetNewClosure())
      $linha.Children.Add($txt) | Out-Null
      $linha.Children.Add($btnRem) | Out-Null
      $listaPreferencias.Children.Add($linha) | Out-Null
    }
  } catch {
    "ERRO em Carregar-PreferenciasGpuGUI: $_" | Out-File $debugLog -Append
  }
}

function Carregar-ProcessosGpuGUI($comboProcessos, $debugLog) {
  $comboProcessos.Items.Clear()
  try {
    $procs = @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -and $_.MainWindowTitle.Trim() -ne "" } | Sort-Object ProcessName -Unique)
    foreach ($p in $procs) {
      $item = New-Object System.Windows.Controls.ComboBoxItem
      $item.Content = "$($p.MainWindowTitle)  ($($p.ProcessName).exe)"
      $item.Tag = $p.Id
      $comboProcessos.Items.Add($item) | Out-Null
    }
    if ($comboProcessos.Items.Count -eq 0) {
      $item = New-Object System.Windows.Controls.ComboBoxItem
      $item.Content = "(nenhum programa com janela aberta agora -- abra o jogo e clique em Atualizar)"
      $comboProcessos.Items.Add($item) | Out-Null
    }
    $comboProcessos.SelectedIndex = 0
  } catch {
    "ERRO em Carregar-ProcessosGpuGUI: $_" | Out-File $debugLog -Append
  }
}

function Build-GPUTab {
  param($window, $scriptsDir, $setStatus, $emSegundoPlano)

  $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
  $raiz = New-Object System.Windows.Controls.DockPanel

  $barra = New-Object System.Windows.Controls.StackPanel
  $barra.Orientation = "Horizontal"
  $barra.Margin = "0,0,0,14"
  [System.Windows.Controls.DockPanel]::SetDock($barra, "Top")
  $btnVerificar = New-Object System.Windows.Controls.Button
  $btnVerificar.Name = "BtnGpuVerificar"
  $btnVerificar.Content = "Verificar placa de vídeo"
  $btnVerificar.Style = $window.FindResource("BtnGhost")
  $barra.Children.Add($btnVerificar) | Out-Null
  $raiz.Children.Add($barra) | Out-Null

  $scroll = New-Object System.Windows.Controls.ScrollViewer
  $painelRaiz = New-Object System.Windows.Controls.StackPanel
  $scroll.Content = $painelRaiz
  $raiz.Children.Add($scroll) | Out-Null

  function New-Rotulo($texto, $margem) {
    $t = New-Object System.Windows.Controls.TextBlock
    $t.Text = $texto
    $t.Style = $window.FindResource("Rotulo")
    $t.Margin = $margem
    return $t
  }

  # --- Placa de vídeo detectada ---
  $painelRaiz.Children.Add((New-Rotulo "PLACA DE VÍDEO" "2,0,0,8")) | Out-Null
  $painelGpuInfo = New-Object System.Windows.Controls.StackPanel
  $painelRaiz.Children.Add($painelGpuInfo) | Out-Null

  # --- Painel do fabricante ---
  $painelRaiz.Children.Add((New-Rotulo "PAINEL DO FABRICANTE" "2,18,0,8")) | Out-Null
  $painelVendor = New-Object System.Windows.Controls.StackPanel
  $painelRaiz.Children.Add($painelVendor) | Out-Null

  $btnVerificar.Add_Click({
    Atualizar-InfoGpuGUI $window $painelGpuInfo $painelVendor $setStatus $debugLog $scriptsDir $emSegundoPlano
    $setStatus.Invoke("Informações da placa de vídeo atualizadas.") | Out-Null
  }.GetNewClosure())

  # --- Otimizações (mesmo padrao Aplicar/Reverter/Status da aba Ajustes) ---
  $painelRaiz.Children.Add((New-Rotulo "OTIMIZAÇÕES" "2,18,0,8")) | Out-Null
  $notaHags = New-Object System.Windows.Controls.TextBlock
  $notaHags.Text = "O HAGS (agendamento de GPU por hardware) já está disponível na aba Ajustes, em Sistema."
  $notaHags.Foreground = $window.FindResource("BrushMuted")
  $notaHags.FontSize = 11.5
  $notaHags.Margin = "2,0,0,10"
  $notaHags.TextWrapping = "Wrap"
  $painelRaiz.Children.Add($notaHags) | Out-Null

  $barraGpuOtim = New-Object System.Windows.Controls.StackPanel
  $barraGpuOtim.Orientation = "Horizontal"
  $barraGpuOtim.Margin = "0,0,0,10"
  $btnGpuStatus = New-Object System.Windows.Controls.Button
  $btnGpuStatus.Name = "BtnGpuStatus"
  $btnGpuStatus.Content = "Marcar conforme sistema atual"
  $btnGpuStatus.Style = $window.FindResource("BtnGhost")
  $btnGpuStatus.Margin = "0,0,10,0"
  $btnGpuAplicar = New-Object System.Windows.Controls.Button
  $btnGpuAplicar.Name = "BtnGpuAplicar"
  $btnGpuAplicar.Content = "Aplicar selecionados"
  $btnGpuAplicar.Style = $window.FindResource("BtnPrimary")
  $btnGpuAplicar.Margin = "0,0,10,0"
  $btnGpuReverter = New-Object System.Windows.Controls.Button
  $btnGpuReverter.Name = "BtnGpuReverter"
  $btnGpuReverter.Content = "Reverter selecionados"
  $btnGpuReverter.Style = $window.FindResource("BtnGhost")
  $barraGpuOtim.Children.Add($btnGpuStatus) | Out-Null
  $barraGpuOtim.Children.Add($btnGpuAplicar) | Out-Null
  $barraGpuOtim.Children.Add($btnGpuReverter) | Out-Null
  $painelRaiz.Children.Add($barraGpuOtim) | Out-Null

  $gradeGpu = New-Object System.Windows.Controls.WrapPanel
  $checkboxesPorItemGPU = @{}
  foreach ($item in $Global:ListaAjustesGPU) {
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
    $checkboxesPorItemGPU[$item.Nome] = $cb
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

    $gradeGpu.Children.Add($cartao) | Out-Null
  }
  $painelRaiz.Children.Add($gradeGpu) | Out-Null

  # IMPORTANTE: os $trabalho abaixo devolvem uma LISTA de hashtables
  # (@{Nome=;Ligado=}), nunca UM hashtable grande com varias chaves. O
  # $resultado que chega aqui no callback e o retorno de EndInvoke() --
  # um PSDataCollection de 1 item (o objeto que o trabalho devolveu).
  # Acessar PROPRIEDADE nesse wrapper (".Keys", ".Count") e proxied
  # certinho pro objeto de dentro, mas o INDEXADOR "[$chave]" direto
  # NUNCA e -- ele tenta indexar o proprio PSDataCollection (que so
  # aceita indice numerico), e devolve $null pra qualquer chave string,
  # silenciosamente. Confirmado testando isolado. Por isso: sempre
  # "foreach ($item in $resultado)" (nunca "$resultado[$chave]" direto),
  # e cada $item vem como o hashtable de verdade, ai sim "$item.Nome"
  # funciona normal.
  $callbackGpuStatus = {
    param($resultado, $erro)
    if ($erro) {
      "ERRO no BtnGpuStatus: $erro" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao ler status -- veja o log.") | Out-Null
      return
    }
    foreach ($item in $resultado) {
      if ($item -and $null -ne $item.Ligado -and $checkboxesPorItemGPU.ContainsKey($item.Nome)) {
        $checkboxesPorItemGPU[$item.Nome].IsChecked = [bool]$item.Ligado
      }
    }
    $setStatus.Invoke("Status atualizado.") | Out-Null
  }.GetNewClosure()

  $callbackGpuAplicar = {
    param($resultado, $erro)
    if ($erro) {
      "ERRO no BtnGpuAplicar: $erro" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao aplicar -- veja o log.") | Out-Null
      return
    }
    $confirmados = 0
    $total = 0
    foreach ($item in $resultado) {
      if (-not $item) { continue }
      $total++
      if ($checkboxesPorItemGPU.ContainsKey($item.Nome) -and $null -ne $item.Ligado) {
        $checkboxesPorItemGPU[$item.Nome].IsChecked = [bool]$item.Ligado
        if ($item.Ligado) { $confirmados++ }
      }
    }
    $setStatus.Invoke("Pronto: $confirmados de $total confirmado(s) como aplicado(s) (status real reconferido).") | Out-Null
  }.GetNewClosure()

  $callbackGpuReverter = {
    param($resultado, $erro)
    if ($erro) {
      "ERRO no BtnGpuReverter: $erro" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao reverter -- veja o log.") | Out-Null
      return
    }
    $confirmados = 0
    $total = 0
    foreach ($item in $resultado) {
      if (-not $item) { continue }
      $total++
      if ($checkboxesPorItemGPU.ContainsKey($item.Nome) -and $null -ne $item.Ligado) {
        $checkboxesPorItemGPU[$item.Nome].IsChecked = [bool]$item.Ligado
        if (-not $item.Ligado) { $confirmados++ }
      }
    }
    $setStatus.Invoke("Pronto: $confirmados de $total confirmado(s) como revertido(s) (status real reconferido).") | Out-Null
  }.GetNewClosure()

  $btnGpuStatus.Add_Click({
    try {
      $itens = @($checkboxesPorItemGPU.Values | ForEach-Object { $_.Tag })
      $setStatus.Invoke("Lendo status atual em segundo plano...") | Out-Null
      $trabalho = {
        param($itens, $dirScripts)
        $resultados = @()
        foreach ($item in $itens) {
          $progresso.Texto = "Lendo status: $($item.Nome)..."
          $caminho = Join-Path $dirScripts $item.Script
          try { $resultados += @{ Nome = $item.Nome; Ligado = ((& $caminho -Action Status 2>&1 | Select-Object -First 1) -match "^LIGADO") } }
          catch { $resultados += @{ Nome = $item.Nome; Ligado = $null } }
        }
        return $resultados
      }
      $emSegundoPlano.Invoke(@($btnGpuStatus, $btnGpuAplicar, $btnGpuReverter), $trabalho, @($itens, $scriptsDir), $callbackGpuStatus, $setStatus)
    } catch {
      "ERRO no BtnGpuStatus: $_`n$($_.ScriptStackTrace)" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao ler status -- veja o log.") | Out-Null
    }
  }.GetNewClosure())

  $btnGpuAplicar.Add_Click({
    try {
      $marcados = @($checkboxesPorItemGPU.Values | Where-Object { $_.IsChecked -eq $true })
      if ($marcados.Count -eq 0) { $setStatus.Invoke("Nenhum item marcado.") | Out-Null; return }
      $itens = @($marcados | ForEach-Object { $_.Tag })
      $setStatus.Invoke("Aplicando $($itens.Count) item(ns) em segundo plano...") | Out-Null
      $trabalho = {
        param($itens, $dirScripts)
        $resultados = @()
        foreach ($item in $itens) {
          $progresso.Texto = "Aplicando: $($item.Nome)..."
          $caminho = Join-Path $dirScripts $item.Script
          try { & $caminho -Action Aplicar 2>&1 | Out-Null } catch {}
          try { $resultados += @{ Nome = $item.Nome; Ligado = ((& $caminho -Action Status 2>&1 | Select-Object -First 1) -match "^LIGADO") } }
          catch { $resultados += @{ Nome = $item.Nome; Ligado = $null } }
        }
        return $resultados
      }
      $emSegundoPlano.Invoke(@($btnGpuStatus, $btnGpuAplicar, $btnGpuReverter), $trabalho, @($itens, $scriptsDir), $callbackGpuAplicar, $setStatus)
    } catch {
      "ERRO no BtnGpuAplicar: $_`n$($_.ScriptStackTrace)" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao aplicar -- veja o log.") | Out-Null
    }
  }.GetNewClosure())

  $btnGpuReverter.Add_Click({
    try {
      $marcados = @($checkboxesPorItemGPU.Values | Where-Object { $_.IsChecked -eq $true })
      if ($marcados.Count -eq 0) { $setStatus.Invoke("Nenhum item marcado.") | Out-Null; return }
      $itens = @($marcados | ForEach-Object { $_.Tag })
      $setStatus.Invoke("Revertendo $($itens.Count) item(ns) em segundo plano...") | Out-Null
      $trabalho = {
        param($itens, $dirScripts)
        $resultados = @()
        foreach ($item in $itens) {
          $progresso.Texto = "Revertendo: $($item.Nome)..."
          $caminho = Join-Path $dirScripts $item.Script
          try { & $caminho -Action Reverter 2>&1 | Out-Null } catch {}
          try { $resultados += @{ Nome = $item.Nome; Ligado = ((& $caminho -Action Status 2>&1 | Select-Object -First 1) -match "^LIGADO") } }
          catch { $resultados += @{ Nome = $item.Nome; Ligado = $null } }
        }
        return $resultados
      }
      $emSegundoPlano.Invoke(@($btnGpuStatus, $btnGpuAplicar, $btnGpuReverter), $trabalho, @($itens, $scriptsDir), $callbackGpuReverter, $setStatus)
    } catch {
      "ERRO no BtnGpuReverter: $_`n$($_.ScriptStackTrace)" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao reverter -- veja o log.") | Out-Null
    }
  }.GetNewClosure())

  # --- Preferencia de GPU por jogo ---
  $painelRaiz.Children.Add((New-Rotulo "PREFERÊNCIA DE GPU POR JOGO" "2,18,0,8")) | Out-Null
  $txtExplicaJogo = New-Object System.Windows.Controls.TextBlock
  $txtExplicaJogo.Text = "Escolha o .exe de um jogo pra forçar ele a sempre abrir na placa de vídeo de Alto Desempenho -- útil em notebook com duas placas (integrada + dedicada), quando o Windows escolhe a errada sozinho. Config por conta de usuário, não precisa ser Administrador."
  $txtExplicaJogo.Foreground = $window.FindResource("BrushMuted")
  $txtExplicaJogo.FontSize = 12
  $txtExplicaJogo.TextWrapping = "Wrap"
  $txtExplicaJogo.Margin = "2,0,0,10"
  $painelRaiz.Children.Add($txtExplicaJogo) | Out-Null

  $btnEscolherJogo = New-Object System.Windows.Controls.Button
  $btnEscolherJogo.Name = "BtnGpuEscolherJogo"
  $btnEscolherJogo.Content = "Escolher jogo (.exe)..."
  $btnEscolherJogo.Style = $window.FindResource("BtnPrimary")
  $btnEscolherJogo.HorizontalAlignment = "Left"
  $btnEscolherJogo.Margin = "0,0,0,12"
  $painelRaiz.Children.Add($btnEscolherJogo) | Out-Null

  $listaPreferencias = New-Object System.Windows.Controls.StackPanel
  $listaPreferencias.Margin = "0,0,0,10"
  $painelRaiz.Children.Add($listaPreferencias) | Out-Null

  $btnEscolherJogo.Add_Click({
    try {
      $dlg = New-Object Microsoft.Win32.OpenFileDialog
      $dlg.Filter = "Executável do jogo (*.exe)|*.exe"
      $dlg.Title = "Escolha o executável do jogo"
      if ($dlg.ShowDialog()) {
        if (-not (Test-ExecutavelEhJogoLegitimo $dlg.FileName)) {
          $setStatus.Invoke("Esse executável não foi reconhecido como um jogo instalado pela Steam, Epic Games ou outro launcher compatível. Só é possível configurar preferência de GPU pra jogos instalados por um launcher oficial.") | Out-Null
          return
        }
        $r = (& (Join-Path $scriptsDir "_gpu_preferencia_jogo.ps1") -Caminho $dlg.FileName -Action Definir 2>&1 | Select-Object -Last 1)
        $setStatus.Invoke("$r") | Out-Null
        Carregar-PreferenciasGpuGUI $window $scriptsDir $listaPreferencias $setStatus $debugLog
      }
    } catch {
      "ERRO no BtnGpuEscolherJogo: $_" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao definir preferência de GPU.") | Out-Null
    }
  }.GetNewClosure())

  # --- Prioridade em tempo real ---
  $painelRaiz.Children.Add((New-Rotulo "PRIORIDADE EM TEMPO REAL (JOGO JÁ ABERTO)" "2,18,0,8")) | Out-Null
  $txtExplicaPrio = New-Object System.Windows.Controls.TextBlock
  $txtExplicaPrio.Text = "Aumenta a prioridade de CPU de um programa que já está rodando agora. Vale só até ele fechar -- não mexe no registro, não é permanente, e reseta sozinho no próximo jogo/reinício."
  $txtExplicaPrio.Foreground = $window.FindResource("BrushMuted")
  $txtExplicaPrio.FontSize = 12
  $txtExplicaPrio.TextWrapping = "Wrap"
  $txtExplicaPrio.Margin = "2,0,0,10"
  $painelRaiz.Children.Add($txtExplicaPrio) | Out-Null

  $linhaPrio = New-Object System.Windows.Controls.StackPanel
  $linhaPrio.Orientation = "Horizontal"
  $linhaPrio.Margin = "0,0,0,10"
  $comboProcessos = New-Object System.Windows.Controls.ComboBox
  $comboProcessos.Name = "ComboGpuProcessos"
  $comboProcessos.Width = 360
  $btnAtualizarProc = New-Object System.Windows.Controls.Button
  $btnAtualizarProc.Name = "BtnGpuAtualizarProcessos"
  $btnAtualizarProc.Content = "Atualizar lista"
  $btnAtualizarProc.Style = $window.FindResource("BtnGhost")
  $btnAtualizarProc.Margin = "10,0,0,0"
  $btnPrioridade = New-Object System.Windows.Controls.Button
  $btnPrioridade.Name = "BtnGpuPrioridade"
  $btnPrioridade.Content = "Aumentar prioridade agora"
  $btnPrioridade.Style = $window.FindResource("BtnPrimary")
  $btnPrioridade.Margin = "10,0,0,0"
  $linhaPrio.Children.Add($comboProcessos) | Out-Null
  $linhaPrio.Children.Add($btnAtualizarProc) | Out-Null
  $linhaPrio.Children.Add($btnPrioridade) | Out-Null
  $painelRaiz.Children.Add($linhaPrio) | Out-Null

  $btnAtualizarProc.Add_Click({
    Carregar-ProcessosGpuGUI $comboProcessos $debugLog
    $setStatus.Invoke("Lista de programas atualizada.") | Out-Null
  }.GetNewClosure())

  $btnPrioridade.Add_Click({
    try {
      $sel = $comboProcessos.SelectedItem
      if (-not $sel -or -not $sel.Tag) { $setStatus.Invoke("Escolha um programa na lista primeiro.") | Out-Null; return }
      $proc = Get-Process -Id $sel.Tag -ErrorAction Stop
      $proc.PriorityClass = "High"
      $setStatus.Invoke("Prioridade de '$($proc.ProcessName)' aumentada pra Alta -- vale só até ele fechar.") | Out-Null
    } catch {
      $setStatus.Invoke("Não consegui mudar a prioridade -- talvez precise ser Administrador.") | Out-Null
    }
  }.GetNewClosure())

  # Carga inicial
  Atualizar-InfoGpuGUI $window $painelGpuInfo $painelVendor $setStatus $debugLog $scriptsDir $emSegundoPlano
  Carregar-PreferenciasGpuGUI $window $scriptsDir $listaPreferencias $setStatus $debugLog
  Carregar-ProcessosGpuGUI $comboProcessos $debugLog

  return $raiz
}
