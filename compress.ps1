Add-Type -AssemblyName System.Drawing
$files = Get-ChildItem -Path images -Recurse -Include *.png, *.jpg, *.jpeg
foreach ($file in $files) {
    try {
        $img = [System.Drawing.Image]::FromFile($file.FullName)
        $scale = 1000 / $img.Width
        if ($scale -lt 1) {
            $newW = 1000
            $newH = [math]::Round($img.Height * $scale)
            $bmp = New-Object System.Drawing.Bitmap($newW, $newH)
            $graph = [System.Drawing.Graphics]::FromImage($bmp)
            $graph.DrawImage($img, 0, 0, $newW, $newH)
            $img.Dispose()
            $graph.Dispose()
            
            # Save as JPG
            $newPath = $file.FullName -replace '\.png$','.jpg'
            $bmp.Save($newPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
            $bmp.Dispose()
            
            if ($file.Extension -eq '.png') {
                Remove-Item $file.FullName
            }
        } else {
            $img.Dispose()
            # If it's a huge PNG but width is small, just convert to JPG
            if ($file.Extension -eq '.png' -and $file.Length -gt 1MB) {
                $img2 = [System.Drawing.Image]::FromFile($file.FullName)
                $newPath = $file.FullName -replace '\.png$','.jpg'
                $img2.Save($newPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
                $img2.Dispose()
                Remove-Item $file.FullName
            }
        }
    } catch {
        Write-Host "Error processing: $($file.Name)"
    }
}
Write-Host "Compression Complete!"
