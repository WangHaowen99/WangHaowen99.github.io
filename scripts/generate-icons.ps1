param(
  [string]$OutputDirectory = (Join-Path $PSScriptRoot "..\static\icons")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

function New-RoundedRectanglePath {
  param(
    [float]$Size,
    [float]$Radius
  )

  $diameter = $Radius * 2
  $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $path.AddArc(0, 0, $diameter, $diameter, 180, 90)
  $path.AddArc($Size - $diameter, 0, $diameter, $diameter, 270, 90)
  $path.AddArc($Size - $diameter, $Size - $diameter, $diameter, $diameter, 0, 90)
  $path.AddArc(0, $Size - $diameter, $diameter, $diameter, 90, 90)
  $path.CloseFigure()
  return $path
}

function New-WhIcon {
  param(
    [int]$Size,
    [string]$FileName,
    [bool]$Maskable = $false
  )

  $bitmap = [System.Drawing.Bitmap]::new($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $graphics.Clear([System.Drawing.Color]::Transparent)

  $blue = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml("#1a73e8"))
  if ($Maskable) {
    $graphics.FillRectangle($blue, 0, 0, $Size, $Size)
  }
  else {
    $rounded = New-RoundedRectanglePath -Size $Size -Radius ($Size * 112 / 512)
    $graphics.FillPath($blue, $rounded)
    $rounded.Dispose()
  }

  $scale = $Size / 512.0
  $pen = [System.Drawing.Pen]::new([System.Drawing.Color]::White, [Math]::Max(2, 34 * $scale))
  $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

  $w = [System.Drawing.PointF[]]@(
    [System.Drawing.PointF]::new(76 * $scale, 150 * $scale),
    [System.Drawing.PointF]::new(120 * $scale, 362 * $scale),
    [System.Drawing.PointF]::new(178 * $scale, 245 * $scale),
    [System.Drawing.PointF]::new(236 * $scale, 362 * $scale),
    [System.Drawing.PointF]::new(280 * $scale, 150 * $scale)
  )
  $graphics.DrawLines($pen, $w)
  $graphics.DrawLine($pen, 324 * $scale, 150 * $scale, 324 * $scale, 362 * $scale)
  $graphics.DrawLine($pen, 436 * $scale, 150 * $scale, 436 * $scale, 362 * $scale)
  $graphics.DrawLine($pen, 324 * $scale, 256 * $scale, 436 * $scale, 256 * $scale)

  $path = Join-Path $OutputDirectory $FileName
  $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)

  $pen.Dispose()
  $blue.Dispose()
  $graphics.Dispose()
  $bitmap.Dispose()
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
New-WhIcon -Size 32 -FileName "favicon-32.png"
New-WhIcon -Size 180 -FileName "apple-touch-icon.png"
New-WhIcon -Size 192 -FileName "icon-192.png"
New-WhIcon -Size 512 -FileName "icon-512.png"
New-WhIcon -Size 512 -FileName "icon-maskable-512.png" -Maskable $true

Write-Host "Generated PWA icons in $OutputDirectory"
