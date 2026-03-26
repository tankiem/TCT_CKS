# ================= CONFIG =================
$tools = @{
    "1" = @{
        name = "Token NCCA"
        url  = "https://raw.githubusercontent.com/tankiem/TCT_CKS/fb250b28dc42adc15086a8514e8027fec7af5426/ncca_csp11_v1_installer_full.zip"
    }
    "2" = @{
        name = "Token Viettel-CA V6"
        url  = "https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/Token_manager/viettel-ca_v6.zip"
    }
    "3" = @{
        name = "Token FastCA"
        url  = "https://raw.githubusercontent.com/tankiem/TCT_CKS/fb250b28dc42adc15086a8514e8027fec7af5426/Setup%20FAST.exe.zip"
    }
}

# ================= CHECK ADMIN =================
if (-not ([Security.Principal.WindowsPrincipal] `
 [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {

    Write-Host "Đang chạy lại với quyền Admin..."
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# ================= MENU =================
Write-Host "===== DANH SACH TOKEN ====="
foreach ($key in ($tools.Keys | Sort-Object {[int]$_})) {
    Write-Host "$key. $($tools[$key].name)"
}
Write-Host "A. Cai tat ca"

$choice = Read-Host "Nhap lua chon (vd: 1,2,3 hoặc A)"

if ($choice -eq "A") {
    $selected = $tools.Keys | Sort-Object {[int]$_}
} else {
    $selected = ($choice -split ",") | ForEach-Object { $_.Trim() } | Sort-Object {[int]$_}
}

# ================= FUNCTION =================
function Install-Tool($tool) {
    $name = $tool.name
    $url  = $tool.url

    $safeName = $name -replace ' ','_'
    $zipPath = "$env:TEMP\$safeName.zip"
    $extractPath = "$env:TEMP\$safeName"

    Write-Host ""
    Write-Host "===============================" -ForegroundColor Cyan
    Write-Host "▶ BẮT ĐẦU: $name" -ForegroundColor Cyan
    Write-Host "==============================="

    # ===== 1. DOWNLOAD =====
    Write-Host "[1/4] Tải file..."
    $downloaded = $false

    for ($i=1; $i -le 3; $i++) {
        try {
            Write-Host "  → Lần $i..."
            Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing

            if (Test-Path $zipPath) {
                $downloaded = $true
                break
            }
        } catch {
            Start-Sleep 2
        }
    }

    if (-not $downloaded) {
        Write-Host "❌ Tải thất bại" -ForegroundColor Red
        return
    }
    Write-Host "✔ Tải thành công"

    # ===== 2. EXTRACT =====
    Write-Host "[2/4] Giải nén..."
    try {
        if (Test-Path $extractPath) {
            Remove-Item $extractPath -Recurse -Force
        }

        Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
        Write-Host "✔ Giải nén thành công"
    } catch {
        Write-Host "❌ Lỗi giải nén" -ForegroundColor Red
        return
    }

    # ===== 3. FIND INSTALLER =====
    Write-Host "[3/4] Tìm installer..."
    $installer = Get-ChildItem -Path $extractPath -Filter "*.exe" -Recurse | Select-Object -First 1

    if (!$installer) {
        Write-Host "❌ Không tìm thấy file .exe" -ForegroundColor Red
        return
    }

    Write-Host "✔ Tìm thấy: $($installer.Name)"

    # ===== 4. INSTALL =====
    Write-Host "[4/4] Cài đặt..."
    $argsList = @("/S","/silent","/quiet","/verysilent","/SILENT")
    $installed = $false

    foreach ($arg in $argsList) {
        try {
            Write-Host "  → Thử mode: $arg"

            $process = Start-Process $installer.FullName -ArgumentList $arg -Wait -PassThru

            # 👉 FIX popup language (NSIS Viettel)
            Start-Sleep -Seconds 2
            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

            if ($process.ExitCode -eq 0) {
                Write-Host "✔ Thành công với: $arg" -ForegroundColor Green
                $installed = $true
                break
            }
        } catch {}
    }

    if (-not $installed) {
        Write-Host "⚠️ Không silent được → mở thủ công" -ForegroundColor Yellow
        Start-Process $installer.FullName
    }

    Write-Host "✔ HOÀN TẤT: $name" -ForegroundColor Green

    # ===== CLEAN =====
    Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
    Remove-Item $extractPath -Recurse -Force -ErrorAction SilentlyContinue
}

# ================= RUN =================
foreach ($key in $selected) {
    if ($tools.ContainsKey($key)) {
        Install-Tool $tools[$key]
    } else {
        Write-Host "❌ Lựa chọn không hợp lệ: $key" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "===== DONE =====" -ForegroundColor Cyan