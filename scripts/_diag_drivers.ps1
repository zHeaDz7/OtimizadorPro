# Verifica a idade dos drivers dos componentes principais (placa de
# video, rede, audio, armazenamento) e avisa quais parecem desatualizados.
# NAO baixa nem instala nenhum driver por conta propria -- isso e
# arriscado de automatizar (driver errado pode ate impedir o PC de
# iniciar direito). Em vez disso, oferece abrir a pagina OFICIAL do
# Windows Update que verifica atualizacoes de driver (canal seguro,
# testado pela Microsoft/fabricante antes de chegar ate voce), e mostra
# o link oficial do fabricante da GPU/rede como alternativa manual.
param(
  [switch]$AbrirWindowsUpdate
)
$ErrorActionPreference = "SilentlyContinue"

if ($AbrirWindowsUpdate) {
  Start-Process "ms-settings:windowsupdate-optionalupdates"
  Write-Output "on: abrindo Configuracoes > Windows Update > Atualizacoes opcionais (drivers)."
  return
}

$categorias = @{
  "Display"      = "Placa de video"
  "Net"          = "Rede"
  "Media"        = "Audio"
  "SCSIAdapter"  = "Armazenamento"
  "HDC"          = "Armazenamento (controlador)"
}

Write-Output "=== IDADE DOS DRIVERS PRINCIPAIS ==="
Write-Output ""

$algumAntigo = $false
foreach ($classe in $categorias.Keys) {
  # So considera hardware de verdade -- drivers virtuais/stub da propria
  # Microsoft (ex: "Microsoft Kernel Debug Network Adapter", datados de
  # 2006) nao tem "atualizacao de fabricante" nenhuma pra fazer, avisar
  # sobre eles so seria ruido/alarme falso.
  $drivers = @(Get-CimInstance Win32_PnPSignedDriver -ErrorAction SilentlyContinue | Where-Object {
    $_.DeviceClass -eq $classe -and $_.DriverDate -and $_.DeviceName -and $_.Manufacturer -notmatch "^Microsoft$"
  } | Select-Object -Unique DeviceName, DriverVersion, DriverDate, Manufacturer)

  foreach ($d in $drivers) {
    try {
      $data = [datetime]$d.DriverDate
      $dias = (New-TimeSpan -Start $data -End (Get-Date)).Days
      $rotulo = $categorias[$classe]
      $status = if ($dias -gt 365) { "ANTIGO ($([math]::Round($dias/365,1)) anos)"; $algumAntigo = $true } elseif ($dias -gt 180) { "ok, mas com alguns meses" } else { "recente" }
      Write-Output ("  [{0}] {1} -- driver de {2} ({3})" -f $rotulo, $d.DeviceName, $data.ToString("dd/MM/yyyy"), $status)
    } catch {}
  }
}

Write-Output ""
if ($algumAntigo) {
  Write-Output "AVISO: pelo menos um driver com mais de 1 ano. Duas formas seguras de atualizar:"
  Write-Output ""
  Write-Output "1) Canal oficial do Windows (recomendado, mais seguro): rode este mesmo"
  Write-Output "   item de novo com a opcao de abrir o Windows Update, ou va em"
  Write-Output "   Configuracoes > Windows Update > Opcoes avancadas > Atualizacoes"
  Write-Output "   opcionais > Atualizacoes de driver."
  Write-Output ""
  Write-Output "2) Direto do fabricante (mais atualizado, mas exige mais cuidado -- baixe"
  Write-Output "   SEMPRE do site oficial):"
  $gpu = Get-CimInstance Win32_VideoController | Where-Object { $_.Name -notmatch "Basic|Meta|Virtual" } | Select-Object -First 1
  if ($gpu) {
    if ($gpu.Name -match "NVIDIA") { Write-Output "   Placa de video: nvidia.com/drivers" }
    elseif ($gpu.Name -match "AMD|Radeon") { Write-Output "   Placa de video: amd.com/support" }
    elseif ($gpu.Name -match "Intel") { Write-Output "   Placa de video: intel.com/content/www/us/en/support" }
  }
  Write-Output "   Placa-mae/chipset e audio: site do fabricante da placa-mae (ou do"
  Write-Output "   notebook), procure pelo modelo exato + 'drivers'."
} else {
  Write-Output "Todos os drivers verificados estao razoavelmente atualizados."
}
