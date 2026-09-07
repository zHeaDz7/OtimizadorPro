# So DIAGNOSTICA -- verifica se Core Isolation / Memory Integrity (VBS,
# Virtualization Based Security) esta ligado. E um recurso de SEGURANCA
# real do Windows (isola processos criticos numa camada virtualizada,
# dificulta certos tipos de malware) -- mas tem um custo de desempenho
# real em CPU mais antiga (a Microsoft documenta perda de ate ~5-10% em
# alguns jogos/CPUs). Nao desligamos automaticamente porque e uma troca
# de seguranca por desempenho que so voce deve decidir.
$ErrorActionPreference = "SilentlyContinue"

$vbs = (Get-CimInstance -Namespace root\Microsoft\Windows\DeviceGuard -ClassName Win32_DeviceGuard -ErrorAction SilentlyContinue)

Write-Output "=== CORE ISOLATION / MEMORY INTEGRITY (VBS) ==="
Write-Output ""
if (-not $vbs) {
  Write-Output "Nao consegui ler o status (comum em versoes mais antigas do Windows, que nem tem esse recurso)."
  return
}

$ligado = $vbs.VirtualizationBasedSecurityStatus -eq 2
if ($ligado) {
  Write-Output "LIGADO -- Core Isolation/Memory Integrity esta ativo."
  Write-Output ""
  Write-Output "Isso e uma protecao de seguranca real (nao e so cosmetico). Em CPUs mais"
  Write-Output "antigas ou sem suporte otimizado a virtualizacao, pode custar alguns FPS"
  Write-Output "em jogos sensiveis. A decisao de desligar e SUA -- e uma troca de"
  Write-Output "seguranca por desempenho, nao vamos mudar isso automaticamente."
  Write-Output ""
  Write-Output "Se quiser testar o impacto: Configuracoes > Privacidade e seguranca >"
  Write-Output "Seguranca do Windows > Seguranca do dispositivo > Detalhes de isolamento"
  Write-Output "do nucleo > desligar 'Integridade de memoria' (pede reiniciar)."
} else {
  Write-Output "DESLIGADO -- Core Isolation/Memory Integrity nao esta ativo."
  Write-Output "Isso já favorece desempenho um pouco. Se quiser mais seguranca (ao custo"
  Write-Output "de possivel perda de FPS), pode ligar em Seguranca do Windows > Seguranca"
  Write-Output "do dispositivo."
}
