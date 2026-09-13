# Sistema de icones do OtimizadorPro -- desenhados a mao, sem imagem
# externa, sem fonte de icone, sem emoji. Cada icone e montado num
# Canvas de 24x24 usando formas basicas do WPF (Line/Polyline/Ellipse/
# Rectangle/Path com ArcSegment) construidas via New-Object -- tudo
# objeto .NET tipado, nada de string de geometria pra interpretar, pra
# nao correr risco de erro de sintaxe de path. New-Icone devolve um
# Viewbox pronto pra anexar em qualquer painel, ja escalado pro tamanho
# pedido.

function New-LinhaIcone([double]$x1, [double]$y1, [double]$x2, [double]$y2, $corBrush, [double]$espessura) {
  $l = New-Object System.Windows.Shapes.Line
  $l.X1 = $x1; $l.Y1 = $y1; $l.X2 = $x2; $l.Y2 = $y2
  $l.Stroke = $corBrush
  $l.StrokeThickness = $espessura
  $l.StrokeStartLineCap = "Round"
  $l.StrokeEndLineCap = "Round"
  return $l
}

function New-PolilinhaIcone([double[][]]$pontos, $corBrush, [double]$espessura) {
  $pl = New-Object System.Windows.Shapes.Polyline
  $colecao = New-Object System.Windows.Media.PointCollection
  foreach ($p in $pontos) { $colecao.Add((New-Object System.Windows.Point($p[0], $p[1]))) }
  $pl.Points = $colecao
  $pl.Stroke = $corBrush
  $pl.StrokeThickness = $espessura
  $pl.StrokeStartLineCap = "Round"
  $pl.StrokeEndLineCap = "Round"
  $pl.StrokeLineJoin = "Round"
  $pl.Fill = "Transparent"
  return $pl
}

function New-CirculoIcone([double]$cx, [double]$cy, [double]$r, $corBrush, [double]$espessura, [bool]$preencher = $false) {
  $e = New-Object System.Windows.Shapes.Ellipse
  $e.Width = $r * 2
  $e.Height = $r * 2
  [System.Windows.Controls.Canvas]::SetLeft($e, $cx - $r)
  [System.Windows.Controls.Canvas]::SetTop($e, $cy - $r)
  $e.Stroke = $corBrush
  $e.StrokeThickness = $espessura
  $e.Fill = if ($preencher) { $corBrush } else { "Transparent" }
  return $e
}

function New-RetanguloIcone([double]$x, [double]$y, [double]$w, [double]$h, $corBrush, [double]$espessura, [double]$raio = 0) {
  $r = New-Object System.Windows.Shapes.Rectangle
  $r.Width = $w
  $r.Height = $h
  [System.Windows.Controls.Canvas]::SetLeft($r, $x)
  [System.Windows.Controls.Canvas]::SetTop($r, $y)
  $r.Stroke = $corBrush
  $r.StrokeThickness = $espessura
  $r.Fill = "Transparent"
  if ($raio -gt 0) { $r.RadiusX = $raio; $r.RadiusY = $raio }
  return $r
}

# Arco simples (um trecho de circulo/elipse) -- usado pros poucos icones
# que precisam de curva de verdade (refresh, power, wifi, usuario).
# Construido via PathGeometry/PathFigure/ArcSegment (tudo objeto .NET
# tipado), nunca via string de "Data" pra evitar erro de sintaxe.
function New-ArcoIcone([double]$x1, [double]$y1, [double]$x2, [double]$y2, [double]$rx, [double]$ry, $corBrush, [double]$espessura, [string]$sentido = "Clockwise", [bool]$arcoGrande = $false) {
  $figura = New-Object System.Windows.Media.PathFigure
  $figura.StartPoint = New-Object System.Windows.Point($x1, $y1)
  $arco = New-Object System.Windows.Media.ArcSegment
  $arco.Point = New-Object System.Windows.Point($x2, $y2)
  $arco.Size = New-Object System.Windows.Size($rx, $ry)
  $arco.SweepDirection = [System.Windows.Media.SweepDirection]::$sentido
  $arco.IsLargeArc = $arcoGrande
  $figura.Segments.Add($arco)
  $geometria = New-Object System.Windows.Media.PathGeometry
  $geometria.Figures.Add($figura)
  $p = New-Object System.Windows.Shapes.Path
  $p.Data = $geometria
  $p.Stroke = $corBrush
  $p.StrokeThickness = $espessura
  $p.StrokeStartLineCap = "Round"
  $p.StrokeEndLineCap = "Round"
  return $p
}

function New-Icone($window, [string]$nome, [double]$tamanho = 18, $corBrush = $null) {
  if (-not $corBrush) { $corBrush = $window.FindResource("BrushInk") }
  $esp = 1.6

  $tela = New-Object System.Windows.Controls.Canvas
  $tela.Width = 24
  $tela.Height = 24

  switch ($nome) {
    "instalar" {
      $tela.Children.Add((New-LinhaIcone 12 3 12 14 $corBrush $esp)) | Out-Null
      $tela.Children.Add((New-PolilinhaIcone @(@(7,9), @(12,14), @(17,9)) $corBrush $esp)) | Out-Null
      $tela.Children.Add((New-PolilinhaIcone @(@(4,15), @(4,20), @(20,20), @(20,15)) $corBrush $esp)) | Out-Null
    }
    "ajustes" {
      $tela.Children.Add((New-LinhaIcone 4 6 20 6 $corBrush $esp)) | Out-Null
      $tela.Children.Add((New-CirculoIcone 14 6 2 $corBrush $esp)) | Out-Null
      $tela.Children.Add((New-LinhaIcone 4 12 20 12 $corBrush $esp)) | Out-Null
      $tela.Children.Add((New-CirculoIcone 8 12 2 $corBrush $esp)) | Out-Null
      $tela.Children.Add((New-LinhaIcone 4 18 20 18 $corBrush $esp)) | Out-Null
      $tela.Children.Add((New-CirculoIcone 16 18 2 $corBrush $esp)) | Out-Null
    }
    "config" {
      $tela.Children.Add((New-CirculoIcone 12 12 3.5 $corBrush $esp)) | Out-Null
      $tela.Children.Add((New-LinhaIcone 12 3 12 7 $corBrush $esp)) | Out-Null
      $tela.Children.Add((New-LinhaIcone 12 17 12 21 $corBrush $esp)) | Out-Null
      $tela.Children.Add((New-LinhaIcone 3 12 7 12 $corBrush $esp)) | Out-Null
      $tela.Children.Add((New-LinhaIcone 17 12 21 12 $corBrush $esp)) | Out-Null
      $tela.Children.Add((New-LinhaIcone 6.5 6.5 9 9 $corBrush $esp)) | Out-Null
      $tela.Children.Add((New-LinhaIcone 15 15 17.5 17.5 $corBrush $esp)) | Out-Null
      $tela.Children.Add((New-LinhaIcone 17.5 6.5 15 9 $corBrush $esp)) | Out-Null
      $tela.Children.Add((New-LinhaIcone 9 15 6.5 17.5 $corBrush $esp)) | Out-Null
    }
    "atualizacoes" {
      $tela.Children.Add((New-ArcoIcone 7 5 19 10 8 8 $corBrush $esp "Clockwise" $false)) | Out-Null
      $tela.Children.Add((New-PolilinhaIcone @(@(16,7), @(19,10), @(15,12)) $corBrush $esp)) | Out-Null
      $tela.Children.Add((New-ArcoIcone 17 19 5 14 8 8 $corBrush $esp "Clockwise" $false)) | Out-Null
      $tela.Children.Add((New-PolilinhaIcone @(@(8,17), @(5,14), @(9,12)) $corBrush $esp)) | Out-Null
    }
    "win11" {
      $tela.Children.Add((New-RetanguloIcone 7 9 10 9 $corBrush $esp 1.2)) | Out-Null
      $tela.Children.Add((New-RetanguloIcone 10 4 4 6 $corBrush $esp 0)) | Out-Null
      $tela.Children.Add((New-CirculoIcone 12 13.5 1.2 $corBrush $esp $true)) | Out-Null
    }
    "diagnostico" {
      $tela.Children.Add((New-PolilinhaIcone @(@(2,12), @(7,12), @(9,5), @(13,19), @(15,12), @(22,12)) $corBrush $esp)) | Out-Null
    }
    "inicializacao" {
      $tela.Children.Add((New-LinhaIcone 12 3 12 11 $corBrush $esp)) | Out-Null
      $tela.Children.Add((New-ArcoIcone 16.5 6 7.5 6 7 7 $corBrush $esp "Clockwise" $true)) | Out-Null
    }
    "gpu" {
      $tela.Children.Add((New-RetanguloIcone 5 6 14 12 $corBrush $esp 1.5)) | Out-Null
      $tela.Children.Add((New-RetanguloIcone 9 10 6 4 $corBrush $esp 0)) | Out-Null
      $tela.Children.Add((New-LinhaIcone 2 9 5 9 $corBrush $esp)) | Out-Null
      $tela.Children.Add((New-LinhaIcone 2 13 5 13 $corBrush $esp)) | Out-Null
      $tela.Children.Add((New-LinhaIcone 19 9 22 9 $corBrush $esp)) | Out-Null
      $tela.Children.Add((New-LinhaIcone 19 13 22 13 $corBrush $esp)) | Out-Null
    }
    "perfis" {
      $tela.Children.Add((New-CirculoIcone 12 8 3.5 $corBrush $esp)) | Out-Null
      $tela.Children.Add((New-ArcoIcone 5 21 19 21 10 11 $corBrush $esp "Counterclockwise" $false)) | Out-Null
    }
    "internet" {
      $tela.Children.Add((New-ArcoIcone 3 9 21 9 11 11 $corBrush $esp "Clockwise" $false)) | Out-Null
      $tela.Children.Add((New-ArcoIcone 6.5 12.5 17.5 12.5 7 7 $corBrush $esp "Clockwise" $false)) | Out-Null
      $tela.Children.Add((New-ArcoIcone 10 16 14 16 3 3 $corBrush $esp "Clockwise" $false)) | Out-Null
      $tela.Children.Add((New-CirculoIcone 12 19 1.1 $corBrush $esp $true)) | Out-Null
    }
    "busca" {
      $tela.Children.Add((New-CirculoIcone 10 10 6 $corBrush $esp)) | Out-Null
      $tela.Children.Add((New-LinhaIcone 14.5 14.5 20 20 $corBrush $esp)) | Out-Null
    }
    default {
      $tela.Children.Add((New-CirculoIcone 12 12 8 $corBrush $esp)) | Out-Null
    }
  }

  $viewbox = New-Object System.Windows.Controls.Viewbox
  $viewbox.Width = $tamanho
  $viewbox.Height = $tamanho
  $viewbox.Stretch = "Uniform"
  $viewbox.Child = $tela
  return $viewbox
}
