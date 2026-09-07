# Traz de volta o menu de contexto (botao direito) classico do Windows 10,
# com todas as opcoes na hora, em vez do menu reduzido do Windows 11 que
# exige clicar em "Mostrar mais opcoes". So aparencia -- reinicia o
# Explorer pra fazer efeito na hora (a tela pode piscar um instante).
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"
$path = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"

try {
  if ($Action -eq "Status") {
    if (Test-Path $path) { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if ($Action -eq "Reverter") {
    Remove-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Recurse -Force -ErrorAction SilentlyContinue
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 500
    Start-Process explorer.exe
    Write-Output "on: menu de contexto voltou ao estilo Windows 11 (padrao)."
  } else {
    if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    Set-ItemProperty -Path $path -Name "(Default)" -Value "" -Type String -Force
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 500
    Start-Process explorer.exe
    Write-Output "on: menu de contexto classico do Windows 10 ativado."
  }
} catch {
  Write-Output "AVISO: nao consegui mudar essa configuracao ($_)"
}
