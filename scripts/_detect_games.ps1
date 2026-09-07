# Detecta pastas de jogos instaladas (Steam, Epic Games) na maquina atual.
# Nao depende de usuario/letra de disco fixos -- le a config de cada
# launcher pra achar onde estao de verdade. Generico de proposito: nao
# assume nenhum jogo/launcher especifico, funciona igual em qualquer PC.
#
# NAO defina $ErrorActionPreference aqui: este arquivo e carregado via dot-
# source (". _detect_games.ps1") por varios outros scripts, o que roda no
# MESMO escopo de quem chama -- uma preferencia global aqui vazaria pra fora
# e sobrescreveria o "Stop" que o script chamador definiu, fazendo erros
# reais (tipo falta de permissao) serem engolidos em silencio depois deste
# ponto. Cada cmdlet abaixo ja usa -ErrorAction SilentlyContinue ou try/catch
# individualmente onde precisa, entao isso nao muda o comportamento aqui.
function Get-SteamLibraries {
  $paths = @()
  $steamPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -ErrorAction SilentlyContinue).InstallPath
  if (-not $steamPath) { $steamPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Valve\Steam" -ErrorAction SilentlyContinue).InstallPath }
  if (-not $steamPath) { return $paths }
  $vdf = Join-Path $steamPath "steamapps\libraryfolders.vdf"
  if (-not (Test-Path $vdf)) { return $paths }
  $lines = Get-Content -LiteralPath $vdf
  foreach ($line in $lines) {
    if ($line -match '"path"\s*"([^"]+)"') {
      $p = $matches[1] -replace '\\\\', '\'
      if (Test-Path $p) { $paths += $p }
    }
  }
  return $paths | Select-Object -Unique
}

function Get-SteamGameFolders {
  $games = @()
  foreach ($lib in (Get-SteamLibraries)) {
    $common = Join-Path $lib "steamapps\common"
    if (Test-Path $common) {
      Get-ChildItem -LiteralPath $common -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $games += [PSCustomObject]@{ Nome = $_.Name; Caminho = $_.FullName; Origem = "Steam" }
      }
    }
  }
  return $games
}

function Get-EpicGameFolders {
  $games = @()
  $manifestDir = "C:\ProgramData\Epic\EpicGamesLauncher\Data\Manifests"
  if (-not (Test-Path $manifestDir)) { return $games }
  Get-ChildItem -LiteralPath $manifestDir -Filter "*.item" -ErrorAction SilentlyContinue | ForEach-Object {
    try {
      $data = Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json
      if ($data.InstallLocation -and (Test-Path $data.InstallLocation)) {
        $games += [PSCustomObject]@{ Nome = $data.DisplayName; Caminho = $data.InstallLocation; Origem = "Epic Games" }
      }
    } catch {}
  }
  return $games
}

function Get-AllDetectedGames {
  $all = @()
  $all += Get-SteamGameFolders
  $all += Get-EpicGameFolders
  return $all
}
