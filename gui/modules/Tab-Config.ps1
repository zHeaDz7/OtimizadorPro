# Aba "Config" -- recursos opcionais do Windows (Hyper-V, WSL, etc),
# atalhos pros painéis clássicos de controle, e ferramentas de reparo
# (reaproveitando scripts já existentes onde dá). Cada item tem uma
# descrição curta em português simples, pra qualquer pessoa entender o
# que vai acontecer antes de clicar -- e nos Reparos, também como isso
# pode (ou não) beneficiar na hora de jogar.
$Global:CatalogoFeatures = @(
  @{ Nome = ".NET Framework 3.5 (necessário pra jogo antigo)"; Feature = "NetFx3" }
  @{ Nome = "Hyper-V (máquina virtual oficial do Windows)"; Feature = "Microsoft-Hyper-V-All" }
  @{ Nome = "Windows Subsystem for Linux (WSL)"; Feature = "Microsoft-Windows-Subsystem-Linux" }
  @{ Nome = "Windows Sandbox (ambiente isolado descartável)"; Feature = "Containers-DisposableClientVM" }
  @{ Nome = "Componentes de mídia legado (WMP, DirectPlay)"; Feature = "WindowsMediaPlayer,DirectPlay" }
  @{ Nome = "Cliente Telnet (ferramenta de rede/diagnóstico)"; Feature = "TelnetClient" }
  @{ Nome = "Cliente TFTP (ferramenta de rede/diagnóstico)"; Feature = "TFTP" }
  @{ Nome = "Servidor Web IIS (hospedar site/servidor local)"; Feature = "IIS-WebServerRole" }
  @{ Nome = "Impressão em PDF da Microsoft"; Feature = "Printing-PrintToPDFServices-Features" }
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
  @{ Nome = "Configurações de Vídeo"; Comando = "desk.cpl"; Desc = "Trocar resolução e taxa de atualização da tela -- importante pra jogo em 120/144/165/240Hz." }
  @{ Nome = "Data e Hora"; Comando = "timedate.cpl"; Desc = "Ajustar relógio e fuso -- horário errado pode derrubar login de jogo online/anticheat." }
  @{ Nome = "Opções de Internet"; Comando = "inetcpl.cpl"; Desc = "Configuração de proxy/conexão usada pelo navegador e alguns launchers." }
  @{ Nome = "Central de Rede e Compartilhamento"; Comando = "control.exe /name Microsoft.NetworkAndSharingCenter"; Desc = "Visão geral e diagnóstico da sua conexão de rede." }
  @{ Nome = "Monitor de Recursos"; Comando = "resmon.exe"; Desc = "Ve em detalhe o que está usando CPU, disco, rede e memória agora." }
  @{ Nome = "Informações do Sistema"; Comando = "msinfo32.exe"; Desc = "Resumo completo do hardware e software instalado no PC." }
  @{ Nome = "Configuração do Sistema (msconfig)"; Comando = "msconfig.exe"; Desc = "Gerenciar item de inicialização e modo de boot." }
  @{ Nome = "Editor do Registro"; Comando = "regedit.exe"; Desc = "Acesso direto ao registro do Windows -- USO AVANÇADO, mexa só se souber o que está fazendo." }
)

# Cada reparo: Nome, Desc (explicação simples + o que muda pra jogar),
# Modo ("fundo" = roda em segundo plano via runspace, "abrir" = só abre
# uma ferramenta/assistente do Windows na hora), Acao = chave usada no
# switch abaixo.
$Global:CatalogoReparos = @(
  @{ Nome = "Reparar rede (Winsock/TCP-IP)"; Desc = "Conserta internet que não conecta ou fica lenta sem motivo aparente. Pra jogo online: menos perda de pacote e desconexão do servidor."; Modo = "fundo"; Acao = "rede" }
  @{ Nome = "Verificar arquivos do sistema (SFC)"; Desc = "Procura e conserta arquivo do Windows corrompido ou alterado. Evita crash/tela azul causados por arquivo de sistema quebrado."; Modo = "fundo"; Acao = "sfc" }
  @{ Nome = "Reparar imagem do Windows (DISM)"; Desc = "Conserta o 'molde' que o SFC usa -- rode antes do SFC se ele não resolver sozinho. Precisa de internet. Base mais estável = menos travamento aleatório."; Modo = "fundo"; Acao = "dism" }
  @{ Nome = "Verificar disco por erro (rápida)"; Desc = "Procura setor com defeito no HD/SSD sem precisar reiniciar. Disco com erro causa engasgo/freeze no carregamento de fase."; Modo = "fundo"; Acao = "chkdsk" }
  @{ Nome = "Verificação completa de disco (no reinício)"; Desc = "Varredura mais profunda e demorada que a rápida -- roda no próximo reinício do Windows. Use se a verificação rápida não resolver."; Modo = "fundo"; Acao = "chkdskcompleto" }
  @{ Nome = "Resetar Windows Update"; Desc = "Limpa arquivo temporário de atualização quando o Windows Update trava ou dá erro. Update travado consome CPU/disco enquanto você joga."; Modo = "fundo"; Acao = "wu" }
  @{ Nome = "Solucionador de problemas do Windows Update"; Desc = "Assistente oficial da Microsoft, mais guiado que o reset simples -- tenta achar a causa exata antes de corrigir."; Modo = "abrir"; Acao = "troubleshoot_wu" }
  @{ Nome = "Limpar cache de DNS"; Desc = "Esquece endereço de site guardado -- resolve site que não abre mas devia. Ajuda a conectar mais rápido no servidor/login de jogo online."; Modo = "fundo"; Acao = "dns" }
  @{ Nome = "Solucionador de problemas de rede"; Desc = "Assistente oficial do Windows que testa a conexão passo a passo. Bom pra ping alto/desconexão que os reparos automáticos não resolveram."; Modo = "abrir"; Acao = "troubleshoot_rede" }
  @{ Nome = "Solucionador de problemas de áudio"; Desc = "Assistente oficial pra som/microfone que não funciona -- útil pro chat de voz durante o jogo."; Modo = "abrir"; Acao = "troubleshoot_audio" }
  @{ Nome = "Reiniciar Spooler de Impressão"; Desc = "Conserta impressora travada ou fila de impressão que não anda. Não afeta desempenho de jogo -- é só conveniência."; Modo = "fundo"; Acao = "spooler" }
  @{ Nome = "Restaurar Firewall pro padrão"; Desc = "Desfaz qualquer regra de firewall bloqueando internet/programa. Resolve jogo que não conecta ao servidor por bloqueio de firewall. Apaga regra personalizada que você tenha criado."; Modo = "fundo"; Acao = "firewall" }
  @{ Nome = "Reconstruir cache de ícones"; Desc = "Conserta ícone errado ou quebrado na área de trabalho/barra de tarefas. Só visual -- não afeta desempenho."; Modo = "fundo"; Acao = "icones" }
  @{ Nome = "Registrar apps da Microsoft Store de novo"; Desc = "Conserta app da Store (Loja, Xbox App, Game Bar) que não abre ou trava. Útil se o Xbox App/Game Pass parar de funcionar."; Modo = "fundo"; Acao = "apps" }
  @{ Nome = "Resetar cache da Microsoft Store"; Desc = "Limpa o cache da loja -- resolve Store/Xbox App travado ou que não acha um jogo que você já comprou."; Modo = "fundo"; Acao = "wsreset" }
  @{ Nome = "Limpar atualizações antigas"; Desc = "Libera espaço em disco apagando versão antiga de atualização já instalada. Mais espaço livre no SSD ajuda a manter a velocidade de escrita."; Modo = "fundo"; Acao = "componentcleanup" }
  @{ Nome = "Reparar repositório WMI"; Desc = "Conserta um componente interno usado por ferramentas de monitoramento (Gerenciador de Tarefas, apps de temperatura/uso de GPU). Se esses pararem de funcionar, isso costuma resolver."; Modo = "fundo"; Acao = "wmi" }
  @{ Nome = "Testar a memória RAM"; Desc = "Ferramenta oficial do Windows pra testar defeito na RAM -- reinicia o PC pra testar. RAM com defeito causa travamento/crash aleatório em jogo pesado."; Modo = "abrir"; Acao = "memtest" }
  @{ Nome = "Diagnóstico do DirectX"; Desc = "Informação oficial de vídeo/som/DirectX -- a base gráfica que praticamente todo jogo usa no Windows."; Modo = "abrir"; Acao = "dxdiag" }
  @{ Nome = "Relatório de energia (notebook)"; Desc = "Gera um relatório oficial sobre bateria/energia -- mostra se o notebook está limitando o desempenho sem você perceber enquanto joga na tomada."; Modo = "fundo"; Acao = "energia" }
  @{ Nome = "Restauração do Sistema"; Desc = "Volta o Windows a um ponto de restauração anterior. Desfaz uma mudança que começou a dar problema em jogo."; Modo = "abrir"; Acao = "restore" }
  @{ Nome = "Opções de Recuperação do Windows"; Desc = "Reiniciar em modo de reparo ou reinstalar o Windows -- último recurso quando nada mais resolveu."; Modo = "abrir"; Acao = "recovery" }
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
      try {
        if ($s.Tag -match "^control\.exe ") {
          Start-Process "control.exe" -ArgumentList ($s.Tag -replace "^control\.exe ", "")
        } else {
          Start-Process $s.Tag
        }
      } catch {}
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
    $par = New-CartaoAcao $window $rep.Nome $rep.Desc 270
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
            "memtest"          { Start-Process "mdsched.exe" }
            "dxdiag"           { Start-Process "dxdiag.exe" }
            "restore"          { Start-Process "rstrui.exe" }
            "recovery"         { Start-Process "ms-settings:recovery" }
            "troubleshoot_rede"  { Start-Process "msdt.exe" -ArgumentList @("-id", "NetworkDiagnosticsNetworkAdapter") }
            "troubleshoot_audio" { Start-Process "msdt.exe" -ArgumentList @("-id", "AudioPlaybackDiagnostic") }
            "troubleshoot_wu"    { Start-Process "msdt.exe" -ArgumentList @("-id", "WindowsUpdateDiagnostic") }
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
              "chkdskcompleto" {
                $progresso.Texto = "Agendando verificação completa numa janela separada..."
                try {
                  $linha = "title Otimizador Pro - Agendando verificação completa de disco && echo Y| chkdsk C: /f /r"
                  $p = Start-Process -FilePath "cmd.exe" -ArgumentList @("/c", $linha) -Wait -PassThru
                  return "Verificação completa agendada pro próximo reinício do Windows."
                } catch { return "AVISO: precisa ser Administrador pra essa parte." }
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
              "wsreset" {
                $progresso.Texto = "Limpando cache da Microsoft Store..."
                try {
                  Start-Process "wsreset.exe" -Wait -ErrorAction Stop
                  return "Cache da Microsoft Store limpo."
                } catch { return "AVISO: não consegui limpar o cache da Store ($_)" }
              }
              "componentcleanup" {
                $progresso.Texto = "Rodando DISM numa janela separada -- olhe a barra de tarefas..."
                $r = $comandoVisivel.Invoke("Otimizador Pro - Limpando atualizações antigas (DISM)", "DISM.exe", @("/Online", "/Cleanup-Image", "/StartComponentCleanup"))
                if ($r.CodigoSaida -eq 0) { return "Atualizações antigas limpas." }
                return "DISM terminou com código $($r.CodigoSaida) -- confira se precisa de rodar como Administrador."
              }
              "wmi" {
                $progresso.Texto = "Reparando repositório WMI..."
                try {
                  $r = (winmgmt /salvagerepository 2>&1) -join " "
                  return "Repositório WMI reparado."
                } catch { return "AVISO: precisa ser Administrador pra essa parte." }
              }
              "energia" {
                $progresso.Texto = "Gerando relatório de energia (demora cerca de 1 minuto)..."
                try {
                  $caminhoRelatorio = Join-Path $env:TEMP "otimizadorpro_relatorio_energia.html"
                  powercfg /energy /output $caminhoRelatorio /duration 30 2>&1 | Out-Null
                  if (Test-Path $caminhoRelatorio) {
                    Start-Process $caminhoRelatorio
                    return "Relatório de energia gerado e aberto no navegador."
                  }
                  return "AVISO: não consegui gerar o relatório -- precisa ser Administrador."
                } catch { return "AVISO: precisa ser Administrador pra essa parte." }
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
