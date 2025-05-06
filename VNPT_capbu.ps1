# Đường dẫn URL của file cần tải VNPT_CAM
$url = "https://smartca.vnpt.vn/download/VNPT_CAMS_Plugin_Setup.exe"

# Đường dẫn đến thư mục Desktop
$desktopPath = [Environment]::GetFolderPath("Desktop")

# Tạo đường dẫn đầy đủ cho file tải về
$installerPath = Join-Path -Path $desktopPath -ChildPath "VNPT_CAMS_Plugin_Setup.exe"

# Kiểm tra xem script có đang chạy với quyền quản trị viên không
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Script cần được chạy với quyền quản trị viên. Đang thử khởi động lại..."
    # Lấy đường dẫn đến PowerShell
    $powershellPath = Get-Process -Id $PID | Select-Object -ExpandProperty Path
    # Khởi động lại script với quyền quản trị viên
    Start-Process -FilePath $powershellPath -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    # Dừng script hiện tại
    exit
}

# Tải file từ URL về Desktop
try {
    Write-Host "Bắt đầu tải file từ: $url"
    Invoke-WebRequest -Uri $url -OutFile $installerPath
    Write-Host "Đã tải file thành công vào: $installerPath"
} catch {
    Write-Error "Lỗi khi tải file: $($_.Exception.Message)"
    return
}

# Chạy file cài đặt và đợi quá trình cài đặt hoàn tất
try {
    Write-Host "Bắt đầu chạy file cài đặt: $installerPath"
    Start-Process -FilePath $installerPath -ArgumentList "/SILENT" -Wait # Thêm tham số /SILENT để chạy silent
    Write-Host "Đã chạy file cài đặt thành công!"

} catch {
    Write-Error "Lỗi khi chạy file cài đặt: $($_.Exception.Message)"
}

# Xóa file cài đặt sau khi cài đặt xong
Remove-Item $installerPath -Force
Write-Host "Đã xóa file cài đặt."
Write-Host "Hoàn tất script."
