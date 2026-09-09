# Aba "Config" -- recursos opcionais do Windows (Hyper-V, WSL, etc),
# atalhos pros painéis clássicos de controle, e ferramentas de reparo
# (reaproveitando scripts já existentes onde dá). Cada item tem uma
# descrição curta em português simples, pra qualquer pessoa entender o
# que vai acontecer antes de clicar.
$Global:CatalogoFeatures = @(
  @{ Nome = ".NET Framework 3.5 (necessário pra jogo antigo)"; Feature = "NetFx3" }
  @{ Nome = "Hyper-V (máquina virtual oficial do Windows)"; Feature = "Microsoft-Hyper-V-All" }
  @{ Nome = "Windows Subsystem for Linux (WSL)"; Feature = "Microsoft-Windows-Subsystem-Linux" }
  @{ Nome = "Windows Sandbox (ambiente isolado descartável)"; Feature = "Containers-DisposableClientVM" }
  @{ Nome = "Componentes de mídia legado (WMP, DirectPlay)"; Feature = "WindowsMediaPlayer,DirectPlay" }
)

$Global:CatalogoPaineis = @(
  @{ Nome = "Programas e Recursos"; Comando = "appwiz.cpl"; Desc = "Desinstalar programa ou ativar recurso do Windows." }
  @{ Nome = "Opções de Energia"; Comando = "powercfg.cpl"; Desc = "Ajustar quando a tela apaga e o PC dorme." }
  @{ Nome = "Conexões de Rede"; Comando = "ncpa.cpl"; Desc = "Ver e configurar Wi-Fi/cabo de rede." }
  @{ Nome = "Propriedades do Mouse"; Comando = "main.cpl"; Desc = "Ajustar velocidade, botões e ponteiro do mouse." }
  @{ Nome = "Propriedades do Sistema"; Comando = "sysdm.cpl"; Desc = "Ver nome do PC, processador e ativação do Windows." }
  @{ Nome = "Som"; Comando = "mmsys.cpl"; Desc = "Escolher caixa de som/microfone e ajustar volume." }
  @{ Nome = "Firewall do Windows Defender"; Comando = "firewall.cpl"; Desc = "Permitir ou bloquear programa de acessar a internet." }
  @{ Nome = "Gerenciamento de Disco"; Comando = "diskmgmt.msc"; Desc = "Ver, formatar ou dividir partição do disco." }
  @{ Nome = "Editor de Políticas de Grupo Local"; Comando = "gpedit.msc"; Desc = "Configurações avançadas do Windows (uso avançado)." }
  @{ Nome = "Serviços do Windows"; Comando = "services.msc"; Desc = "Ligar/desligar processos que rodam em segundo plano." }
  @{ Nome = "Agendador de Tarefas"; Comando = "taskschd.msc"; Desc = "Ver e criar tarefa automática do Windows." }
  @{ Nome = "Gerenciador de Dispositivos"; Comando = "devmgmt.msc"; Desc = "Ver e atualizar driver de hardware." }
)

# Cada reparo: Nome, Desc (explicação simples), Modo ("fundo" = roda em
# segundo plano via runspace, "abrir" = só abre uma ferramenta do
# Windows na hora, instantâneo), Acao = chave usada no switch abaixo.
$Global:CatalogoReparos = @(
  @{ Nome = "Reparar rede (Winsock/TCP-IP)"; Desc = "Conserta internet que não conecta ou fica lenta sem motivo aparente."; Modo = "fundo"; Acao = "rede" }
  @{ Nome = "Verificar arquivos do sistema (SFC)"; Desc = "Procura e conserta arquivo do Windows corrompido ou alterado."; Modo = "fundo"; Acao = "sfc" }
  @{ Nome = "Reparar imagem do Windows (DISM)"; Desc = "Conserta o 'molde' que o SFC usa -- rode antes do SFC se ele não resolver sozinho. Precisa de internet."; Modo = "fundo"; Acao = "dism" }
  @{ Nome = "Verificar disco por erro"; Desc = "Procura setor com defeito ou erro no HD/SSD sem precisar reiniciar."; Modo = "fundo"; Acao = "chkdsk" }
  @{ Nome = "Resetar Windows Update"; Desc = "Limpa arquivo temporário de atualização quando o Windows Update trava ou dá erro."; Modo = "fundo"; Acao = "wu" }
  @{ Nome = "Limpar cache de DNS"; Desc = "Esquece endereço de site guardado -- resolve site que não abre mas devia."; Modo = "fundo"; Acao = "dns" }
  @{ Nome = "Reiniciar Spooler de Impressão"; Desc = "Conserta impressora travada ou fila de impressão que não anda."; Modo = "fundo"; Acao = "spooler" }
  @{ Nome = "Restaurar Firewall pro padrão"; Desc = "Desfaz qualquer regra de firewall bloqueando internet/programa. Apaga regra personalizada que você tenha criado."; Modo = "fundo"; Acao = "firewall" }
  @{ Nome = "Reconstruir cache de ícones"; Desc = "Conserta ícone errado ou quebrado na área de trabalho/barra de tarefas."; Modo = "fundo"; Acao = "icones" }
  @{ Nome = "Registrar apps da Microsoft Store de novo"; Desc = "Conserta app da Store (Loja, Configurações, Calculadora) que não abre ou trava."; Modo = "fundo"; Acao = "apps" }
  @{ Nome = "Limpar atualizações antigas"; Desc = "Libera espaço em disco apagando versão antiga de atualização já instalada."; Modo = "fundo"; Acao = "componentcleanup" }
  @{ Nome = "Testar a memória RAM"; Desc = "Abre a ferramenta oficial do Windows pra testar defeito na RAM -- reinicia o PC pra testar."; Modo = "abrir"; Acao = "memtest" }
  @{ Nome = "Diagnóstico do DirectX"; Desc = "Abre a ferramenta oficial do Windows com informação de vídeo/som pra diagnóstico."; Modo = "abrir"; Acao = "dxdiag" }
  @{ Nome = "Restauração do Sistema"; Desc = "Abre a ferramenta oficial pra voltar o Windows a um ponto de restauração anterior."; Modo = "abrir"; Acao = "restore" }
  @{ Nome = "Opções de Recuperação do Windows"; Desc = "Abre Configurações > Recuperação -- reiniciar em modo de reparo ou reinstalar o Windows."; Modo = "abrir"; Acao = "recovery" }
)

function Build-ConfigTab {
  param($window, $scriptsDir, $setStatus, $emSegundoPlano)

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

  # Callback criado com GetNewClosure() UMA vez, no escopo direto de
  # Build-ConfigTab -- nao aninhado dentro do Add_Click (evita o bug de
  # GetNewClosure() aninhado perder variavel do escopo avo).
  $callbackFeatures = {
    param($resultado, $erro)
    if ($erro) {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnInstalarFeatures: $erro" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro -- veja o log.") | Out-Null
      return
    }
    $setStatus.Invoke("$($resultado.Ok) recurso(s) instalado(s), $($resultado.Falha) falharam. Reinicie o PC pra valer.") | Out-Null
  }.GetNewClosure()

  $btnInstalarFeatures.Add_Click({
    try {
      $marcados = @($checkboxesFeature.Values | Where-Object { $_.IsChecked -eq $true })
      if ($marcados.Count -eq 0) { $setStatus.Invoke("Nenhum recurso marcado.") | Out-Null; return }
      $listaFeatures = @($marcados | ForEach-Object { $_.Tag })
      $setStatus.Invoke("Instalando $($listaFeatures.Count) recurso(s) em segundo plano -- a janela continua funcionando normal...") | Out-Null

      $trabalho = {
        param($features)
        $ok = 0; $falha = 0
        foreach ($f in $features) {
          foreach ($nomeFeat in ($f.Feature -split ",")) {
            $progresso.Texto = "Instalando recurso: $($f.Nome)..."
            try {
              Enable-WindowsOptionalFeature -Online -FeatureName $nomeFeat -All -NoRestart -ErrorAction Stop | Out-Null
              $ok++
            } catch { $falha++ }
          }
        }
        return @{ Ok = $ok; Falha = $falha }
      }

      $emSegundoPlano.Invoke(@($btnInstalarFeatures), $trabalho, @(,$listaFeatures), $callbackFeatures, $setStatus)
    } catch {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnInstalarFeatures: $_" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro -- veja o log.") | Out-Null
    }
  }.GetNewClosure())

  # --- Painéis clássicos ---
  $t2 = New-Object System.Windows.Controls.TextBlock
  $t2.Text = "PAINÉIS CLÁSSICOS (ATALHO RÁPIDO)"
  $t2.Style = $window.FindResource("Rotulo")
  $t2.Margin = "2,0,0,8"
  $painel.Children.Add($t2) | Out-Null

  function New-CartaoAcao($window, $texto, $desc, $largura) {
    $borda = New-Object System.Windows.Controls.Border
    $borda.BorderBrush = $window.FindResource("BrushBorder")
    $borda.BorderThickness = 1
    $borda.CornerRadius = 6
    $borda.Margin = "0,0,10,10"
    $borda.Padding = "12,10"
    $borda.Width = $largura

    $painelCartao = New-Object System.Windows.Controls.StackPanel
    $borda.Child = $painelCartao

    $btn = New-Object System.Windows.Controls.Button
    $txtBtn = New-Object System.Windows.Controls.TextBlock
    $txtBtn.Text = $texto
    $txtBtn.TextWrapping = "Wrap"
    $txtBtn.TextAlignment = "Center"
    $btn.Content = $txtBtn
    $btn.Style = $window.FindResource("BtnGhost")
    $btn.MinHeight = 40
    $painelCartao.Children.Add($btn) | Out-Null

    $txtDesc = New-Object System.Windows.Controls.TextBlock
    $txtDesc.Text = $desc
    $txtDesc.Foreground = $window.FindResource("BrushMuted")
    $txtDesc.FontSize = 11
    $txtDesc.TextWrapping = "Wrap"
    $txtDesc.Margin = "2,8,2,0"
    $painelCartao.Children.Add($txtDesc) | Out-Null

    return @{ Cartao = $borda; Botao = $btn }
  }

  $gradePaineis = New-Object System.Windows.Controls.WrapPanel
  foreach ($p in $Global:CatalogoPaineis) {
    $par = New-CartaoAcao $window $p.Nome $p.Desc 260
    $par.Botao.Tag = $p.Comando
    $par.Botao.Add_Click({
      param($s, $e)
      try { Start-Process $s.Tag } catch {}
    })
    $gradePaineis.Children.Add($par.Cartao) | Out-Null
  }
  $painel.Children.Add($gradePaineis) | Out-Null

  # --- Reparos ---
  $t3 = New-Object System.Windows.Controls.TextBlock
  $t3.Text = "REPAROS"
  $t3.Style = $window.FindResource("Rotulo")
  $t3.Margin = "2,20,0,8"
  $painel.Children.Add($t3) | Out-Null

  $gradeReparos = New-Object System.Windows.Controls.WrapPanel
  $botoesReparo = @()
  foreach ($rep in $Global:CatalogoReparos) {
    $par = New-CartaoAcao $window $rep.Nome $rep.Desc 260
    $par.Botao.Name = "BtnReparo_$($rep.Acao)"
    $botoesReparo += $par.Botao
    $gradeReparos.Children.Add($par.Cartao) | Out-Null
  }
  $painel.Children.Add($gradeReparos) | Out-Null

  # Callback compartilhado por todos os botoes de reparo "fundo", criado
  # com GetNewClosure() UMA vez aqui -- nao aninhado dentro do Add_Click
  # de cada botao (evita o bug de GetNewClosure() aninhado perder
  # variavel do escopo avo depois de rodar varios segundos em segundo
  # plano).
  $callbackReparo = {
    param($resultado, $erro)
    if ($erro) {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no reparo: $erro" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro -- veja o log.") | Out-Null
      return
    }
    $setStatus.Invoke("$resultado") | Out-Null
  }.GetNewClosure()

  foreach ($par2 in ($Global:CatalogoReparos | ForEach-Object -Begin { $i = 0 } -Process { $obj = @{ Item = $_; Botao = $botoesReparo[$i] }; $i++; $obj }) ) {
    $rep = $par2.Item
    $btn = $par2.Botao

    if ($rep.Modo -eq "abrir") {
      $btn.Tag = $rep.Acao
      $btn.Add_Click({
        param($s, $e)
        try {
          switch ($s.Tag) {
            "memtest"  { Start-Process "mdsched.exe" }
            "dxdiag"   { Start-Process "dxdiag.exe" }
            "restore"  { Start-Process "rstrui.exe" }
            "recovery" { Start-Process "ms-settings:recovery" }
          }
        } catch {}
      })
    } else {
      $btn.Tag = @{ Acao = $rep.Acao; Nome = $rep.Nome }
      $btn.Add_Click({
        param($s, $e)
        try {
          $acao = $s.Tag.Acao
          $setStatus.Invoke("$($s.Tag.Nome) -- rodando em segundo plano, a janela continua funcionando normal...") | Out-Null

          $trabalho = {
            param($acao, $dirScripts)
            switch ($acao) {
              "rede" {
                $progresso.Texto = "Reparando rede (Winsock/TCP-IP)..."
                $r = (& (Join-Path $dirScripts "_net_repair.ps1") 2>&1) -join " | "
                return $r
              }
              "sfc" {
                $progresso.Texto = "Rodando SFC numa janela separada -- olhe a barra de tarefas..."
                $r = $comandoVisivel.Invoke("Otimizador Pro - Verificando arquivos do sistema (SFC)", "sfc.exe", @("/scannow"))
                if ($r.CodigoSaida -eq 0) { return "Verificação de arquivos do sistema concluída." }
                return "SFC terminou com código $($r.CodigoSaida) -- se não tiver rodado como Administrador, abra o Otimizador Pro como Administrador e tente de novo."
              }
              "dism" {
                $progresso.Texto = "Rodando DISM numa janela separada -- olhe a barra de tarefas..."
                $r = $comandoVisivel.Invoke("Otimizador Pro - Reparando imagem do Windows (DISM)", "DISM.exe", @("/Online", "/Cleanup-Image", "/RestoreHealth"))
                if ($r.CodigoSaida -eq 0) { return "Imagem do Windows reparada com sucesso." }
                return "DISM terminou com código $($r.CodigoSaida) -- confira se precisa de internet ou de rodar como Administrador."
              }
              "chkdsk" {
                $progresso.Texto = "Verificando o disco por erro..."
                try {
                  $r = Repair-Volume -DriveLetter "C" -Scan -ErrorAction Stop
                  return "Verificação de disco concluída: $($r.HealthStatus)."
                } catch { return "AVISO: não consegui verificar o disco ($_)" }
              }
              "wu" {
                $progresso.Texto = "Parando servicos do Windows Update..."
                try {
                  Stop-Service -Name wuauserv, bits -Force -ErrorAction Stop
                  $progresso.Texto = "Limpando pasta de atualizacoes baixadas..."
                  Remove-Item -Path "$env:WINDIR\SoftwareDistribution" -Recurse -Force -ErrorAction SilentlyContinue
                  $progresso.Texto = "Reiniciando servicos do Windows Update..."
                  Start-Service -Name wuauserv, bits -ErrorAction SilentlyContinue
                  return "Windows Update resetado."
                } catch { return "AVISO: precisa ser Administrador pra essa parte." }
              }
              "dns" {
                $progresso.Texto = "Limpando cache de DNS..."
                ipconfig /flushdns 2>&1 | Out-Null
                return "Cache de DNS limpo."
              }
              "spooler" {
                $progresso.Texto = "Reiniciando o spooler de impressao..."
                try {
                  Stop-Service -Name spooler -Force -ErrorAction Stop
                  Remove-Item -Path "$env:WINDIR\System32\spool\PRINTERS\*" -Force -ErrorAction SilentlyContinue
                  Start-Service -Name spooler -ErrorAction Stop
                  return "Spooler de impressão reiniciado."
                } catch { return "AVISO: precisa ser Administrador pra essa parte." }
              }
              "firewall" {
                $progresso.Texto = "Restaurando o firewall pro padrao..."
                $r = (netsh advfirewall reset 2>&1) -join " "
                return "Firewall restaurado pro padrão do Windows."
              }
              "icones" {
                $progresso.Texto = "Reconstruindo cache de icones (a tela vai piscar)..."
                try {
                  Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
                  Start-Sleep -Milliseconds 500
                  Remove-Item "$env:LOCALAPPDATA\IconCache.db" -Force -ErrorAction SilentlyContinue
                  Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache*.db" -Force -ErrorAction SilentlyContinue
                  Start-Process explorer.exe
                  return "Cache de ícones reconstruído."
                } catch { return "AVISO: não consegui limpar o cache de ícones ($_)" }
              }
              "apps" {
                $ok = 0
                $pacotes = @(Get-AppxPackage -AllUsers)
                $i = 0
                foreach ($pacote in $pacotes) {
                  $i++
                  $progresso.Texto = "Registrando apps da Store ($i/$($pacotes.Count))..."
                  try {
                    Add-AppxPackage -DisableDevelopmentMode -Register "$($pacote.InstallLocation)\AppXManifest.xml" -ErrorAction Stop
                    $ok++
                  } catch {}
                }
                return "Apps da Microsoft Store registrados de novo ($ok processado(s))."
              }
              "componentcleanup" {
                $progresso.Texto = "Rodando DISM numa janela separada -- olhe a barra de tarefas..."
                $r = $comandoVisivel.Invoke("Otimizador Pro - Limpando atualizações antigas (DISM)", "DISM.exe", @("/Online", "/Cleanup-Image", "/StartComponentCleanup"))
                if ($r.CodigoSaida -eq 0) { return "Atualizações antigas limpas." }
                return "DISM terminou com código $($r.CodigoSaida) -- confira se precisa de rodar como Administrador."
              }
            }
          }

          $emSegundoPlano.Invoke($botoesReparo, $trabalho, @($acao, $scriptsDir), $callbackReparo, $setStatus)
        } catch {
          $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
          "ERRO no botao de reparo: $_" | Out-File $debugLog -Append
          $setStatus.Invoke("Erro -- veja o log.") | Out-Null
        }
      }.GetNewClosure())
    }
  }

  return $raiz
}
