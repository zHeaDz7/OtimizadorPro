# Desfragmenta HDs mecanicos (reorganiza os arquivos fragmentados pra ficar
# mais rapido de ler, reduz o tempo de busca da cabeca de leitura). NUNCA
# desfragmenta SSD -- SSD nao tem cabeca de leitura, desfragmentar nao
# ajuda em nada e so gasta ciclos de escrita do disco a toa (por isso esse
# item fica de fora do "Rodar TUDO": pode demorar bastante dependendo do
# tamanho/fragmentacao do disco, entao so roda quando voce escolher).
$ErrorActionPreference = "Stop"

try {
  $volumes = Get-Volume | Where-Object { $_.DriveLetter -and $_.DriveType -eq "Fixed" }
  $hds = @()
  foreach ($v in $volumes) {
    $letra = $v.DriveLetter
    try {
      $disco = Get-Partition -DriveLetter $letra -ErrorAction Stop | Get-Disk -ErrorAction Stop
      $fisico = Get-PhysicalDisk -ErrorAction Stop | Where-Object { $_.DeviceId -eq $disco.Number } | Select-Object -First 1
      if ($fisico.MediaType -eq "HDD") { $hds += $letra }
    } catch {}
  }

  if ($hds.Count -eq 0) {
    Write-Output "Nenhum HD mecanico detectado nessa maquina -- so SSD, que nao precisa (e nao deve) ser desfragmentado."
    return
  }

  foreach ($letra in $hds) {
    Write-Output "Desfragmentando ${letra}: -- isso pode demorar de alguns minutos a algumas horas dependendo do tamanho e fragmentacao do disco. Nao desligue o PC."
    try {
      Optimize-Volume -DriveLetter $letra -Defrag -Verbose -ErrorAction Stop
      Write-Output "on: ${letra}: desfragmentado"
    } catch {
      Write-Output "AVISO: nao consegui desfragmentar ${letra}: ($_)"
    }
  }
} catch {
  Write-Output "AVISO: precisa ser Administrador pra essa parte ($_)"
}
