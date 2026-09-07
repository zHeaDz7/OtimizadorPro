# Ajusta o timer do kernel do Windows pra maior precisao (menos "passos"
# entre uma atualizacao e outra do relogio interno do sistema) usando
# opcoes OFICIAIS e documentadas do bcdedit (a ferramenta de configuracao
# de boot do proprio Windows). Isso pode reduzir microstutter e atraso
# de input em jogos sensiveis a timing. E uma configuracao de BOOT -- so
# faz efeito depois de REINICIAR o PC (aplicar ou reverter). bcdedit exige
# Administrador ate pra LER a configuracao atual, entao sem admin nem o
# Status funciona -- isso e normal, nao e falha do script.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"

function Get-BcdCurrent {
  $saida = bcdedit /enum "{current}" 2>&1
  if ($LASTEXITCODE -ne 0) { throw ($saida -join " ") }
  return $saida
}

try {
  if ($Action -eq "Status") {
    $saida = Get-BcdCurrent
    $linha = $saida | Select-String -Pattern "disabledynamictick\s+(\S+)"
    if ($linha -and $linha.Matches[0].Groups[1].Value -match "Yes|Sim") { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if ($Action -eq "Reverter") {
    bcdedit /deletevalue useplatformclock 2>&1 | Out-Null
    bcdedit /deletevalue disabledynamictick 2>&1 | Out-Null
    bcdedit /deletevalue tscsyncpolicy 2>&1 | Out-Null
    Write-Output "on: timer do kernel revertido pro padrao do Windows."
    Write-Output "AVISO: precisa REINICIAR o PC pra valer."
    return
  }

  bcdedit /set disabledynamictick yes 2>&1 | Out-Null
  if ($LASTEXITCODE -ne 0) { throw "bcdedit /set disabledynamictick falhou" }
  bcdedit /set tscsyncpolicy Enhanced 2>&1 | Out-Null
  if ($LASTEXITCODE -ne 0) { throw "bcdedit /set tscsyncpolicy falhou" }

  Write-Output "on: timer do kernel ajustado pra maior precisao (tick dinamico desligado, TSC sincronizado)."
  Write-Output "AVISO: precisa REINICIAR o PC pra valer. Reverter tambem precisa reiniciar."
} catch {
  Write-Output "AVISO: precisa ser Administrador pra essa parte (bcdedit exige elevacao ate pra ler) ($_)"
}
