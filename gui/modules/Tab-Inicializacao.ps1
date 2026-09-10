# Aba "Inicialização" -- lista tudo que abre sozinho junto com o Windows
# e deixa a pessoa escolher o que desativar. Cobre TRÊS lugares onde um
# programa pode se registrar pra abrir sozinho:
#   - Pasta Inicializar (atalho)
#   - Registro (Run/RunOnce)
#   - Tarefa Agendada com gatilho de logon/inicialização
# O terceiro é o ponto cego real: o Gerenciador de Tarefas > aba
# Inicializar do Windows NÃO mostra Tarefas Agendadas -- só os dois
# primeiros. Foi assim que o Ubisoft Connect ficou "escondido" mesmo
# aparecendo na tela toda vez que o Windows ligava.
#
# Tudo reversível: registro é renomeado com prefixo (nunca apagado),
# atalho da pasta é movido pra uma subpasta (nunca apagado), tarefa
# agendada é só desabilitada (nunca apagada).
$Global:PrefixoInicializacaoDesativada = "Desativado_OtimizadorPro_"

function Build-InicializacaoTab {
  param($window, $scriptsDir, $setStatus, $emSegundoPlano)

  $raiz = New-Object System.Windows.Controls.StackPanel
  $raiz.Margin = "0,0,20,0"

  $titulo = New-Object System.Windows.Controls.TextBlock
  $titulo.Text = "Inicialização"
  $titulo.Foreground = $window.FindResource("BrushInk")
  $titulo.FontSize = 18
  $titulo.FontWeight = "Bold"
  $titulo.Margin = "0,0,0,4"
  $raiz.Children.Add($titulo) | Out-Null

  $sub = New-Object System.Windows.Controls.TextBlock
  $sub.Text = "Lista tudo que abre sozinho com o Windows -- inclusive Tarefas Agendadas, que o Gerenciador de Tarefas do Windows NÃO mostra (foi assim que o Ubisoft Connect ficava se abrindo sozinho sem aparecer em lugar nenhum). Nada é apagado -- só desativado, e dá pra reverter aqui mesmo a qualquer momento."
  $sub.Foreground = $window.FindResource("BrushMuted")
  $sub.TextWrapping = "Wrap"
  $sub.Margin = "0,0,0,16"
  $raiz.Children.Add($sub) | Out-Null

  $avisoCuidado = New-Object System.Windows.Controls.TextBlock
  $avisoCuidado.Text = "Só desative o que você reconhece com certeza. Coisa tipo antivírus, driver de áudio/RGB ou sincronização de nuvem geralmente precisa continuar ligada."
  $avisoCuidado.Foreground = $window.FindResource("BrushBad")
  $avisoCuidado.TextWrapping = "Wrap"
  $avisoCuidado.FontSize = 11.5
  $avisoCuidado.Margin = "0,0,0,16"
  $raiz.Children.Add($avisoCuidado) | Out-Null

  $barraBotoes = New-Object System.Windows.Controls.StackPanel
  $barraBotoes.Orientation = "Horizontal"
  $barraBotoes.Margin = "0,0,0,16"
  $btnVerificar = New-Object System.Windows.Controls.Button
  $btnVerificar.Name = "BtnInicializacaoVerificar"
  $btnVerificar.Content = "Verificar itens de inicialização"
  $btnVerificar.Style = $window.FindResource("BtnPrimary")
  $btnVerificar.Margin = "0,0,10,0"
  $btnDesativar = New-Object System.Windows.Controls.Button
  $btnDesativar.Name = "BtnInicializacaoDesativar"
  $btnDesativar.Content = "Desativar selecionados"
  $btnDesativar.Style = $window.FindResource("BtnGhost")
  $btnDesativar.Margin = "0,0,10,0"
  $btnReativar = New-Object System.Windows.Controls.Button
  $btnReativar.Name = "BtnInicializacaoReativar"
  $btnReativar.Content = "Reativar selecionados"
  $btnReativar.Style = $window.FindResource("BtnGhost")
  $barraBotoes.Children.Add($btnVerificar) | Out-Null
  $barraBotoes.Children.Add($btnDesativar) | Out-Null
  $barraBotoes.Children.Add($btnReativar) | Out-Null
  $raiz.Children.Add($barraBotoes) | Out-Null

  $painelLista = New-Object System.Windows.Controls.StackPanel
  $raiz.Children.Add($painelLista) | Out-Null

  $txtVazio = New-Object System.Windows.Controls.TextBlock
  $txtVazio.Text = "Clique em 'Verificar itens de inicialização' pra ver a lista."
  $txtVazio.Foreground = $window.FindResource("BrushMuted")
  $txtVazio.Margin = "0,10,0,0"
  $painelLista.Children.Add($txtVazio) | Out-Null

  $checkboxesPorItem = @{}

  # Callbacks criados com GetNewClosure() UMA vez, aqui no escopo direto
  # de Build-InicializacaoTab -- nao aninhados dentro do Add_Click.
  $callbackVerificar = {
    param($resultado, $erro)
    if ($erro) {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnInicializacaoVerificar: $erro" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao verificar -- veja o log.") | Out-Null
      return
    }

    $painelLista.Children.Clear()
    $checkboxesPorItem.Clear()

    if ($resultado.Count -eq 0) {
      $txt = New-Object System.Windows.Controls.TextBlock
      $txt.Text = "Nenhum item de inicialização encontrado."
      $txt.Foreground = $window.FindResource("BrushMuted")
      $painelLista.Children.Add($txt) | Out-Null
      $setStatus.Invoke("Verificação concluída: nenhum item encontrado.") | Out-Null
      return
    }

    $grade = New-Object System.Windows.Controls.WrapPanel
    $i = 0
    foreach ($item in $resultado) {
      $i++
      $cartao = New-Object System.Windows.Controls.Border
      $cartao.Width = 400
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
      $cb.Tag = $item
      $painelCartao.Children.Add($cb) | Out-Null

      $txtInfo = New-Object System.Windows.Controls.TextBlock
      $corEstado = if ($item.Estado -eq "Ativo") { $window.FindResource("BrushGood") } else { $window.FindResource("BrushMuted") }
      $txtInfo.Text = "$($item.Tipo) -- $($item.Estado)"
      $txtInfo.Foreground = $corEstado
      $txtInfo.FontSize = 11
      $txtInfo.Margin = "26,3,0,0"
      $painelCartao.Children.Add($txtInfo) | Out-Null

      if ($item.Comando) {
        $txtCmd = New-Object System.Windows.Controls.TextBlock
        $txtCmd.Text = $item.Comando
        $txtCmd.Foreground = $window.FindResource("BrushMuted")
        $txtCmd.FontSize = 10.5
        $txtCmd.TextWrapping = "Wrap"
        $txtCmd.Margin = "26,2,0,0"
        $painelCartao.Children.Add($txtCmd) | Out-Null
      }

      $chaveUnica = "$($item.Tipo)|$($item.ChaveOuId)|$($item.Nome)|$($item.Estado)"
      $checkboxesPorItem[$chaveUnica] = $cb
      $grade.Children.Add($cartao) | Out-Null
    }
    $painelLista.Children.Add($grade) | Out-Null

    $ativos = @($resultado | Where-Object { $_.Estado -eq "Ativo" }).Count
    $desativados = @($resultado | Where-Object { $_.Estado -eq "Desativado" }).Count
    $setStatus.Invoke("Verificação concluída: $ativos ativo(s), $desativados já desativado(s).") | Out-Null
  }.GetNewClosure()

  $btnVerificar.Add_Click({
    try {
      $setStatus.Invoke("Verificando itens de inicialização (registro, pasta e tarefas agendadas) em segundo plano...") | Out-Null

      $trabalho = {
        $prefixo = "Desativado_OtimizadorPro_"
        $itens = @()

        $progresso.Texto = "Lendo pasta de Inicializar e Registro..."
        $ativos = @(Get-CimInstance Win32_StartupCommand -ErrorAction SilentlyContinue)
        foreach ($a in $ativos) {
          $tipo = if ($a.Location -match "Startup") { "Pasta" } else { "Registro" }
          $itens += [PSCustomObject]@{ Nome = $a.Name; Tipo = $tipo; Estado = "Ativo"; ChaveOuId = $a.Location; Comando = $a.Command }
        }

        $progresso.Texto = "Lendo itens ja desativados antes..."
        $chavesRun = @(
          "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
          "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
          "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
        )
        foreach ($chave in $chavesRun) {
          if (Test-Path $chave) {
            $valores = Get-Item $chave
            foreach ($nomeValor in $valores.GetValueNames()) {
              if ($nomeValor -like "$prefixo*") {
                $comando = (Get-ItemProperty -Path $chave -Name $nomeValor -ErrorAction SilentlyContinue).$nomeValor
                $itens += [PSCustomObject]@{
                  Nome = $nomeValor.Substring($prefixo.Length)
                  Tipo = "Registro"
                  Estado = "Desativado"
                  ChaveOuId = $chave
                  Comando = $comando
                }
              }
            }
          }
        }
        $pastaOrigem = [Environment]::GetFolderPath("Startup")
        $pastaDesativados = Join-Path $pastaOrigem "Desativados_OtimizadorPro"
        if (Test-Path $pastaDesativados) {
          Get-ChildItem $pastaDesativados -File -ErrorAction SilentlyContinue | ForEach-Object {
            $itens += [PSCustomObject]@{ Nome = $_.Name; Tipo = "Pasta"; Estado = "Desativado"; ChaveOuId = $pastaDesativados; Comando = $null }
          }
        }

        $progresso.Texto = "Lendo tarefas agendadas com gatilho de logon..."
        # Cobre a raiz E subpastas de terceiros (ex: \Ubisoft\...) -- so
        # exclui \Microsoft\Windows\... (namespace reservado do proprio
        # Windows, onde ficam as ~30 tarefas internas do sistema que
        # nunca devem aparecer aqui).
        $tarefas = @(Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.TaskPath -notmatch "^\\Microsoft\\Windows\\" })
        foreach ($t in $tarefas) {
          $gatilhos = $t.Triggers | Where-Object { $_.CimClass.CimClassName -match "LogonTrigger|BootTrigger" }
          if ($gatilhos) {
            $acao = $t.Actions | Select-Object -First 1
            $estado = if ($t.State -eq "Disabled") { "Desativado" } else { "Ativo" }
            $itens += [PSCustomObject]@{
              Nome = $t.TaskName
              Tipo = "Tarefa Agendada"
              Estado = $estado
              ChaveOuId = "$($t.TaskPath)::$($t.TaskName)"
              Comando = "$($acao.Execute) $($acao.Arguments)".Trim()
            }
          }
        }

        return $itens
      }

      $emSegundoPlano.Invoke(@($btnVerificar, $btnDesativar, $btnReativar), $trabalho, @(), $callbackVerificar, $setStatus)
    } catch {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnInicializacaoVerificar: $_`n$($_.ScriptStackTrace)" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao verificar -- veja o log.") | Out-Null
    }
  }.GetNewClosure())

  $callbackDesativar = {
    param($resultado, $erro)
    if ($erro) {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnInicializacaoDesativar: $erro" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao desativar -- veja o log.") | Out-Null
      return
    }
    $setStatus.Invoke("Pronto: $($resultado.Ok) item(ns) desativado(s), $($resultado.Falha) falharam. Clique em 'Verificar' de novo pra atualizar a lista.") | Out-Null
  }.GetNewClosure()

  $btnDesativar.Add_Click({
    try {
      $marcados = @($checkboxesPorItem.Values | Where-Object { $_.IsChecked -eq $true -and $_.Tag.Estado -eq "Ativo" })
      if ($marcados.Count -eq 0) { $setStatus.Invoke("Nenhum item ativo marcado.") | Out-Null; return }
      $itens = @($marcados | ForEach-Object { $_.Tag })
      $setStatus.Invoke("Desativando $($itens.Count) item(ns) em segundo plano...") | Out-Null

      $trabalho = {
        param($itens)
        $prefixo = "Desativado_OtimizadorPro_"
        $ok = 0; $falha = 0
        foreach ($item in $itens) {
          try {
            switch ($item.Tipo) {
              "Registro" {
                $valor = (Get-ItemProperty -Path $item.ChaveOuId -Name $item.Nome -ErrorAction Stop).($item.Nome)
                Set-ItemProperty -Path $item.ChaveOuId -Name "$prefixo$($item.Nome)" -Value $valor -Force
                Remove-ItemProperty -Path $item.ChaveOuId -Name $item.Nome -Force
                $ok++
              }
              "Pasta" {
                $pastaOrigem = [Environment]::GetFolderPath("Startup")
                $pastaDesativados = Join-Path $pastaOrigem "Desativados_OtimizadorPro"
                New-Item -ItemType Directory -Force -Path $pastaDesativados | Out-Null
                $arquivo = Get-ChildItem $pastaOrigem -Filter "*$($item.Nome)*" -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($arquivo) { Move-Item -LiteralPath $arquivo.FullName -Destination $pastaDesativados -Force; $ok++ } else { $falha++ }
              }
              "Tarefa Agendada" {
                $partes = $item.ChaveOuId -split "::", 2
                Disable-ScheduledTask -TaskPath $partes[0] -TaskName $partes[1] -ErrorAction Stop | Out-Null
                $ok++
              }
            }
          } catch { $falha++ }
        }
        return @{ Ok = $ok; Falha = $falha }
      }

      $emSegundoPlano.Invoke(@($btnVerificar, $btnDesativar, $btnReativar), $trabalho, @(,$itens), $callbackDesativar, $setStatus)
    } catch {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnInicializacaoDesativar: $_`n$($_.ScriptStackTrace)" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao desativar -- veja o log.") | Out-Null
    }
  }.GetNewClosure())

  $callbackReativar = {
    param($resultado, $erro)
    if ($erro) {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnInicializacaoReativar: $erro" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao reativar -- veja o log.") | Out-Null
      return
    }
    $setStatus.Invoke("Pronto: $($resultado.Ok) item(ns) reativado(s), $($resultado.Falha) falharam. Clique em 'Verificar' de novo pra atualizar a lista.") | Out-Null
  }.GetNewClosure()

  $btnReativar.Add_Click({
    try {
      $marcados = @($checkboxesPorItem.Values | Where-Object { $_.IsChecked -eq $true -and $_.Tag.Estado -eq "Desativado" })
      if ($marcados.Count -eq 0) { $setStatus.Invoke("Nenhum item desativado marcado.") | Out-Null; return }
      $itens = @($marcados | ForEach-Object { $_.Tag })
      $setStatus.Invoke("Reativando $($itens.Count) item(ns) em segundo plano...") | Out-Null

      $trabalho = {
        param($itens)
        $prefixo = "Desativado_OtimizadorPro_"
        $ok = 0; $falha = 0
        foreach ($item in $itens) {
          try {
            switch ($item.Tipo) {
              "Registro" {
                $nomeDesativado = "$prefixo$($item.Nome)"
                $valor = (Get-ItemProperty -Path $item.ChaveOuId -Name $nomeDesativado -ErrorAction Stop).$nomeDesativado
                Set-ItemProperty -Path $item.ChaveOuId -Name $item.Nome -Value $valor -Force
                Remove-ItemProperty -Path $item.ChaveOuId -Name $nomeDesativado -Force
                $ok++
              }
              "Pasta" {
                $pastaOrigem = [Environment]::GetFolderPath("Startup")
                $caminhoArquivo = Join-Path $item.ChaveOuId $item.Nome
                Move-Item -LiteralPath $caminhoArquivo -Destination $pastaOrigem -Force
                $ok++
              }
              "Tarefa Agendada" {
                $partes = $item.ChaveOuId -split "::", 2
                Enable-ScheduledTask -TaskPath $partes[0] -TaskName $partes[1] -ErrorAction Stop | Out-Null
                $ok++
              }
            }
          } catch { $falha++ }
        }
        return @{ Ok = $ok; Falha = $falha }
      }

      $emSegundoPlano.Invoke(@($btnVerificar, $btnDesativar, $btnReativar), $trabalho, @(,$itens), $callbackReativar, $setStatus)
    } catch {
      $debugLog = Join-Path $env:TEMP "otimizadorpro_gui_debug.txt"
      "ERRO no BtnInicializacaoReativar: $_`n$($_.ScriptStackTrace)" | Out-File $debugLog -Append
      $setStatus.Invoke("Erro ao reativar -- veja o log.") | Out-Null
    }
  }.GetNewClosure())

  return $raiz
}
