# Desliga a Hibernacao do Windows. O arquivo de hibernacao (hiberfil.sys)
# ocupa espaco em disco do MESMO TAMANHO da sua RAM (ex: 16GB de RAM =
# 16GB gastos no disco, so parado la) pra guardar o estado do PC quando
# hiberna. Se voce nunca usa hibernacao (so usa Suspender ou Desligar),
# desligar libera esse espaco todo -- especialmente relevante se o
# Windows estiver instalado num SSD pequeno. Tambem desliga o "Fast
# Startup" (que depende de hibernacao parcial) -- reative os dois juntos
# se quiser o boot mais rapido de volta.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"

try {
  if ($Action -eq "Status") {
    # Le direto do registro (o que powercfg /hibernate on/off realmente
    # muda) em vez de tentar interpretar o texto do "powercfg /a", que
    # muda de idioma conforme o Windows configurado.
    $v = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power" -Name "HibernateEnabled" -ErrorAction SilentlyContinue).HibernateEnabled
    if ($v -eq 0) { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if ($Action -eq "Reverter") {
    powercfg /hibernate on 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "powercfg /hibernate on falhou" }
    Write-Output "on: Hibernacao ligada de novo (volta a ocupar espaco em disco igual a sua RAM)."
    return
  }

  $tamanhoGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
  powercfg /hibernate off 2>&1 | Out-Null
  if ($LASTEXITCODE -ne 0) { throw "powercfg /hibernate off falhou" }
  Write-Output "on: Hibernacao desligada -- libera ate ${tamanhoGB}GB de espaco em disco (o tamanho do hiberfil.sys era do tamanho da sua RAM)."
  Write-Output "AVISO: se voce usava 'Hibernar' no menu Iniciar, essa opcao some (Suspender continua funcionando normal)."
} catch {
  Write-Output "AVISO: precisa ser Administrador pra essa parte ($_)"
}
