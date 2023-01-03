#
# 画像の高さ方向のサイズ変更
#
# $path:   画像フォルダ
# $height: 高さ
#

param(
	[parameter(mandatory)][string]$path, 
	[parameter(mandatory)][int]$height, 
	[string]$imgf = "jpeg"
)

[void][Reflection.Assembly]::LoadWithPartialName("System.Drawing")

$imgFList = @{
	jpeg = [System.Drawing.Imaging.ImageFormat]::Jpeg;
	bmp  = [System.Drawing.Imaging.ImageFormat]::Bmp;
	exif = [System.Drawing.Imaging.ImageFormat]::Exif;
	gif  = [System.Drawing.Imaging.ImageFormat]::Gif;
	ico  = [System.Drawing.Imaging.ImageFormat]::Icon;
	png  = [System.Drawing.Imaging.ImageFormat]::Png;
	tiff = [System.Drawing.Imaging.ImageFormat]::Tiff;
	wmf  = [System.Drawing.Imaging.ImageFormat]::Wmf;
}

if (-not (Test-Path $path)) {
	write-error "Invalid argument `"path`"."
	return
}

if (!$imgFList.ContainsKey($imgf)) {
	write-error "Invalid argument `"imgf`"."
	return
}
$imageFormat = $imgFList[$imgf]

get-childitem $path | ? { !$_.PSIsContainer } | % {
	$image = New-Object System.Drawing.Bitmap($_.fullname)
	[int]$width = [math]::Truncate(($height / $image.Height) * $image.Width + .5)

	$canvas = New-Object System.Drawing.Bitmap($width, $height)
	$graphics = [System.Drawing.Graphics]::FromImage($canvas)
	$graphics.DrawImage($image, (New-Object System.Drawing.Rectangle(0, 0, $canvas.Width, $canvas.Height)))

	$outdir = Join-Path $_.DirectoryName "out"
	If(!(Test-Path $outdir)){ New-Item -Path $outdir -ItemType Directory}
	$outfile = $_.basename + "_" + $height + "." + $imgf
	$outpath = Join-Path $outdir $outfile
	Write-Host "$outpath : ($($image.Width), $($image.Height)) -> ($width, $height)"

	$canvas.Save($outpath, $imageFormat)
	if ($graphics -ne $null) { $graphics.Dispose() }
	if ($canvas -ne $null) { $canvas.Dispose() }
	if ($image -ne $null) { $image.Dispose() }
}