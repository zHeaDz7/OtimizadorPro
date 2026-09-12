# Aba "Perfis" -- 4 perfis prontos em linguagem simples (Gamers,
# Produtividade, Equilíbrio, Avançado) que aplicam num clique só um
# conjunto curado de itens que JÁ EXISTEM nas abas Ajustes/Placa de
# Vídeo. Não reimplementa nenhuma otimização aqui -- só escolhe QUAIS
# itens já existentes rodar, do mesmo jeito que a aba Ajustes já faz
# manualmente item por item. Segue o mesmo padrão visual (cards) da aba
# "Perfis de Windows Update" (Tab-Updates.ps1).

# Qual script cada perfil aplica -- nomes reais do catalogo em
# $Global:ListaAjustes / $Global:ListaAjustesGPU, resolvidos em tempo de
# execucao (nao duplica Nome/Melhora/Contras aqui).
$Global:PerfisScripts = [ordered]@{
  "Gamers" = @(
    "_power_plan.ps1", "_windows_tweaks.ps1", "_gaming_priority.ps1", "_audio_tweaks.ps1",
    "_fullscreen_opt.ps1", "_defender_exclusions.ps1", "_indexing_exclusion.ps1", "_hags.ps1",
    "_network_tweaks.ps1", "_net_interrupt_moderation.ps1", "_reg_transparencia.ps1", "_ram_trim.ps1"
  )
  "Produtividade" = @(
    "_storage_sense.ps1", "_telemetry.ps1", "_delivery_optimization.ps1", "_reg_animacoes.ps1",
    "_reg_widgets.ps1", "_reg_taskbar_chat.ps1", "_dns_optimizer.ps1", "_ram_trim.ps1"
  )
  "Equilibrio" = @(
    "_windows_tweaks.ps1", "_gaming_priority.ps1", "_fullscreen_opt.ps1", "_defender_exclusions.ps1",
    "_indexing_exclusion.ps1", "_hags.ps1", "_network_tweaks.ps1", "_net_interrupt_moderation.ps1",
    "_reg_transparencia.ps1", "_ram_trim.ps1", "_storage_sense.ps1", "_telemetry.ps1",
    "_delivery_optimization.ps1", "_reg_animacoes.ps1", "_reg_widgets.ps1", "_reg_taskbar_chat.ps1", "_dns_optimizer.ps1"
  )
  "Avancado" = @(
    "_defender_exclusions.ps1", "_mouse_fix.ps1", "_reg_usb_suspend.ps1", "_reg_kernel_timer.ps1",
    "_reg_mouse_queue.ps1", "_reg_islc.ps1", "_reg_accessibility.ps1", "_reg_priority_boost.ps1",
    "_core_parking.ps1", "_gpu_msi_mode.ps1", "_gpu_tdr_delay.ps1", "_reg_hibernacao.ps1",
    "_reg_background_apps.ps1", "_reg_start_ads.ps1", "_reg_fast_startup.ps1", "_reg_sysmain.ps1"
  )
}

# Textos em linguagem simples pra cada script -- reescrita direta do
# campo "Melhora" que ja existe no catalogo (nao inventa reivindicacao
# nova). O expander "Ver o que muda tecnicamente" de cada card mostra o
# Nome tecnico real desses mesmos itens, pra transparencia total.
$Global:PerfisTextoSimples = @{
  "_power_plan.ps1"           = "Processador nunca reduz a velocidade pra economizar energia -- desempenho constante"
  "_windows_tweaks.ps1"       = "O jogo em primeiro plano ganha prioridade sobre os outros programas abertos"
  "_gaming_priority.ps1"      = "O jogo recebe mais fatia de processador/placa de vídeo quando várias coisas rodam ao mesmo tempo"
  "_audio_tweaks.ps1"         = "Remove processamento extra de efeitos sonoros -- menos atraso no áudio"
  "_fullscreen_opt.ps1"       = "Reduz atraso de resposta e telas pretas em jogos mais antigos"
  "_defender_exclusions.ps1"  = "As pastas dos seus jogos carregam mais rápido, sem verificação do antivírus em tempo real"
  "_indexing_exclusion.ps1"   = "Menos uso de disco/processador em segundo plano indexando pastas de jogo"
  "_hags.ps1"                 = "Pode reduzir a latência em jogos e placas de vídeo mais novas"
  "_network_tweaks.ps1"       = "Reduz a latência de rede -- importante pra jogo online"
  "_net_interrupt_moderation.ps1" = "Reduz o atraso entre o pacote de rede chegar e o PC processar -- bom pra jogo competitivo"
  "_reg_transparencia.ps1"    = "Menos peso visual pra placa de vídeo em PC mais fraco"
  "_ram_trim.ps1"              = "Libera memória RAM que programas não devolveram sozinhos"
  "_storage_sense.ps1"        = "Windows limpa arquivos temporários e Lixeira sozinho de vez em quando"
  "_telemetry.ps1"            = "Menos dado enviado pra Microsoft em segundo plano"
  "_delivery_optimization.ps1" = "Para de usar sua internet pra distribuir atualização do Windows pra outros PCs"
  "_reg_animacoes.ps1"        = "Janelas abrem/fecham/minimizam com sensação mais imediata"
  "_reg_widgets.ps1"          = "Barra de tarefas mais limpa, sem o botão de Widgets"
  "_reg_taskbar_chat.ps1"     = "Remove o ícone de Chat/Teams da barra de tarefas"
  "_dns_optimizer.ps1"        = "Resolve nome de site/servidor mais rápido"
  "_mouse_fix.ps1"            = "Mouse responde exatamente ao movimento da mão, sem 'aceleração' que atrapalha a mira"
  "_reg_usb_suspend.ps1"      = "Mouse e teclado nunca 'dormem' -- zero microatraso ao voltar a mexer"
  "_reg_kernel_timer.ps1"     = "Temporização mais precisa do sistema -- pode reduzir engasgos em alguns jogos"
  "_reg_mouse_queue.ps1"      = "Menos chance de perder um clique ou movimento em pico de uso do processador"
  "_reg_islc.ps1"             = "Evita que partes do sistema sejam jogadas pro disco -- resposta mais consistente"
  "_reg_accessibility.ps1"    = "Evita ativar sem querer atalhos de acessibilidade (ex: apertar Shift 5x durante o jogo)"
  "_reg_priority_boost.ps1"   = "O programa que você está usando ganha prioridade sobre os que estão em segundo plano"
  "_core_parking.ps1"         = "Todos os núcleos do processador ficam sempre disponíveis, sem esperar um núcleo 'acordar'"
  "_gpu_msi_mode.ps1"         = "Reduz a latência de interrupção da placa de vídeo"
  "_gpu_tdr_delay.ps1"        = "Evita a tela piscar e voltar por reinício falso do driver da placa de vídeo em cargas pesadas"
  "_reg_hibernacao.ps1"       = "Libera espaço em disco que ficava reservado pra hibernação"
  "_reg_background_apps.ps1" = "Apps da Microsoft Store param de gastar processador/rede quando você não está usando"
  "_reg_start_ads.ps1"        = "Menu Iniciar e Configurações sem propaganda ou apps sugeridos"
  "_reg_fast_startup.ps1"     = "Cada desligamento fica 100% completo -- ajuda depois de trocar driver/placa de vídeo"
  "_reg_sysmain.ps1"          = "Menos uso de processador/disco pré-carregando programas em segundo plano"
}

# Nivel de modulo (nao aninhada dentro de Build-PerfisTab) -- chamada de
# dentro de Add_Click({...}.GetNewClosure()), e GetNewClosure() so capta
# VARIAVEL do escopo onde foi chamado, nunca funcao aninhada do escopo
# pai (mesmo bug ja documentado em Tab-Diagnostico.ps1/Tab-GPU.ps1). Por
# isso tudo que precisa vem por parametro, nada fecha sobre escopo local.
function Invoke-Perfil($nomePerfil, $itens, $botao, $txtResultado, $scriptsDir, $emSegundoPlano, $callbackPerfil, $setStatus, $debugLog) {
  try {
    $setStatus.Invoke("Aplicando perfil $nomePerfil em segundo plano -- a janela continua funcionando normal...") | Out-Null

    $trabalho = {
      param($itens, $dirScripts, $txtResultadoRef)

      function Test-Ligado($item, $saida) {
        $primeira = "$($saida | Select-Object -First 1)"
        switch ($item.Conv) {
          "toggle" { return $primeira -match "^LIGADO" }
          "onoff"  { return (($saida -join " ") -match "Ligado") }
        }
        return $false
      }

      $aplicados = 0
      $naoAplicados = @()
      $i = 0
      foreach ($item in $itens) {
        $i++
        $progresso.Texto = "Aplicando ($i/$($itens.Count)): $($item.Nome)..."
        $caminho = Join-Path $dirScripts $item.Script
        try {
          switch ($item.Conv) {
            "toggle" {
              $saidaAplicar = & $caminho -Action Aplicar 2>&1
              $saidaStatusPos = & $caminho -Action Status 2>&1
              if (Test-Ligado $item $saidaStatusPos) { $aplicados++ }
              else { $naoAplicados += @{ Nome = $item.Nome; SaidaBruta = (@($saidaAplicar) + @($saidaStatusPos)) -join " " } }
            }
            "onoff" {
              $saidaAplicar = & $caminho -Action On 2>&1
              $saidaStatusPos = & $caminho -Action Status 2>&1
              if (Test-Ligado $item $saidaStatusPos) { $aplicados++ }
              else { $naoAplicados += @{ Nome = $item.Nome; SaidaBruta = (@($saidaAplicar) + @($saidaStatusPos)) -join " " } }
            }
            "onoffdireto" {
              & $caminho -Action Off 2>&1 | Out-Null
              $aplicados++
            }
            default {
              & $caminho 2>&1 | Out-Null
              $aplicados++
            }
          }
        } catch {
          $naoAplicados += @{ Nome = $item.Nome; SaidaBruta = "erro ao tentar aplicar: $_" }
        }
      }

      return @{ Aplicados = $aplicados; NaoAplicados = $naoAplicados; TxtResultado = $txtResultadoRef }
    }

    $emSegundoPlano.Invoke(@($botao), $trabalho, @($itens, $scriptsDir, $txtResultado), $callbackPerfil, $setStatus)
  } catch {
    "ERRO no Invoke-Perfil ($nomePerfil): $_`n$($_.ScriptStackTrace)" | Out-File $debugLog -Append
    $setStatus.Invoke("Erro ao aplicar o perfil -- veja o log.") | Out-Null
  }
}

function Get-ItensPerfilPorScripts([string[]]$nomesScripts) {
  $todos = @($Global:ListaAjustes) + @($Global:ListaAjustesGPU)
  $ordenado = @()
  foreach ($nome in $nomesScripts) {
    $item = $todos | Where-Object { $_.Script -eq $nome } | Select-Object -First 1
    if ($item) { $ordenado += $item }
  }
  return $ordenado
}

# Nivel de modulo -- usada so pelo callback (roda na thread principal). O
# $trabalho que roda dentro de Invoke-EmSegundoPlano executa num Runspace
# separado que nao enxerga funcao nem variavel daqui, so o que e passado
# explicitamente por argumento -- por isso o $trabalho so devolve o texto
# bruto de saida, e a traducao pra motivo legivel acontece aqui.
function Get-MotivoNaoAplicadoPerfil($saidaBruta) {
  $texto = ($saidaBruta -join " ")
  if ($texto -match "Administrador") { return "precisa que o Otimizador seja executado como Administrador" }
  if ($texto -match "^NAO SUPORTADO" -or $texto -match "nao suporta|não suport") { return "essa opção não é suportada nesse hardware/driver" }
  if ($texto -match "AVISO:\s*(.+)") { return $matches[1].Trim() }
  return "não foi possível confirmar que a mudança foi aplicada"
}

function Build-PerfisTab {
  param($window, $scriptsDir, $setStatus, $emSegundoPlano)

  $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
  $raiz = New-Object System.Windows.Controls.StackPanel
  $raiz.Margin = "0,0,20,0"

  $titulo = New-Object System.Windows.Controls.TextBlock
  $titulo.Text = "Perfis"
  $titulo.Foreground = $window.FindResource("BrushInk")
  $titulo.FontSize = 18
  $titulo.FontWeight = "Bold"
  $titulo.Margin = "0,0,0,4"
  $raiz.Children.Add($titulo) | Out-Null

  $sub = New-Object System.Windows.Controls.TextBlock
  $sub.Text = "Cada perfil aplica de uma vez um conjunto de otimizações que já existem nas abas Ajustes e Placa de Vídeo -- não precisa escolher item por item. Reversível: reverta cada item manualmente na aba Ajustes se quiser desfazer algo específico."
  $sub.Foreground = $window.FindResource("BrushMuted")
  $sub.TextWrapping = "Wrap"
  $sub.Margin = "0,0,0,20"
  $raiz.Children.Add($sub) | Out-Null

  $grade = New-Object System.Windows.Controls.Primitives.UniformGrid
  $grade.Columns = 2

  function New-CartaoPerfil($window, $titulo, $desc, $itensSimples, $corBotao, $nomeBotao, $detalhes) {
    $borda = New-Object System.Windows.Controls.Border
    $borda.BorderBrush = $window.FindResource("BrushBorder")
    $borda.BorderThickness = 1
    $borda.CornerRadius = 8
    $borda.Margin = "0,0,16,16"
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

    foreach ($linha in $itensSimples) {
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
    $painel.Children.Add($btn) | Out-Null

    $txtResultado = New-Object System.Windows.Controls.TextBlock
    $txtResultado.TextWrapping = "Wrap"
    $txtResultado.FontSize = 11.5
    $txtResultado.Margin = "0,0,0,10"
    $txtResultado.Visibility = "Collapsed"
    $painel.Children.Add($txtResultado) | Out-Null

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

    return @{ Cartao = $borda; Botao = $btn; TxtResultado = $txtResultado }
  }

  $itensGamers = Get-ItensPerfilPorScripts $Global:PerfisScripts["Gamers"]
  $itensProdutividade = Get-ItensPerfilPorScripts $Global:PerfisScripts["Produtividade"]
  $itensEquilibrio = Get-ItensPerfilPorScripts $Global:PerfisScripts["Equilibrio"]
  $itensAvancado = Get-ItensPerfilPorScripts $Global:PerfisScripts["Avancado"]

  function Get-BulletsSimples($itens) {
    return @($itens | ForEach-Object {
      if ($Global:PerfisTextoSimples.ContainsKey($_.Script)) { $Global:PerfisTextoSimples[$_.Script] } else { $_.Melhora }
    })
  }

  $cGamers = New-CartaoPerfil $window "Gamers" "Foco total em desempenho pra jogar -- prioridade de processador/placa de vídeo pro jogo, latência de rede menor, sem enfeite visual atrapalhando." (Get-BulletsSimples $itensGamers) "BtnPrimary" "BtnPerfilGamersAplicar" @($itensGamers | ForEach-Object { $_.Nome })

  $cProdutividade = New-CartaoPerfil $window "Produtividade" "Pra quem usa o PC mais pra trabalho/estudo do que pra jogo -- limpeza automática, menos coisa rodando em segundo plano, sem mexer em nada que afete desempenho de jogo." (Get-BulletsSimples $itensProdutividade) "BtnGhost" "BtnPerfilProdutividadeAplicar" @($itensProdutividade | ForEach-Object { $_.Nome })

  $cEquilibrio = New-CartaoPerfil $window "Equilíbrio (Gamer + Produtividade)" "Combina o essencial dos dois perfis acima -- bom desempenho em jogo sem abrir mão da limpeza/organização do dia a dia. Deixa de fora os itens mais extremos de cada lado (ex: energia sempre no máximo)." (Get-BulletsSimples $itensEquilibrio) "BtnGhost" "BtnPerfilEquilibrioAplicar" @($itensEquilibrio | ForEach-Object { $_.Nome })

  $cAvancado = New-CartaoPerfil $window "Avançado" "Pra quem já manja e quer ir além -- ajustes mais profundos de registro/hardware. NÃO desliga Windows Defender nem Windows Update por completo -- só usa exclusões e ajustes que já são seguros e reversíveis no restante do app." (Get-BulletsSimples $itensAvancado) "BtnGhost" "BtnPerfilAvancadoAplicar" @($itensAvancado | ForEach-Object { $_.Nome })

  $grade.Children.Add($cGamers.Cartao) | Out-Null
  $grade.Children.Add($cProdutividade.Cartao) | Out-Null
  $grade.Children.Add($cEquilibrio.Cartao) | Out-Null
  $grade.Children.Add($cAvancado.Cartao) | Out-Null
  $raiz.Children.Add($grade) | Out-Null

  $avisoFinal = New-Object System.Windows.Controls.TextBlock
  $avisoFinal.Text = "Nenhum perfil desliga o Windows Defender ou o Windows Update por completo -- essa é uma regra permanente do Otimizador Pro."
  $avisoFinal.Foreground = $window.FindResource("BrushMuted")
  $avisoFinal.FontSize = 11.5
  $avisoFinal.TextWrapping = "Wrap"
  $avisoFinal.Margin = "0,4,0,0"
  $raiz.Children.Add($avisoFinal) | Out-Null

  # Callback compartilhado pelos 4 perfis, criado com GetNewClosure() UMA
  # vez aqui no escopo direto de Build-PerfisTab -- nao aninhado dentro de
  # cada Add_Click (evita o bug de GetNewClosure() aninhado perder
  # variavel do escopo avo).
  $callbackPerfil = {
    param($resultado, $erro)
    if ($erro) {
      "ERRO ao aplicar perfil: $erro" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao aplicar o perfil -- veja o log.") | Out-Null
      return
    }

    $txtResultado = $resultado.TxtResultado
    $aplicados = $resultado.Aplicados
    # NAO envolver $resultado.NaoAplicados em @(...) -- quando o array
    # dentro do hashtable devolvido pelo runspace separado esta REALMENTE
    # vazio, @() em cima dele gera um array fantasma de 1 elemento com
    # $null (confirmado testando isolado -- $resultado vem de uma
    # PSDataCollection de 1 item, e @() nessa combinacao especifica nao
    # preserva "vazio"). .Count direto, sem @(), e confiavel.
    $qtdFalhas = 0
    if ($resultado.NaoAplicados) { $qtdFalhas = $resultado.NaoAplicados.Count }

    $txtResultado.Visibility = "Visible"
    if ($qtdFalhas -eq 0) {
      $txtResultado.Text = "$aplicados item(ns) aplicado(s) e confirmado(s)."
      $txtResultado.Foreground = $window.FindResource("BrushGood")
    } else {
      $motivos = @($resultado.NaoAplicados | ForEach-Object { "$($_.Nome): $(Get-MotivoNaoAplicadoPerfil $_.SaidaBruta)" })
      $txtResultado.Text = "$aplicados aplicado(s). $qtdFalhas não puderam ser aplicados -- " + ($motivos -join "; ")
      $txtResultado.Foreground = $window.FindResource("BrushAccentInk")
    }

    $setStatus.Invoke("Perfil aplicado: $aplicados item(ns) confirmado(s), $qtdFalhas não aplicado(s).") | Out-Null
  }.GetNewClosure()

  $cGamers.Botao.Add_Click({ Invoke-Perfil "Gamers" $itensGamers $cGamers.Botao $cGamers.TxtResultado $scriptsDir $emSegundoPlano $callbackPerfil $setStatus $debugLog }.GetNewClosure())
  $cProdutividade.Botao.Add_Click({ Invoke-Perfil "Produtividade" $itensProdutividade $cProdutividade.Botao $cProdutividade.TxtResultado $scriptsDir $emSegundoPlano $callbackPerfil $setStatus $debugLog }.GetNewClosure())
  $cEquilibrio.Botao.Add_Click({ Invoke-Perfil "Equilíbrio" $itensEquilibrio $cEquilibrio.Botao $cEquilibrio.TxtResultado $scriptsDir $emSegundoPlano $callbackPerfil $setStatus $debugLog }.GetNewClosure())
  $cAvancado.Botao.Add_Click({ Invoke-Perfil "Avançado" $itensAvancado $cAvancado.Botao $cAvancado.TxtResultado $scriptsDir $emSegundoPlano $callbackPerfil $setStatus $debugLog }.GetNewClosure())

  $sv = New-Object System.Windows.Controls.ScrollViewer
  $sv.Content = $raiz
  return $sv
}
