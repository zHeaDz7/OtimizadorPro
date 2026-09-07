# Verifica onde esta o arquivo de paginacao (memoria virtual) do Windows.
# Se ele estiver num HD mecanico enquanto existe um SSD livre na maquina,
# isso pode causar lentidao forte quando a RAM se esgota (jogo grande +
# muito programa aberto). So AVISA e pergunta -- mover o pagefile e
# reversivel, mas mexe em configuracao de sistema, entao confirma antes.
$ErrorActionPreference = "Stop"

$ramGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)

$pf = Get-CimInstance Win32_PageFileUsage -ErrorAction SilentlyContinue
if (-not $pf) {
  Write-Output "Nao encontrei informacao do arquivo de paginacao (pode estar com tamanho gerenciado pelo sistema, o que geralmente ja e adequado)."
  return
}

foreach ($p in $pf) {
  $letra = $p.Name.Substring(0,1)
  try {
    $disco = Get-Partition -DriveLetter $letra -ErrorAction Stop | Get-Disk -ErrorAction Stop
    $fisico = Get-PhysicalDisk -ErrorAction Stop | Where-Object { $_.DeviceId -eq $disco.Number } | Select-Object -First 1
    Write-Output "Arquivo de paginacao em ${letra}: ($($fisico.MediaType)), $([math]::Round($p.AllocatedBaseSize/1024,1)) GB"
    if ($fisico.MediaType -eq "HDD") {
      $temSSD = @(Get-PhysicalDisk | Where-Object { $_.MediaType -eq "SSD" }).Count -gt 0
      if ($temSSD) {
        Write-Output "AVISO: seu arquivo de paginacao esta num HD mecanico, e voce tem SSD disponivel."
        Write-Output "Recomendado mover manualmente: Configuracoes > Sistema > Sobre > Configuracoes"
        Write-Output "avancadas do sistema > Desempenho > Configuracoes > aba Avancado >"
        Write-Output "Memoria virtual > Alterar -- desmarque 'Gerenciar automaticamente' e"
        Write-Output "defina o pagefile no disco SSD, tamanho gerenciado pelo sistema."
      }
    }
  } catch {
    Write-Output "Arquivo de paginacao em ${letra}: $([math]::Round($p.AllocatedBaseSize/1024,1)) GB"
  }
}

$totalAlocadoGB = [math]::Round((($pf | Measure-Object -Property AllocatedBaseSize -Sum).Sum) / 1024, 1)
Write-Output ""
Write-Output "RAM instalada: $ramGB GB. Arquivo de paginacao total: $totalAlocadoGB GB."
if ($ramGB -lt 16 -and $totalAlocadoGB -lt ($ramGB * 0.5)) {
  Write-Output "AVISO: seu arquivo de paginacao parece pequeno pra quantidade de RAM que"
  Write-Output "voce tem. Se o 'Gerenciar automaticamente' estiver desmarcado com um"
  Write-Output "valor manual baixo, considere marcar de volta o gerenciamento automatico"
  Write-Output "(o Windows geralmente acerta o tamanho sozinho) em Configuracoes >"
  Write-Output "Sistema > Sobre > Configuracoes avancadas do sistema > Desempenho >"
  Write-Output "Configuracoes > aba Avancado > Memoria virtual."
} else {
  Write-Output "Tamanho parece adequado -- geralmente e melhor deixar no automatico"
  Write-Output "('Gerenciar automaticamente o tamanho do arquivo de paginacao') do que"
  Write-Output "definir um valor manual, a nao ser que voce tenha um motivo especifico."
}
