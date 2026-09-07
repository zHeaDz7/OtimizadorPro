# Mostra quais programas estao consumindo mais CPU/RAM agora, e deixa a
# pessoa escolher (um por um, nunca automatico) se quer fechar algum antes
# de jogar. Nunca fecha nada sem voce escolher explicitamente -- programa
# errado fechado sem querer pode atrapalhar (ex: software de audio, VPN).
$ErrorActionPreference = "SilentlyContinue"

$conhecidosPesados = @(
  "wallpaper64", "wallpaper32", "webwallpaper64", "webwallpaper32",
  "NVIDIA Broadcast", "Discord", "chrome", "msedge", "firefox",
  "EpicGamesLauncher", "Spotify", "OneDrive", "Teams"
)

$procs = Get-Process | Where-Object { $_.WorkingSet64 -gt 150MB -or $_.CPU -gt 30 } |
  Sort-Object WorkingSet64 -Descending | Select-Object -First 15

if (-not $procs) {
  Write-Output "Nenhum programa pesado rodando agora. Tudo limpo."
  return
}

Write-Output "Programas usando mais recursos agora:"
Write-Output ""
$i = 1
$indice = @{}
foreach ($p in $procs) {
  $marca = if ($conhecidosPesados -contains $p.Name) { " <- comum atrapalhar em jogo" } else { "" }
  Write-Output ("  {0,2}. {1,-25} RAM: {2,6:N0} MB{3}" -f $i, $p.Name, ($p.WorkingSet64/1MB), $marca)
  $indice[$i] = $p
  $i++
}
Write-Output ""
Write-Output "  0. Nao fechar nada, so queria ver"
Write-Output ""
$escolha = Read-Host "Digite os numeros pra fechar (separados por virgula), ou 0"
if ($escolha -eq "0" -or [string]::IsNullOrWhiteSpace($escolha)) {
  Write-Output "Nada fechado."
  return
}

foreach ($num in ($escolha -split ",")) {
  $num = $num.Trim()
  if ($indice.ContainsKey([int]$num)) {
    $alvo = $indice[[int]$num]
    try {
      Stop-Process -Id $alvo.Id -Force -ErrorAction Stop
      Write-Output "fechado: $($alvo.Name)"
    } catch {
      Write-Output "nao consegui fechar $($alvo.Name): $_"
    }
  }
}
