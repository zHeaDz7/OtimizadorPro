# So DIAGNOSTICA -- verifica a taxa de atualizacao de CADA monitor
# conectado (nao so o principal). Usa a API do Windows diretamente
# (EnumDisplayDevices/EnumDisplaySettings) porque o WMI so relata a
# GPU, nao cada tela conectada nela -- em setup com mais de um monitor,
# o item P deste OtimizadorPro pode nao pegar os outros.
$ErrorActionPreference = "SilentlyContinue"

$tipoDefinido = @"
using System;
using System.Runtime.InteropServices;
public class MonitorApi {
  [StructLayout(LayoutKind.Sequential)]
  public struct DISPLAY_DEVICE {
    [MarshalAs(UnmanagedType.U4)] public int cb;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string DeviceName;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)] public string DeviceString;
    [MarshalAs(UnmanagedType.U4)] public int StateFlags;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)] public string DeviceID;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)] public string DeviceKey;
  }
  [StructLayout(LayoutKind.Sequential)]
  public struct DEVMODE {
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dmDeviceName;
    public short dmSpecVersion, dmDriverVersion, dmSize, dmDriverExtra;
    public int dmFields;
    public int dmPositionX, dmPositionY;
    public int dmDisplayOrientation, dmDisplayFixedOutput;
    public short dmColor, dmDuplex, dmYResolution, dmTTOption, dmCollate;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dmFormName;
    public short dmLogPixels;
    public int dmBitsPerPel, dmPelsWidth, dmPelsHeight, dmDisplayFlags, dmDisplayFrequency;
    public int dmICMMethod, dmICMIntent, dmMediaType, dmDitherType, dmReserved1, dmReserved2, dmPanningWidth, dmPanningHeight;
  }
  [DllImport("user32.dll", CharSet = CharSet.Auto)]
  public static extern bool EnumDisplayDevices(string lpDevice, uint iDevNum, ref DISPLAY_DEVICE lpDisplayDevice, uint dwFlags);
  [DllImport("user32.dll", CharSet = CharSet.Auto)]
  public static extern bool EnumDisplaySettings(string lpszDeviceName, int iModeNum, ref DEVMODE lpDevMode);
}
"@

try {
  Add-Type -TypeDefinition $tipoDefinido -ErrorAction Stop
} catch {
  Write-Output "Nao consegui carregar a API de monitores nessa maquina. Use o item P (basico) em vez disso."
  return
}

Write-Output "=== TAXA DE ATUALIZACAO DE CADA MONITOR ==="
Write-Output ""

$i = 0
$encontrouAlgum = $false
while ($true) {
  $dd = New-Object MonitorApi+DISPLAY_DEVICE
  $dd.cb = [System.Runtime.InteropServices.Marshal]::SizeOf($dd)
  $ok = [MonitorApi]::EnumDisplayDevices($null, $i, [ref]$dd, 0)
  if (-not $ok) { break }
  $i++

  if (($dd.StateFlags -band 1) -eq 0) { continue }  # so telas ativas (DISPLAY_DEVICE_ATTACHED_TO_DESKTOP)
  $encontrouAlgum = $true

  $dm = New-Object MonitorApi+DEVMODE
  $dm.dmSize = [System.Runtime.InteropServices.Marshal]::SizeOf($dm)
  $okModo = [MonitorApi]::EnumDisplaySettings($dd.DeviceName, -1, [ref]$dm)

  $ehPrincipal = ($dd.StateFlags -band 4) -ne 0  # DISPLAY_DEVICE_PRIMARY_DEVICE
  $marcador = if ($ehPrincipal) { " (principal)" } else { "" }

  if ($okModo) {
    Write-Output "  $($dd.DeviceString)$marcador -- $($dm.dmPelsWidth)x$($dm.dmPelsHeight) @ $($dm.dmDisplayFrequency)Hz"
  } else {
    Write-Output "  $($dd.DeviceString)$marcador -- nao consegui ler a taxa de atualizacao"
  }
}

if (-not $encontrouAlgum) {
  Write-Output "Nao encontrei nenhum monitor ativo (raro -- pode ser limitacao de ambiente remoto/virtual)."
}
Write-Output ""
Write-Output "Se algum monitor estiver abaixo do que ele suporta de verdade, ajuste em"
Write-Output "Configuracoes > Sistema > Tela > escolha o monitor > Taxa de atualizacao."
