# Otimizador Pro -- instalador rapido
# Uso:  irm https://raw.githubusercontent.com/zHeaDz7/OtimizadorPro/main/instalar.ps1 | iex
#
# Baixa o projeto do GitHub pra uma pasta local e abre a interface grafica.
# Nao instala nada escondido, nao roda nada compilado -- so copia os
# arquivos .ps1/.bat (que voce pode ler e conferir) e executa a GUI.

$ErrorActionPreference = "Stop"

$usuarioGitHub = "zHeaDz7"
$nomeRepo = "OtimizadorPro"
$branch = "main"

Write-Host "Otimizador Pro -- baixando a versao mais recente..." -ForegroundColor Yellow

$zipUrl = "https://github.com/$usuarioGitHub/$nomeRepo/archive/refs/heads/$branch.zip"
$destino = "$env:LOCALAPPDATA\OtimizadorPro"
$zipTmp = "$env:TEMP\OtimizadorPro_$(Get-Random).zip"
$extractTmp = "$env:TEMP\OtimizadorPro_extract_$(Get-Random)"

try {
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipTmp -UseBasicParsing
    Expand-Archive -Path $zipTmp -DestinationPath $extractTmp -Force

    if (Test-Path $destino) { Remove-Item $destino -Recurse -Force }
    $pastaExtraida = Get-ChildItem $extractTmp | Select-Object -First 1
    Move-Item $pastaExtraida.FullName $destino
} finally {
    Remove-Item $zipTmp -Force -ErrorAction SilentlyContinue
    Remove-Item $extractTmp -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "Pronto -- abrindo o Otimizador Pro (vai pedir permissao de Administrador)..." -ForegroundColor Green

Start-Process powershell -ArgumentList @(
    "-NoProfile", "-ExecutionPolicy", "Bypass", "-STA", "-File", "`"$destino\gui\main.ps1`""
) -Verb RunAs
