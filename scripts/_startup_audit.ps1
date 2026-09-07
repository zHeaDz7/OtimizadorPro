# Lista programas que abrem sozinhos junto com o Windows, e deixa a pessoa
# escolher quais desativar (nunca automatico -- desativar coisa errada por
# engano pode tirar algo que a pessoa precisa, tipo antivirus ou driver).
# Cobre os DOIS tipos de inicializacao: atalho na pasta Inicializar (move
# pra uma subpasta, reversivel) E entrada no Registro -- Run/RunOnce
# (renomeia o valor com um prefixo, o Windows para de reconhecer, mas o
# comando original fica salvo ali mesmo, 100% reversivel por essa mesma
# tela).
$ErrorActionPreference = "SilentlyContinue"
$prefixo = "Desativado_OtimizadorPro_"

function Get-ChavesRun {
  return @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
  )
}

# --- Itens ATIVOS (via WMI, cobre pasta + registro + mais alguns locais) ---
$itens = @(Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location, User)

# --- Itens ja DESATIVADOS por nos, pra oferecer reativar ---
$desativadosRegistro = @()
foreach ($chave in (Get-ChavesRun)) {
  if (Test-Path $chave) {
    (Get-Item $chave).GetValueNames() | Where-Object { $_ -like "$prefixo*" } | ForEach-Object {
      $desativadosRegistro += [PSCustomObject]@{ Chave = $chave; Nome = $_; NomeOriginal = $_.Substring($prefixo.Length) }
    }
  }
}
$pastaOrigem = [Environment]::GetFolderPath("Startup")
$pastaDesativados = Join-Path $pastaOrigem "Desativados_OtimizadorPro"
$desativadosPasta = @()
if (Test-Path $pastaDesativados) {
  $desativadosPasta = @(Get-ChildItem $pastaDesativados -File -ErrorAction SilentlyContinue)
}

if (-not $itens -and $desativadosRegistro.Count -eq 0 -and $desativadosPasta.Count -eq 0) {
  Write-Output "Nenhum item de inicializacao encontrado."
  return
}

Write-Output "Programas que abrem junto com o Windows:"
Write-Output ""
$i = 1
$indice = @{}
foreach ($it in $itens) {
  $tipo = if ($it.Location -match "Startup") { "pasta" } else { "registro" }
  Write-Output ("  {0,2}. {1} ({2})" -f $i, $it.Name, $tipo)
  $indice[$i] = $it
  $i++
}

if ($desativadosRegistro.Count -gt 0 -or $desativadosPasta.Count -gt 0) {
  Write-Output ""
  Write-Output "Ja desativados por este programa (pode reativar digitando com R na frente, ex: R1):"
  $r = 1
  $indiceReativar = @{}
  foreach ($d in $desativadosRegistro) {
    Write-Output ("  R{0}. {1} (registro)" -f $r, $d.NomeOriginal)
    $indiceReativar[$r] = @{ Tipo = "registro"; Item = $d }
    $r++
  }
  foreach ($d in $desativadosPasta) {
    Write-Output ("  R{0}. {1} (pasta)" -f $r, $d.Name)
    $indiceReativar[$r] = @{ Tipo = "pasta"; Item = $d }
    $r++
  }
}

Write-Output ""
Write-Output "  0. Nao mexer em nada, so queria ver"
Write-Output ""
Write-Output "AVISO: nao desative nada que voce nao reconhece com certeza (ex: antivirus, driver de audio/RGB)."
$escolha = Read-Host "Numeros pra DESATIVAR, ou R+numero pra REATIVAR (ex: 1,3,R2), ou 0"
if ($escolha -eq "0" -or [string]::IsNullOrWhiteSpace($escolha)) {
  Write-Output "Nada alterado."
  return
}

foreach ($parte in ($escolha -split ",")) {
  $parte = $parte.Trim()

  if ($parte -match "^[Rr](\d+)$") {
    $num = [int]$matches[1]
    if ($indiceReativar -and $indiceReativar.ContainsKey($num)) {
      $alvo = $indiceReativar[$num]
      try {
        if ($alvo.Tipo -eq "registro") {
          $d = $alvo.Item
          $valorAtual = (Get-ItemProperty -Path $d.Chave -Name $d.Nome).($d.Nome)
          Set-ItemProperty -Path $d.Chave -Name $d.NomeOriginal -Value $valorAtual -Force
          Remove-ItemProperty -Path $d.Chave -Name $d.Nome -Force
          Write-Output "reativado: $($d.NomeOriginal)"
        } else {
          Move-Item -LiteralPath $alvo.Item.FullName -Destination $pastaOrigem -Force
          Write-Output "reativado: $($alvo.Item.Name)"
        }
      } catch {
        Write-Output "nao consegui reativar: $_"
      }
    }
    continue
  }

  if ($parte -match "^\d+$") {
    $num = [int]$parte
    if ($indice.ContainsKey($num)) {
      $alvo = $indice[$num]
      try {
        if ($alvo.Location -match "Startup") {
          New-Item -ItemType Directory -Force -Path $pastaDesativados | Out-Null
          $arquivo = Get-ChildItem $pastaOrigem -Filter "*$($alvo.Name)*" -ErrorAction SilentlyContinue | Select-Object -First 1
          if ($arquivo) {
            Move-Item -LiteralPath $arquivo.FullName -Destination $pastaDesativados -Force
            Write-Output "desativado (movido pra Desativados_OtimizadorPro): $($alvo.Name)"
          }
        } else {
          $encontrou = $false
          foreach ($chave in (Get-ChavesRun)) {
            if (Test-Path $chave) {
              $valor = (Get-ItemProperty -Path $chave -Name $alvo.Name -ErrorAction SilentlyContinue)
              if ($valor) {
                Set-ItemProperty -Path $chave -Name "$prefixo$($alvo.Name)" -Value $valor.($alvo.Name) -Force
                Remove-ItemProperty -Path $chave -Name $alvo.Name -Force
                Write-Output "desativado (renomeado no registro, reversivel por essa mesma tela): $($alvo.Name)"
                $encontrou = $true
                break
              }
            }
          }
          if (-not $encontrou) {
            Write-Output "AVISO: '$($alvo.Name)' nao esta nas chaves Run padrao (pode ser Tarefa Agendada ou Servico) -- desative manualmente pelo Gerenciador de Tarefas > aba Inicializar."
          }
        }
      } catch {
        Write-Output "nao consegui desativar $($alvo.Name): $_"
      }
    }
  }
}
