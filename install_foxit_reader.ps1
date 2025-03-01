# Cấu hình các biến
$DesktopPath = "$env:USERPROFILE\Desktop"
$ExeFilePath = "$DesktopPath\FoxitPDFReader1212_enu_Setup_Prom.exe"
$DownloadUrl = "https://cksvietnam.vn/download/FoxitPDFReader1212_enu_Setup_Prom.exe"

# Tải file cài đặt
Write-Host "Dang tai file cai dat..."
try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $ExeFilePath -ErrorAction Stop
    Write-Host "Tai file thanh cong."
} catch {
    Write-Error "Khong the tai tep: $($_.Exception.Message)"
    Read-Host "Nhan Enter de thoat..."
    exit 1
}

# Cài đặt Foxit Reader
Write-Host "Dang cai dat Foxit Reader..."
try {
    Start-Process -FilePath $ExeFilePath -ArgumentList "/verysilent" -Wait -ErrorAction Stop
    Write-Host "Foxit Reader da cai dat thanh cong!"
} catch {
    Write-Error "Cai dat Foxit Reader that bai: $($_.Exception.Message)"
    Read-Host "Nhan Enter de thoat..."
    exit 1
}

# Xóa file cài đặt
Write-Host "Dang xoa file cai dat..."
try {
    Remove-Item -Path $ExeFilePath -ErrorAction Stop
    Write-Host "Da xoa file cai dat."
} catch {
    Write-Error "Khong the xoa file: $($_.Exception.Message)"
    Read-Host "Nhan Enter de thoat..."
    exit 1
}

Write-Host "Hoan tat."
Read-Host "Nhan Enter de thoat..."