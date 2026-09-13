# Helpers de UI compartilhados entre as abas -- centraliza o padrao de
# card que antes era repetido (com pequenas variacoes) em cada
# Tab-*.ps1. So mexe em como o card e CONSTRUIDO -- cada aba continua
# dona do conteudo que coloca dentro.
#
# New-CartaoEstat usa New-Icone (de _Icons.ps1) pro badge -- dot-source
# aqui garante que a funcao existe mesmo se algum modulo carregar
# _UI.ps1 sem ter carregado _Icons.ps1 antes.
. (Join-Path $PSScriptRoot "_Icons.ps1")

# Card padrao: fundo BrushSurface (branco), borda fina, cantos
# arredondados. $padding aceita os mesmos formatos que Border.Padding
# ja aceitava antes (numero unico ou "a,b" / "a,b,c,d").
function New-Cartao($window, $padding = 18, $margin = "0,0,0,16") {
  $cartao = New-Object System.Windows.Controls.Border
  $cartao.Background = $window.FindResource("BrushSurface")
  $cartao.BorderBrush = $window.FindResource("BrushBorder")
  $cartao.BorderThickness = 1
  $cartao.CornerRadius = 10
  $cartao.Padding = $padding
  $cartao.Margin = $margin
  $painel = New-Object System.Windows.Controls.StackPanel
  $cartao.Child = $painel
  return @{ Cartao = $cartao; Painel = $painel }
}

# Cartao de estatistica (estilo "$597" da referencia): badge de icone
# num quadrado arredondado com fundo suave de destaque, valor grande em
# negrito, rotulo pequeno embaixo. Usado com moderacao -- so onde ja
# existe um numero/fato real pra destacar (ver plano), nunca inventado.
function New-CartaoEstat($window, [string]$icone, [string]$valor, [string]$rotulo) {
  $cartao = New-Object System.Windows.Controls.Border
  $cartao.Background = $window.FindResource("BrushSurface")
  $cartao.BorderBrush = $window.FindResource("BrushBorder")
  $cartao.BorderThickness = 1
  $cartao.CornerRadius = 12
  $cartao.Padding = "18,16"
  $cartao.Margin = "0,0,14,14"
  $cartao.Width = 200

  $sombra = New-Object System.Windows.Media.Effects.DropShadowEffect
  $sombra.BlurRadius = 12
  $sombra.ShadowDepth = 2
  $sombra.Opacity = 0.10
  $sombra.Color = [System.Windows.Media.Colors]::Black
  $cartao.Effect = $sombra

  $painel = New-Object System.Windows.Controls.StackPanel

  $badge = New-Object System.Windows.Controls.Border
  $badge.Background = $window.FindResource("BrushAccentSoft")
  $badge.CornerRadius = 9
  $badge.Width = 38
  $badge.Height = 38
  $badge.Margin = "0,0,0,12"
  $badge.Child = (New-Icone $window $icone 18 $window.FindResource("BrushAccentInk"))
  $painel.Children.Add($badge) | Out-Null

  $txtValor = New-Object System.Windows.Controls.TextBlock
  $txtValor.Text = $valor
  $txtValor.Foreground = $window.FindResource("BrushInk")
  $txtValor.FontSize = 26
  $txtValor.FontWeight = "Bold"
  $painel.Children.Add($txtValor) | Out-Null

  $txtRotulo = New-Object System.Windows.Controls.TextBlock
  $txtRotulo.Text = $rotulo
  $txtRotulo.Foreground = $window.FindResource("BrushMuted")
  $txtRotulo.FontSize = 12
  $txtRotulo.Margin = "0,3,0,0"
  $txtRotulo.TextWrapping = "Wrap"
  $painel.Children.Add($txtRotulo) | Out-Null

  $cartao.Child = $painel
  return @{ Cartao = $cartao; TxtValor = $txtValor; TxtRotulo = $txtRotulo }
}
