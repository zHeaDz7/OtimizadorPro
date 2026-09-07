# Reduz latencia de rede com 4 ajustes oficiais do Windows/driver:
# 1) Desliga o algoritmo de Nagle (agrupa pacotes pequenos esperando um
#    tempinho antes de enviar -- bom pra throughput, ruim pra jogo online).
# 2) Desliga a "economia de energia" do adaptador de rede (pode fazer o
#    adaptador entrar em modo baixo consumo entre pacotes, causando picos
#    de latencia).
# 3) Desativa o "NetworkThrottlingIndex" -- por padrao o Windows limita o
#    processamento de rede pra sobrar recursos pra tarefas multimidia
#    (video/audio); como jogos ja usam o mesmo mecanismo (MMCSS) que
#    video/audio, essa limitacao pode atrapalhar o proprio jogo. Recurso
#    oficial documentado pela Microsoft.
# 4) Desliga o "Large Send Offload" (LSO) nos adaptadores fisicos -- o LSO
#    deixa a placa de rede juntar varios pacotes grandes antes de mandar
#    (bom pra transferencia de arquivo grande), mas em alguns
#    drivers/adaptadores isso causa picos de latencia em jogo online.
$ErrorActionPreference = "Stop"

# 1) Desliga economia de energia de TODOS os adaptadores de rede fisicos
$adaptadoresAjustados = 0
try {
  $adapters = Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq "Up" }
  foreach ($a in $adapters) {
    try {
      $pm = Get-NetAdapterPowerManagement -Name $a.Name -ErrorAction Stop
      if ($pm.AllowComputerToTurnOffDevice -ne "Disabled") {
        Set-NetAdapterPowerManagement -Name $a.Name -AllowComputerToTurnOffDevice Disabled -ErrorAction Stop
        $adaptadoresAjustados++
      }
    } catch {}
  }
  Write-Output "on: economia de energia desligada em $adaptadoresAjustados adaptador(es) de rede"
} catch {
  Write-Output "AVISO: nao consegui ajustar economia de energia da rede ($_)"
}

# 2) Desliga o algoritmo de Nagle por interface (registro, por adaptador TCP/IP)
try {
  $tcpipInterfaces = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
  $n = 0
  Get-ChildItem $tcpipInterfaces -ErrorAction Stop | ForEach-Object {
    Set-ItemProperty -Path $_.PsPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $_.PsPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    $n++
  }
  Write-Output "on: algoritmo de Nagle desligado em $n interface(s) (menos delay em jogo online)"
} catch {
  Write-Output "AVISO: precisa ser Administrador pra essa parte -- pulando."
}

# 3) NetworkThrottlingIndex desativado
try {
  $mmPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
  Set-ItemProperty -Path $mmPath -Name "NetworkThrottlingIndex" -Value 0xffffffff -Type DWord -Force -ErrorAction Stop
  Write-Output "on: limite de processamento de rede durante tarefas multimidia (NetworkThrottlingIndex) desativado"
} catch {
  Write-Output "AVISO: precisa ser Administrador pra essa parte (NetworkThrottlingIndex) -- pulando."
}

# 4) Large Send Offload desligado nos adaptadores fisicos
try {
  $adapters2 = @(Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq "Up" })
  $nLso = 0
  $ultimoErro = $null
  foreach ($a in $adapters2) {
    try {
      Disable-NetAdapterLso -Name $a.Name -Confirm:$false -ErrorAction Stop
      $nLso++
    } catch {
      $ultimoErro = $_
    }
  }
  if ($nLso -gt 0) {
    Write-Output "on: Large Send Offload (LSO) desligado em $nLso adaptador(es)"
  } elseif ($adapters2.Count -gt 0) {
    Write-Output "AVISO: precisa ser Administrador pra essa parte (LSO) -- pulando ($ultimoErro)"
  } else {
    Write-Output "info: nenhum adaptador fisico ativo encontrado pra ajustar LSO"
  }
} catch {
  Write-Output "AVISO: nao consegui desligar o LSO ($_)"
}

Write-Output ""
Write-Output "Reinicie o PC (ou desative/ative a placa de rede) pra valer 100%."
