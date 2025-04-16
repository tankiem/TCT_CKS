# === CONFIG ===
$downloadFolder = "$env:USERPROFILE\Desktop"
$zipFileName = "FPT_Installer.zip"
$exeName = "FPT_Installer.exe"
$downloadUrl = "https://drive.usercontent.google.com/download?id=1F9pQy1Lv6Jq4zDnwzp8mB1Au6gSM1XLU&export=download&authuser=1&confirm=t&uuid=ed60bb2c-9436-4ea9-9ecc-b53d1977ea10&at=AEz70l7-z2bzrTbQrGoTaZ0gjm7L:1741399826501"

# === Tải file ZIP ===
$zipPath = Join-Path $downloadFolder $zipFileName
Write-Host "Dang tai file ZIP tu: $downloadUrl"
try {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($downloadUrl, $zipPath)
    Write-Host "Đã tải xong: $zipPath"
} catch {
    Write-Host "Lỗi khi tải file ZIP. Thoát."
    exit
}

# === Giải nén bằng Shell.Application ===
$shell = New-Object -ComObject Shell.Application
$zip = $shell.NameSpace($zipPath)
if (-not $zip) {
    Write-Host "Không mở được file ZIP. Thoát."
    exit
}

$extractPath = Join-Path $downloadFolder "FPT_Extracted_$(Get-Date -Format 'yyyyMMddHHmmss')"
New-Item -ItemType Directory -Path $extractPath | Out-Null
$destination = $shell.NameSpace($extractPath)
$destination.CopyHere($zip.Items(), 16)
Start-Sleep -Seconds 3  # Đợi 1 chút cho giải nén xong

Write-Host "Đã giải nén đến: $extractPath"

# === Tìm và chạy EXE ===
$exePath = Get-ChildItem -Path $extractPath -Filter $exeName -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
if ($exePath) {
    Write-Host "Dang chay file: $($exePath.FullName)"
    Start-Process -FilePath $exePath.FullName /q -Wait
    Write-Host "Đã cài đặt xong."
} else {
    Write-Host "Không tìm thấy file $exeName. Thoát."
    exit
}

# === Xóa file ZIP và thư mục đã giải nén ===
Write-Host "Đang xóa file ZIP và thư mục đã giải nén..."
Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue
Remove-Item -Path $extractPath -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Dọn dẹp xong. Hoàn tất."
