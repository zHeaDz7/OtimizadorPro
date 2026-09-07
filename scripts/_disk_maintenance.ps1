# Garante que cada disco recebe a manutencao certa pro seu tipo:
# - SSD: roda TRIM (fala pra placa quais blocos estao livres, mantem a
#   velocidade de escrita) -- NUNCA desfragmenta (desfragmentar SSD nao
#   ajuda em nada e so gasta ciclos de escrita a toa).
# - HD mecanico: desfragmenta (isso sim ajuda HD, reduz tempo de busca).
# Windows moderno (10/11) ja faz isso sozinho via "Otimizar Unidades" --
# aqui so garantimos que esta configurado certo e rodamos uma vez agora.
$ErrorActionPreference = "Stop"

try {
  $volumes = Get-Volume | Where-Object { $_.DriveLetter -and $_.DriveType -eq "Fixed" }
  foreach ($v in $volumes) {
    $letra = $v.DriveLetter
    try {
      $disco = Get-Partition -DriveLetter $letra -ErrorAction Stop | Get-Disk -ErrorAction Stop
      $fisico = Get-PhysicalDisk -ErrorAction Stop | Where-Object { $_.DeviceId -eq $disco.Number } | Select-Object -First 1
      if ($fisico.MediaType -eq "SSD") {
        Optimize-Volume -DriveLetter $letra -ReTrim -ErrorAction Stop
        Write-Output "on: TRIM executado em ${letra}: (SSD)"
      } elseif ($fisico.MediaType -eq "HDD") {
        Write-Output "info: ${letra}: e HD mecanico -- use a opcao de Desfragmentar Disco no menu pra otimizar (pode demorar, por isso e separada)"
      }
    } catch {
      Write-Output "AVISO: nao consegui otimizar ${letra}: ($_)"
    }
  }
} catch {
  Write-Output "AVISO: precisa ser Administrador pra essa parte ($_)"
}
