# Limpeza profunda de arquivos que so ocupam espaco e nao servem pra nada
# depois de usados uma vez -- o Windows (ou o driver da placa de video, ou
# o proprio jogo) recria tudo sozinho conforme precisa. Nada aqui apaga
# documento, foto, save de jogo ou configuracao. Cada categoria roda
# isolada -- se uma precisar de Administrador e voce nao tiver, ela avisa
# e as outras continuam normalmente.
$ErrorActionPreference = "Stop"
$totalGeral = 0

function Limpar-Pasta([string]$caminho, [string]$nome) {
  # Usa Write-Host (nao Write-Output) pras mensagens, porque a funcao
  # PRECISA retornar so o numero de bytes liberados pra quem chamou poder
  # somar (@() += Limpar-Pasta ...) -- se usasse Write-Output aqui, a
  # mensagem de texto entraria junto no valor de retorno da funcao e
  # quebraria a soma.
  if (-not (Test-Path $caminho)) {
    Write-Host "info: $nome nao encontrado nessa maquina, pulando."
    return 0
  }
  try {
    $itens = Get-ChildItem -LiteralPath $caminho -Recurse -Force -ErrorAction SilentlyContinue
    $antes = ($itens | Where-Object { -not $_.PSIsContainer } | Measure-Object -Property Length -Sum).Sum
    if (-not $antes) { $antes = 0 }
    $itens | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "on: $nome limpo ($([math]::Round($antes/1MB,0)) MB liberados)"
    return $antes
  } catch {
    Write-Host "AVISO: nao consegui limpar $nome ($_)"
    return 0
  }
}

# 1) Temporarios do usuario atual (%TEMP%) -- nao precisa de admin
$totalGeral += Limpar-Pasta $env:TEMP "temporarios do usuario (%TEMP%)"

# 2) Temporarios do sistema (C:\Windows\Temp) -- precisa de admin
$totalGeral += Limpar-Pasta "C:\Windows\Temp" "temporarios do sistema (C:\Windows\Temp)"

# 3) Prefetch (C:\Windows\Prefetch) -- precisa de admin. O Windows usa isso
# pra acelerar a abertura de programas que voce mais usa; limpar libera
# espaco e forca ele reaprender do zero (os primeiros lancamentos depois
# disso podem ficar um pouco mais lentos ate reaprender -- e normal).
$totalGeral += Limpar-Pasta "C:\Windows\Prefetch" "Prefetch"

# 4) Recentes (%APPDATA%\Microsoft\Windows\Recent) -- lista de atalhos pra
# arquivos abertos recentemente. Nao precisa de admin. So organizacao,
# nao apaga os arquivos de verdade, so o atalho/historico deles.
$totalGeral += Limpar-Pasta (Join-Path $env:APPDATA "Microsoft\Windows\Recent") "lista de Recentes"

# 5) Cache de download do Windows Update -- precisa de admin. Precisa
# pausar o servico de Windows Update por um instante pra conseguir apagar
# os arquivos (senao ficam travados em uso); o servico volta a funcionar
# normal logo em seguida, so os arquivos ja baixados sao apagados (o
# Windows Update baixa de novo se precisar, sem perder nenhuma
# atualizacao ja instalada).
try {
  $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  if (-not $isAdmin) {
    Write-Output "AVISO: precisa ser Administrador pra limpar o cache do Windows Update."
  } else {
    Stop-Service -Name wuauserv -Force -ErrorAction Stop
    $totalGeral += Limpar-Pasta "C:\Windows\SoftwareDistribution\Download" "cache de download do Windows Update"
    Start-Service -Name wuauserv -ErrorAction Stop
  }
} catch {
  Write-Output "AVISO: nao consegui limpar o cache do Windows Update ($_)"
  try { Start-Service -Name wuauserv -ErrorAction SilentlyContinue } catch {}
}

# 6) Cache de shader (DirectX/NVIDIA/AMD) -- nao precisa de admin. Os
# jogos recompilam o shader na primeira vez que precisarem de novo (pode
# deixar o primeiro carregamento de uma cena um pouco mais lento so na
# proxima sessao, depois volta ao normal).
$totalGeral += Limpar-Pasta (Join-Path $env:LOCALAPPDATA "D3DSCache") "cache de shader DirectX"
$totalGeral += Limpar-Pasta (Join-Path $env:LOCALAPPDATA "NVIDIA\DXCache") "cache de shader NVIDIA"
$totalGeral += Limpar-Pasta (Join-Path $env:LOCALAPPDATA "NVIDIA\GLCache") "cache de shader OpenGL NVIDIA"
$totalGeral += Limpar-Pasta (Join-Path $env:LOCALAPPDATA "AMD\DxCache") "cache de shader AMD"
$totalGeral += Limpar-Pasta (Join-Path $env:LOCALAPPDATA "AMD\DxcCache") "cache de shader AMD (DXC)"

# 7) Lixeira -- nao precisa de admin.
try {
  Clear-RecycleBin -Force -ErrorAction Stop
  Write-Output "on: Lixeira esvaziada"
} catch {
  Write-Output "info: Lixeira ja estava vazia ou nao consegui acessar."
}

Write-Output ""
Write-Output "Total liberado: $([math]::Round($totalGeral/1MB,0)) MB"
