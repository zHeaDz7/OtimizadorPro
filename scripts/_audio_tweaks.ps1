# Desliga "Melhorias de Audio" do Windows nos dispositivos de som -- esses
# efeitos (equalizador virtual, "surround" simulado, etc.) processam o
# audio em tempo real e podem causar delay/estalo perceptivel, sem
# beneficio real em jogo competitivo. Configuracao 100% nativa do Windows,
# reversivel em Configuracoes > Som > Propriedades do dispositivo.
$ErrorActionPreference = "Stop"

try {
  $devices = Get-CimInstance -Namespace "root\cimv2" -ClassName "Win32_SoundDevice" -ErrorAction SilentlyContinue
  $chavesRegistro = Get-ChildItem "HKCU:\Software\Microsoft\Multimedia\Audio\{*}" -ErrorAction SilentlyContinue
  # O caminho oficial pra isso e por dispositivo em FxProperties -- como a
  # chave exata varia de driver pra driver, ajustamos a chave global que a
  # maioria dos drivers de audio (Realtek, etc.) respeita.
  $n = 0
  $endpoints = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render" -ErrorAction SilentlyContinue
  foreach ($ep in $endpoints) {
    $fxPath = Join-Path $ep.PSPath "FxProperties"
    if (Test-Path $fxPath) {
      try {
        Set-ItemProperty -Path $fxPath -Name "{1da5d803-d492-4edd-8c23-e0c0ffee7f0e},5" -Value 1 -Type DWord -Force -ErrorAction Stop
        $n++
      } catch {}
    }
  }
  Write-Output "on: melhorias de audio desligadas em $n dispositivo(s) de som"
} catch {
  Write-Output "AVISO: nao consegui ajustar melhorias de audio ($_)"
}

Write-Output ""
Write-Output "Dica manual complementar: Configuracoes > Som > seu dispositivo > Propriedades"
Write-Output "> aba Avancado -- desmarque 'Permitir que os aplicativos assumam o controle"
Write-Output "exclusivo' se notar corte/delay de audio em jogo."
