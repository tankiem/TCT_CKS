# ================= CONFIG =================
$url = "https://raw.githubusercontent.com/tankiem/TCT_CKS/fb250b28dc42adc15086a8514e8027fec7af5426/ncca_csp11_v1_installer_full.zip"
$zipFilePath = "$env:TEMP\ncca.zip"
$extractPath = "$env:TEMP\ncca"
$installerName = "ncca_csp11_v1_installer_full.exe"

# ================= CHECK ADMIN =================
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {

    Write-Host "Đang chạy lại với quyền Admin..."
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# ================= DOWNLOAD =================
function Download-File {
    param ($url, $output)

    for ($i=1; $i -le 3; $i++) {
        try {
            Write-Host "Đang tải lần $i..."
            Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
            if (Test-Path $output) {
                Write-Host "Download thành công!"
                return $true
            }
        } catch {
            Write-Warning "Lỗi tải, thử lại..."
            Start-Sleep 3
        }
    }
    return $false
}

if (!(Download-File $url $zipFilePath)) {
    Write-Error "Download thất bại!"
    exit
}

# ================= EXTRACT =================
if (Test-Path $extractPath) {
    Remove-Item $extractPath -Recurse -Force
}

Expand-Archive -Path $zipFilePath -DestinationPath $extractPath -Force

# ================= INSTALL =================
$installerPath = Join-Path $extractPath $installerName

if (!(Test-Path $installerPath)) {
    Write-Error "Không tìm thấy file cài!"
    exit
}

Write-Host "Đang cài đặt..."

# ⚠️ thử các mode silent phổ biến
$argumentsList = @(
    "/S",
    "/silent",
    "/quiet",
    "/verysilent"
)

foreach ($arg in $argumentsList) {
    try {
        Start-Process $installerPath -ArgumentList $arg -Wait
        Write-Host "Đã thử mode: $arg"
        break
    } catch {}
}

Write-Host "Cài đặt hoàn tất!"

# ================= CLEAN =================
Remove-Item $zipFilePath -Force -ErrorAction SilentlyContinue
Remove-Item $extractPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Done!"
