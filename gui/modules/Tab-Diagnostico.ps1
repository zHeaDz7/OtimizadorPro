# Aba "Diagnóstico" -- lê o hardware real do PC (CPU, RAM, GPU, disco) e
# calcula uma pontuação de otimização: quantos itens do catálogo de
# Ajustes já estão aplicados agora vs quantos poderiam estar (100%).
# Mostra isso como um gráfico de barra simples, desenhado com formas do
# WPF mesmo (sem biblioteca externa) -- pra pessoa ver de relance como
# o PC está e o quanto dá pra melhorar.

# Funcao de nivel de modulo (nao aninhada dentro de Build-DiagnosticoTab)
# -- GetNewClosure() so "engarrafa" VARIAVEIS do escopo, nunca funcoes
# locais, entao uma funcao definida dentro de Build-DiagnosticoTab
# nao existe mais quando o callback assincrono roda de dentro de
# Invoke-EmSegundoPlano (escopo totalmente diferente). Precisa estar
# aqui, no nivel do modulo, pra ficar sempre visivel.
function Formatar-NumeroGB([double]$gb) {
  if ($gb -ge 1000) { return "$([math]::Round($gb / 1000, 1)) TB" }
  return "$gb GB"
}

# Scripts que NUNCA contam no placar nem sao auto-aplicados pelo "Aplicar
# tudo que falta" -- ficam disponiveis como opt-in manual na aba Ajustes,
# mas sao preferencia puramente cosmetica (barra de tarefas), ferramenta
# de sessao/temporaria (pausar o Windows Search antes de jogar, reverter
# depois), ou uma limitacao real de hardware/driver confirmada nessa
# maquina (Core Parking -- o Windows trava o valor maximo em 0 mesmo no
# plano de energia menos restritivo que existe, confirmado via powercfg
# e registro direto -- nao e algo que o script consiga forcar).
$Global:ScriptsExcluidosDoPlacar = @("_reg_taskbar_esquerda.ps1", "_search_pause.ps1", "_core_parking.ps1")

# Funcao de nivel de modulo, usada só pelo callback (que roda de volta na
# thread principal, não dentro do $trabalho de Invoke-EmSegundoPlano --
# aquele roda num Runspace totalmente separado que não enxerga nem
# variavel nem funcao daqui, só o que é passado explicitamente por
# argumento/AddArgument). Por isso o $trabalho só devolve o texto bruto
# de saída de cada item não aplicado, e é aqui que a gente traduz isso
# num motivo legível.
function Get-MotivoNaoAplicado($saidaBruta) {
  $texto = ($saidaBruta -join " ")
  if ($texto -match "Administrador") { return "precisa que o Otimizador seja executado como Administrador" }
  if ($texto -match "^NAO SUPORTADO" -or $texto -match "nao suporta|não suport") { return "essa opção não é suportada nesse hardware/driver" }
  if ($texto -match "AVISO:\s*(.+)") { return $matches[1].Trim() }
  return "não foi possível confirmar que a mudança foi aplicada"
}

function New-BarraProgresso($window, $largura, $altura, $corFundo, $corPreenchimento) {
  $trilho = New-Object System.Windows.Controls.Border
  $trilho.Width = $largura
  $trilho.Height = $altura
  $trilho.CornerRadius = $altura / 2
  $trilho.Background = $corFundo
  $trilho.ClipToBounds = $true

  $preenchimento = New-Object System.Windows.Controls.Border
  $preenchimento.Height = $altura
  $preenchimento.Width = 0
  $preenchimento.CornerRadius = $altura / 2
  $preenchimento.Background = $corPreenchimento
  $preenchimento.HorizontalAlignment = "Left"

  $trilho.Child = $preenchimento
  return @{ Trilho = $trilho; Preenchimento = $preenchimento; LarguraMax = $largura }
}

function Set-BarraPct($barra, [double]$pct) {
  $pct = [math]::Max(0, [math]::Min(100, $pct))
  $barra.Preenchimento.Width = $barra.LarguraMax * ($pct / 100)
}

function Build-DiagnosticoTab {
  param($window, $scriptsDir, $setStatus, $emSegundoPlano)

  $raiz = New-Object System.Windows.Controls.ScrollViewer
  $painel = New-Object System.Windows.Controls.StackPanel
  $painel.Margin = "0,0,20,0"
  $raiz.Content = $painel

  $titulo = New-Object System.Windows.Controls.TextBlock
  $titulo.Text = "Diagnóstico do PC"
  $titulo.Foreground = $window.FindResource("BrushInk")
  $titulo.FontSize = 18
  $titulo.FontWeight = "Bold"
  $titulo.Margin = "0,0,0,4"
  $painel.Children.Add($titulo) | Out-Null

  $sub = New-Object System.Windows.Controls.TextBlock
  $sub.Text = "Lê o hardware do seu PC e mostra quanto das otimizações da aba Ajustes já estão aplicadas -- e quanto dá pra melhorar."
  $sub.Foreground = $window.FindResource("BrushMuted")
  $sub.TextWrapping = "Wrap"
  $sub.Margin = "0,0,0,20"
  $painel.Children.Add($sub) | Out-Null

  # --- Botões ---
  $barraBotoes = New-Object System.Windows.Controls.StackPanel
  $barraBotoes.Orientation = "Horizontal"
  $barraBotoes.Margin = "0,0,0,20"
  $btnVerificar = New-Object System.Windows.Controls.Button
  $btnVerificar.Name = "BtnDiagnosticoVerificar"
  $btnVerificar.Content = "Verificar meu PC agora"
  $btnVerificar.Style = $window.FindResource("BtnPrimary")
  $btnVerificar.Margin = "0,0,10,0"
  $btnAplicarFaltando = New-Object System.Windows.Controls.Button
  $btnAplicarFaltando.Name = "BtnDiagnosticoAplicarFaltando"
  $btnAplicarFaltando.Content = "Aplicar tudo que falta"
  $btnAplicarFaltando.Style = $window.FindResource("BtnGhost")
  $barraBotoes.Children.Add($btnVerificar) | Out-Null
  $barraBotoes.Children.Add($btnAplicarFaltando) | Out-Null
  $painel.Children.Add($barraBotoes) | Out-Null

  # --- Card de hardware ---
  $cardHw = New-Object System.Windows.Controls.Border
  $cardHw.BorderBrush = $window.FindResource("BrushBorder")
  $cardHw.BorderThickness = 1
  $cardHw.CornerRadius = 8
  $cardHw.Padding = 18
  $cardHw.Margin = "0,0,0,16"
  $painelHw = New-Object System.Windows.Controls.StackPanel
  $cardHw.Child = $painelHw

  $tHw = New-Object System.Windows.Controls.TextBlock
  $tHw.Text = "Seu hardware"
  $tHw.Foreground = $window.FindResource("BrushInk")
  $tHw.FontWeight = "Bold"
  $tHw.FontSize = 15
  $tHw.Margin = "0,0,0,10"
  $painelHw.Children.Add($tHw) | Out-Null

  $gradeHw = New-Object System.Windows.Controls.WrapPanel
  $painelHw.Children.Add($gradeHw) | Out-Null
  $painel.Children.Add($cardHw) | Out-Null

  function New-LinhaHw($window, $rotulo) {
    $borda = New-Object System.Windows.Controls.Border
    $borda.Width = 290
    $borda.Margin = "0,0,14,10"
    $painelLinha = New-Object System.Windows.Controls.StackPanel
    $borda.Child = $painelLinha

    $t = New-Object System.Windows.Controls.TextBlock
    $t.Text = $rotulo
    $t.Foreground = $window.FindResource("BrushMuted")
    $t.FontSize = 11
    $painelLinha.Children.Add($t) | Out-Null

    $v = New-Object System.Windows.Controls.TextBlock
    $v.Text = "Verificando..."
    $v.Foreground = $window.FindResource("BrushInk")
    $v.FontSize = 13.5
    $v.TextWrapping = "Wrap"
    $v.Margin = "0,2,0,0"
    $painelLinha.Children.Add($v) | Out-Null

    return @{ Cartao = $borda; Valor = $v }
  }

  $linhaCpu = New-LinhaHw $window "PROCESSADOR"
  $linhaRam = New-LinhaHw $window "MEMÓRIA RAM"
  $linhaGpu = New-LinhaHw $window "PLACA DE VÍDEO"
  $linhaDisco = New-LinhaHw $window "DISCO (C:)"
  $gradeHw.Children.Add($linhaCpu.Cartao) | Out-Null
  $gradeHw.Children.Add($linhaRam.Cartao) | Out-Null
  $gradeHw.Children.Add($linhaGpu.Cartao) | Out-Null
  $gradeHw.Children.Add($linhaDisco.Cartao) | Out-Null

  # --- Card de pontuação ---
  $cardScore = New-Object System.Windows.Controls.Border
  $cardScore.BorderBrush = $window.FindResource("BrushBorder")
  $cardScore.BorderThickness = 1
  $cardScore.CornerRadius = 8
  $cardScore.Padding = 18
  $cardScore.Margin = "0,0,0,16"
  $painelScore = New-Object System.Windows.Controls.StackPanel
  $cardScore.Child = $painelScore

  $tScore = New-Object System.Windows.Controls.TextBlock
  $tScore.Text = "Pontuação de otimização"
  $tScore.Foreground = $window.FindResource("BrushInk")
  $tScore.FontWeight = "Bold"
  $tScore.FontSize = 15
  $tScore.Margin = "0,0,0,4"
  $painelScore.Children.Add($tScore) | Out-Null

  $txtResumoScore = New-Object System.Windows.Controls.TextBlock
  $txtResumoScore.Text = "Clique em 'Verificar meu PC agora' pra ler o estado atual."
  $txtResumoScore.Foreground = $window.FindResource("BrushMuted")
  $txtResumoScore.TextWrapping = "Wrap"
  $txtResumoScore.FontSize = 12.5
  $txtResumoScore.Margin = "0,0,0,14"
  $painelScore.Children.Add($txtResumoScore) | Out-Null

  # Linha "Atual"
  $linhaAtual = New-Object System.Windows.Controls.StackPanel
  $linhaAtual.Margin = "0,0,0,10"
  $rotAtual = New-Object System.Windows.Controls.TextBlock
  $rotAtual.Text = "Como está agora"
  $rotAtual.Foreground = $window.FindResource("BrushMuted")
  $rotAtual.FontSize = 11.5
  $rotAtual.Margin = "0,0,0,4"
  $linhaAtual.Children.Add($rotAtual) | Out-Null
  $linhaAtualBarraTxt = New-Object System.Windows.Controls.StackPanel
  $linhaAtualBarraTxt.Orientation = "Horizontal"
  $barraAtual = New-BarraProgresso $window 500 18 $window.FindResource("BrushSurface2") $window.FindResource("BrushAccent")
  $txtPctAtual = New-Object System.Windows.Controls.TextBlock
  $txtPctAtual.Text = "0%"
  $txtPctAtual.Foreground = $window.FindResource("BrushInk")
  $txtPctAtual.FontWeight = "Bold"
  $txtPctAtual.Margin = "10,0,0,0"
  $txtPctAtual.VerticalAlignment = "Center"
  $linhaAtualBarraTxt.Children.Add($barraAtual.Trilho) | Out-Null
  $linhaAtualBarraTxt.Children.Add($txtPctAtual) | Out-Null
  $linhaAtual.Children.Add($linhaAtualBarraTxt) | Out-Null
  $painelScore.Children.Add($linhaAtual) | Out-Null

  # Linha "Potencial"
  $linhaPotencial = New-Object System.Windows.Controls.StackPanel
  $linhaPotencial.Margin = "0,0,0,16"
  $rotPotencial = New-Object System.Windows.Controls.TextBlock
  $rotPotencial.Text = "Como poderia estar (tudo aplicado)"
  $rotPotencial.Foreground = $window.FindResource("BrushMuted")
  $rotPotencial.FontSize = 11.5
  $rotPotencial.Margin = "0,0,0,4"
  $linhaPotencial.Children.Add($rotPotencial) | Out-Null
  $linhaPotencialBarraTxt = New-Object System.Windows.Controls.StackPanel
  $linhaPotencialBarraTxt.Orientation = "Horizontal"
  $barraPotencial = New-BarraProgresso $window 500 18 $window.FindResource("BrushSurface2") $window.FindResource("BrushGood")
  Set-BarraPct $barraPotencial 100
  $txtPctPotencial = New-Object System.Windows.Controls.TextBlock
  $txtPctPotencial.Text = "100%"
  $txtPctPotencial.Foreground = $window.FindResource("BrushInk")
  $txtPctPotencial.FontWeight = "Bold"
  $txtPctPotencial.Margin = "10,0,0,0"
  $txtPctPotencial.VerticalAlignment = "Center"
  $linhaPotencialBarraTxt.Children.Add($barraPotencial.Trilho) | Out-Null
  $linhaPotencialBarraTxt.Children.Add($txtPctPotencial) | Out-Null
  $linhaPotencial.Children.Add($linhaPotencialBarraTxt) | Out-Null
  $painelScore.Children.Add($linhaPotencial) | Out-Null

  # Breakdown por categoria
  $tCategorias = New-Object System.Windows.Controls.TextBlock
  $tCategorias.Text = "POR CATEGORIA"
  $tCategorias.Style = $window.FindResource("Rotulo")
  $tCategorias.Margin = "0,4,0,10"
  $painelScore.Children.Add($tCategorias) | Out-Null

  $painelCategorias = New-Object System.Windows.Controls.StackPanel
  $painelScore.Children.Add($painelCategorias) | Out-Null

  $painel.Children.Add($cardScore) | Out-Null

  # --- Card de resultado do "Aplicar tudo que falta" (some ate a primeira vez que roda) ---
  $cardResultado = New-Object System.Windows.Controls.Border
  $cardResultado.BorderBrush = $window.FindResource("BrushBorder")
  $cardResultado.BorderThickness = 1
  $cardResultado.CornerRadius = 8
  $cardResultado.Padding = 18
  $cardResultado.Margin = "0,0,0,16"
  $cardResultado.Visibility = "Collapsed"
  $painelResultado = New-Object System.Windows.Controls.StackPanel
  $cardResultado.Child = $painelResultado

  $tResultado = New-Object System.Windows.Controls.TextBlock
  $tResultado.Text = "Resultado de 'Aplicar tudo que falta'"
  $tResultado.Foreground = $window.FindResource("BrushInk")
  $tResultado.FontWeight = "Bold"
  $tResultado.FontSize = 15
  $tResultado.Margin = "0,0,0,10"
  $painelResultado.Children.Add($tResultado) | Out-Null

  $listaResultado = New-Object System.Windows.Controls.StackPanel
  $painelResultado.Children.Add($listaResultado) | Out-Null

  $painel.Children.Add($cardResultado) | Out-Null

  # Callback criado com GetNewClosure() UMA vez no escopo direto da
  # funcao (evita o bug de GetNewClosure() aninhado perder variavel).
  $callbackVerificar = {
    param($resultado, $erro)
    if ($erro) {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnDiagnosticoVerificar: $erro" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao verificar -- veja o log.") | Out-Null
      return
    }

    $linhaCpu.Valor.Text = "$($resultado.CpuNome) ($($resultado.CpuNucleos) núcleos)"
    $linhaRam.Valor.Text = "$($resultado.RamGB) GB"
    $linhaGpu.Valor.Text = "$($resultado.GpuNome)"
    $tipoDiscoTexto = if ($resultado.DiscoTipo) { "$($resultado.DiscoTipo) -- " } else { "" }
    $linhaDisco.Valor.Text = "$tipoDiscoTexto$(Formatar-NumeroGB $resultado.DiscoLivreGB) livre(s) de $(Formatar-NumeroGB $resultado.DiscoTotalGB)"

    $pct = if ($resultado.Aplicaveis -gt 0) { [math]::Round(($resultado.Ligados / $resultado.Aplicaveis) * 100) } else { 0 }
    Set-BarraPct $barraAtual $pct
    $txtPctAtual.Text = "$pct%"
    $txtResumoScore.Text = "$($resultado.Ligados) de $($resultado.Aplicaveis) otimizações da aba Ajustes já estão aplicadas nesse PC."

    $painelCategorias.Children.Clear()
    foreach ($cat in ($resultado.PorCategoria.Keys | Sort-Object)) {
      $info = $resultado.PorCategoria[$cat]

      $linhaCat = New-Object System.Windows.Controls.StackPanel
      $linhaCat.Margin = "0,0,0,8"
      $cabecalhoCat = New-Object System.Windows.Controls.TextBlock
      $cabecalhoCat.Foreground = $window.FindResource("BrushMuted")
      $cabecalhoCat.FontSize = 11.5
      $cabecalhoCat.Margin = "0,0,0,3"

      if ($info.Total -eq 0) {
        $cabecalhoCat.Text = "$cat -- não avaliável no seu hardware"
        $linhaCat.Children.Add($cabecalhoCat) | Out-Null
      } else {
        $pctCat = [math]::Round(($info.Ligados / $info.Total) * 100)
        $cabecalhoCat.Text = "$cat -- $($info.Ligados)/$($info.Total)"
        $linhaCat.Children.Add($cabecalhoCat) | Out-Null

        $barraCat = New-BarraProgresso $window 500 10 $window.FindResource("BrushSurface2") $window.FindResource("BrushAccent")
        Set-BarraPct $barraCat $pctCat
        $linhaCat.Children.Add($barraCat.Trilho) | Out-Null
      }

      $painelCategorias.Children.Add($linhaCat) | Out-Null
    }

    $setStatus.Invoke("Diagnóstico concluído: $pct% das otimizações aplicadas.") | Out-Null
  }.GetNewClosure()

  $btnVerificar.Add_Click({
    try {
      $setStatus.Invoke("Lendo hardware e status das otimizações em segundo plano...") | Out-Null
      $itens = @($Global:ListaAjustes)

      $trabalho = {
        param($itens, $dirScripts, $scriptsExcluidos)
        $ligados = 0
        $aplicaveis = 0
        $porCategoria = @{}
        # Pre-popula toda categoria com item toggle/onoff (nao excluido),
        # mesmo que acabe com Total=0 depois (ex: unico item da categoria
        # relatar "NAO SUPORTADO" nesse hardware) -- assim a aba mostra
        # "nao avaliavel" em vez de sumir a categoria sem explicacao.
        foreach ($item in $itens) {
          if ($item.Conv -ne "toggle" -and $item.Conv -ne "onoff") { continue }
          if ($scriptsExcluidos -contains $item.Script) { continue }
          if (-not $porCategoria.ContainsKey($item.Cat)) { $porCategoria[$item.Cat] = @{ Total = 0; Ligados = 0 } }
        }

        $i = 0
        foreach ($item in $itens) {
          if ($item.Conv -ne "toggle" -and $item.Conv -ne "onoff") { continue }
          if ($scriptsExcluidos -contains $item.Script) { continue }
          $i++
          $progresso.Texto = "Lendo status ($i): $($item.Nome)..."
          $caminho = Join-Path $dirScripts $item.Script
          try {
            $saidaStatus = & $caminho -Action Status 2>&1
            $primeiraLinha = "$($saidaStatus | Select-Object -First 1)"
            if ($primeiraLinha -match "^NAO SUPORTADO") { continue }  # hardware/driver nao permite nessa maquina -- fora do placar

            $aplicaveis++
            $porCategoria[$item.Cat].Total++
            $ligado = $false
            switch ($item.Conv) {
              "toggle" { $ligado = ($primeiraLinha -match "^LIGADO") }
              "onoff"  { $ligado = (($saidaStatus -join " ") -match "Ligado") }
            }
            if ($ligado) { $ligados++; $porCategoria[$item.Cat].Ligados++ }
          } catch {}
        }

        $progresso.Texto = "Lendo hardware..."
        $cpu = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
        $ramBytes = (Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue).TotalPhysicalMemory
        $gpus = @(Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue)
        $gpu = ($gpus | Where-Object { $_.Name -notmatch "Basic Display|Basic Render" } | Select-Object -First 1)
        if (-not $gpu) { $gpu = $gpus | Select-Object -First 1 }
        $discoLogico = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction SilentlyContinue
        $tipoDiscoSSD = $null
        try {
          $numeroDisco = (Get-Partition -DriveLetter C -ErrorAction Stop).DiskNumber
          $tipoDiscoSSD = (Get-PhysicalDisk -ErrorAction Stop | Where-Object { $_.DeviceId -eq $numeroDisco } | Select-Object -First 1).MediaType
        } catch {}

        return @{
          Ligados      = $ligados
          Aplicaveis   = $aplicaveis
          PorCategoria = $porCategoria
          CpuNome      = if ($cpu) { $cpu.Name.Trim() } else { "não detectado" }
          CpuNucleos   = if ($cpu) { $cpu.NumberOfCores } else { "?" }
          RamGB        = if ($ramBytes) { [math]::Round($ramBytes / 1GB, 1) } else { 0 }
          GpuNome      = if ($gpu) { $gpu.Name } else { "não detectada" }
          DiscoTipo    = $tipoDiscoSSD
          DiscoLivreGB = if ($discoLogico) { [math]::Round($discoLogico.FreeSpace / 1GB, 1) } else { 0 }
          DiscoTotalGB = if ($discoLogico) { [math]::Round($discoLogico.Size / 1GB, 1) } else { 0 }
        }
      }

      $emSegundoPlano.Invoke(@($btnVerificar, $btnAplicarFaltando), $trabalho, @($itens, $scriptsDir, $Global:ScriptsExcluidosDoPlacar), $callbackVerificar, $setStatus)
    } catch {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnDiagnosticoVerificar: $_`n$($_.ScriptStackTrace)" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao verificar -- veja o log.") | Out-Null
    }
  }.GetNewClosure())

  $callbackAplicarFaltando = {
    param($resultado, $erro)
    if ($erro) {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnDiagnosticoAplicarFaltando: $erro" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao aplicar -- veja o log.") | Out-Null
      return
    }

    $aplicados = $resultado.Aplicados
    # NAO envolver $resultado.NaoAplicados em @(...) aqui -- $resultado e
    # o objeto devolvido por Invoke-EmSegundoPlano (uma PSDataCollection
    # de 1 item vindo de EndInvoke()); quando o array de dentro do
    # hashtable esta REALMENTE vazio, envolver com @() gera um array
    # fantasma de 1 elemento contendo $null (confirmado testando isolado)
    # -- daria "1 nao aplicado" falso mesmo com tudo certo. Ler .Count
    # direto (sem @()) e o unico jeito confiavel de saber se esta vazio.
    $qtdFalhas = 0
    if ($resultado.NaoAplicados) { $qtdFalhas = $resultado.NaoAplicados.Count }

    $cardResultado.Visibility = "Visible"
    $listaResultado.Children.Clear()

    if ($qtdFalhas -eq 0) {
      $msgOk = New-Object System.Windows.Controls.TextBlock
      $msgOk.Text = "Todos os itens que faltavam foram aplicados e confirmados ($aplicados)."
      $msgOk.Foreground = $window.FindResource("BrushGood")
      $msgOk.TextWrapping = "Wrap"
      $listaResultado.Children.Add($msgOk) | Out-Null
    } else {
      $resumo = New-Object System.Windows.Controls.TextBlock
      $resumo.Text = "$aplicados aplicado(s) e confirmado(s). $qtdFalhas não puderam ser aplicados:"
      $resumo.Foreground = $window.FindResource("BrushInk")
      $resumo.TextWrapping = "Wrap"
      $resumo.Margin = "0,0,0,8"
      $listaResultado.Children.Add($resumo) | Out-Null

      $temMotivoAdmin = $false
      foreach ($na in $resultado.NaoAplicados) {
        $motivo = Get-MotivoNaoAplicado $na.SaidaBruta
        if ($motivo -match "Administrador") { $temMotivoAdmin = $true }
        $linha = New-Object System.Windows.Controls.TextBlock
        $linha.Text = "- $($na.Nome): $motivo"
        $linha.Foreground = $window.FindResource("BrushMuted")
        $linha.TextWrapping = "Wrap"
        $linha.FontSize = 12
        $linha.Margin = "0,0,0,4"
        $listaResultado.Children.Add($linha) | Out-Null
      }

      if ($temMotivoAdmin) {
        $avisoAdmin = New-Object System.Windows.Controls.TextBlock
        $avisoAdmin.Text = "Feche o Otimizador e abra de novo clicando com o botão direito > 'Executar como Administrador' (ou use o OtimizadorPro-GUI.bat) pra aplicar os itens que precisam de permissão elevada."
        $avisoAdmin.Foreground = $window.FindResource("BrushAccentInk")
        $avisoAdmin.TextWrapping = "Wrap"
        $avisoAdmin.Margin = "8,8,0,0"
        $listaResultado.Children.Add($avisoAdmin) | Out-Null
      }
    }

    $setStatus.Invoke("Pronto: $aplicados item(ns) aplicado(s) e confirmado(s). Clique em 'Verificar meu PC agora' de novo pra ver a pontuação atualizada.") | Out-Null
  }.GetNewClosure()

  $btnAplicarFaltando.Add_Click({
    try {
      $setStatus.Invoke("Descobrindo o que ainda falta aplicar...") | Out-Null
      $itens = @($Global:ListaAjustes | Where-Object {
        ($_.Conv -eq "toggle" -or $_.Conv -eq "onoff") -and ($Global:ScriptsExcluidosDoPlacar -notcontains $_.Script)
      })

      $trabalho = {
        param($itens, $dirScripts)

        function Test-Ligado($item, $saida) {
          $primeira = "$($saida | Select-Object -First 1)"
          switch ($item.Conv) {
            "toggle" { return $primeira -match "^LIGADO" }
            "onoff"  { return (($saida -join " ") -match "Ligado") }
          }
          return $false
        }

        $faltando = @()
        foreach ($item in $itens) {
          $caminho = Join-Path $dirScripts $item.Script
          try {
            $saidaStatus = & $caminho -Action Status 2>&1
            if ("$($saidaStatus | Select-Object -First 1)" -match "^NAO SUPORTADO") { continue }
            if (-not (Test-Ligado $item $saidaStatus)) { $faltando += $item }
          } catch {}
        }

        $aplicados = 0
        $naoAplicados = @()
        $i = 0
        foreach ($item in $faltando) {
          $i++
          $progresso.Texto = "Aplicando ($i/$($faltando.Count)): $($item.Nome)..."
          $caminho = Join-Path $dirScripts $item.Script
          try {
            $saidaAplicar = if ($item.Conv -eq "toggle") { & $caminho -Action Aplicar 2>&1 } else { & $caminho -Action On 2>&1 }
            $saidaStatusPos = & $caminho -Action Status 2>&1
            if (Test-Ligado $item $saidaStatusPos) {
              $aplicados++
            } else {
              $naoAplicados += @{ Nome = $item.Nome; SaidaBruta = (@($saidaAplicar) + @($saidaStatusPos)) -join " " }
            }
          } catch {
            $naoAplicados += @{ Nome = $item.Nome; SaidaBruta = "erro ao tentar aplicar: $_" }
          }
        }

        # Garante barra de tarefas centralizada ao final, independente do
        # estado anterior -- Reverter desse script ja seta TaskbarAl=1 (centro).
        try { & (Join-Path $dirScripts "_reg_taskbar_esquerda.ps1") -Action Reverter 2>&1 | Out-Null } catch {}

        return @{ Aplicados = $aplicados; NaoAplicados = $naoAplicados }
      }

      $emSegundoPlano.Invoke(@($btnVerificar, $btnAplicarFaltando), $trabalho, @($itens, $scriptsDir), $callbackAplicarFaltando, $setStatus)
    } catch {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnDiagnosticoAplicarFaltando: $_`n$($_.ScriptStackTrace)" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao aplicar -- veja o log.") | Out-Null
    }
  }.GetNewClosure())

  return $raiz
}
