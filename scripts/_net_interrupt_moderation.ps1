# "Interrupt Moderation" e um recurso da placa de rede que agrupa varios
# avisos (interrupcoes) pro processador antes de entregar, em vez de
# avisar a cada pacote -- economiza CPU, mas atrasa a entrega de cada
# pacote individual. Desligar faz a placa avisar o processador na hora
# de cada pacote (menos latencia, um pouco mais de uso de CPU). Nem toda
# placa/driver expoe essa opcao -- se a sua nao tiver, o script avisa em
# vez de fingir que mudou algo.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"

function Get-PropriedadeModeracao($adapterName) {
  return Get-NetAdapterAdvancedProperty -Name $adapterName -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -match "Interrupt Moderation" } | Select-Object -First 1
}

try {
  $adapters = @(Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq "Up" })
  if ($adapters.Count -eq 0) {
    Write-Output "AVISO: nenhum adaptador de rede fisico ativo encontrado."
    return
  }

  $comSuporte = @()
  foreach ($a in $adapters) {
    $prop = Get-PropriedadeModeracao $a.Name
    if ($prop) { $comSuporte += [PSCustomObject]@{ Adapter = $a.Name; Prop = $prop } }
  }

  if ($comSuporte.Count -eq 0) {
    if ($Action -eq "Status") { Write-Output "NAO SUPORTADO"; return }
    Write-Output "AVISO: nenhum dos seus adaptadores de rede expoe essa opcao no driver -- comum em placas Wi-Fi e alguns drivers genericos. Nao ha nada pra ajustar aqui nessa maquina."
    return
  }

  if ($Action -eq "Status") {
    $desligado = ($comSuporte | Where-Object { $_.Prop.DisplayValue -match "Disabled|Off|Desativado" }).Count -eq $comSuporte.Count
    if ($desligado) { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if ($Action -eq "Reverter") {
    $n = 0
    foreach ($item in $comSuporte) {
      try {
        $valoresPossiveis = (Get-NetAdapterAdvancedProperty -Name $item.Adapter -RegistryKeyword $item.Prop.RegistryKeyword -AllProperties -ErrorAction SilentlyContinue).ValidDisplayValues
        $padrao = $valoresPossiveis | Where-Object { $_ -match "Enabled|On|Adaptive|Ativado" } | Select-Object -First 1
        if (-not $padrao) { $padrao = $valoresPossiveis | Select-Object -Last 1 }
        if ($padrao) {
          Set-NetAdapterAdvancedProperty -Name $item.Adapter -RegistryKeyword $item.Prop.RegistryKeyword -DisplayValue $padrao -ErrorAction Stop
          $n++
        }
      } catch {}
    }
    Write-Output "on: Interrupt Moderation revertido pro padrao em $n adaptador(es)."
    return
  }

  $n = 0
  foreach ($item in $comSuporte) {
    try {
      $valoresPossiveis = (Get-NetAdapterAdvancedProperty -Name $item.Adapter -RegistryKeyword $item.Prop.RegistryKeyword -AllProperties -ErrorAction SilentlyContinue).ValidDisplayValues
      $desligar = $valoresPossiveis | Where-Object { $_ -match "Disabled|Off|Desativado" } | Select-Object -First 1
      if ($desligar) {
        Set-NetAdapterAdvancedProperty -Name $item.Adapter -RegistryKeyword $item.Prop.RegistryKeyword -DisplayValue $desligar -ErrorAction Stop
        $n++
      }
    } catch {}
  }
  if ($n -gt 0) {
    Write-Output "on: Interrupt Moderation desligado em $n adaptador(es) (menos latencia, um pouco mais de uso de CPU)."
  } else {
    Write-Output "AVISO: seu(s) adaptador(es) tem a opcao mas nao consegui mudar (precisa ser Administrador)."
  }
} catch {
  Write-Output "AVISO: nao consegui mudar essa configuracao ($_)"
}
