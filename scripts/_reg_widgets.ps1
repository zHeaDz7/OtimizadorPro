# Remove o botao de Widgets da barra de tarefas do Windows 11 (aquele
# painel de noticias/tempo que abre do lado esquerdo). So interface --
# nao desliga nenhum servico nem processo em segundo plano por conta
# propria, so tira o botao de acesso.
param(
  [ValidateSet("Aplicar", "Reverter", "Status")]
  [string]$Action = "Aplicar"
)
$ErrorActionPreference = "Stop"
$path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

try {
  if ($Action -eq "Status") {
    $v = (Get-ItemProperty -Path $path -Name "TaskbarDa" -ErrorAction SilentlyContinue).TaskbarDa
    if ($v -eq 0) { Write-Output "LIGADO" } else { Write-Output "DESLIGADO" }
    return
  }

  if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
  if ($Action -eq "Reverter") {
    Set-ItemProperty -Path $path -Name "TaskbarDa" -Value 1 -Type DWord -Force
    Write-Output "on: botao de Widgets voltou pra barra de tarefas."
  } else {
    Set-ItemProperty -Path $path -Name "TaskbarDa" -Value 0 -Type DWord -Force
    Write-Output "on: botao de Widgets removido da barra de tarefas."
  }
  # So mata o Explorer -- o Windows religa ele sozinho automaticamente
  # como shell (e' assim que o "Reiniciar" do Gerenciador de Tarefas
  # funciona). Chamar Start-Process explorer.exe aqui de novo, depois
  # que o Windows ja religou, abre uma janela nova e visivel (Inicio) --
  # bug real relatado pelo usuario: abria sozinho ao aplicar perfil e
  # voltava a aparecer apos reiniciar o PC (Windows restaura janela que
  # ficou aberta).
  Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
} catch {
  Write-Output "AVISO: nao consegui mudar essa configuracao ($_)"
}
