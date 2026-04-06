# Yêu cầu chạy PowerShell với quyền Administrator
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Vui lòng chạy PowerShell với quyền Administrator (Run as Administrator) để script có thể cài đặt phần mềm!"
    Break
}

# Load thư viện để tạo giao diện GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Cấu hình cửa sổ chính
$form = New-Object System.Windows.Forms.Form
$form.Text = "Tool Hỗ Trợ Khách Hàng - Cài Đặt CKS & Thuế"
$form.Size = New-Object System.Drawing.Size(550, 600)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# Tiêu đề danh sách
$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "Tích chọn các phần mềm cần tải và cài đặt:"
$lblTitle.Location = New-Object System.Drawing.Point(20, 15)
$lblTitle.AutoSize = $true
$lblTitle.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($lblTitle)

# Danh sách Checkbox
$checkListBox = New-Object System.Windows.Forms.CheckedListBox
$checkListBox.Location = New-Object System.Drawing.Point(20, 40)
$checkListBox.Size = New-Object System.Drawing.Size(490, 250)
$checkListBox.CheckOnClick = $true
$form.Controls.Add($checkListBox)

# Danh sách phần mềm đã sắp xếp theo nhóm 1-4 (Đã bỏ Sfive và HTKK)
$softwareList = @(
    # --- NHÓM 1 ---
    @{ Name = "1. Tool gen FPT"; Url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/FPT_Installer.zip" },
    @{ Name = "1. Tool gen VNPT"; Url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/VNPT_CAMS_Plugin_Setup.exe" },
    
    # --- NHÓM 2 ---
    @{ Name = "2. Plugin thuế - dvc"; Url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/eSigner_1.1.0_setup.zip" },
    @{ Name = "2. Tool ký kho bạc"; Url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/SignatureAppXp_Setup_2.0.zip" },
    @{ Name = "2. Tool ký hóa đơn Viettel"; Url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/viettel-tool-ki-so-1.0.1.exe" },
    @{ Name = "2. Tool ký hóa đơn VNPT"; Url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/VNPT-CA.Plugin_Office_Setup.1.0.5.0.zip" },
    @{ Name = "2. Tool BHXH free"; Url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/vss-declaration-Setup_2.0.7.19.exe" },
    
    # --- NHÓM 3 ---
    @{ Name = "3. Phần mềm token NCCA"; Url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/ncca_csp11_v1_installer_full.zip" },
    @{ Name = "3. Phần mềm token FASTCA"; Url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/Setup.FAST.zip" },
    @{ Name = "3. Phần mềm token Viettel V6"; Url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/viettel-ca_v6.zip" },
    
    # --- NHÓM 4 ---
    @{ Name = "4. Phần mềm đọc xml"; Url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/iTaxViewer2.7.2_v1.zip" },
    @{ Name = "4. Phần mềm ký PDF"; Url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/FoxitPDFReader1212_enu_Setup_Prom.exe" },
    @{ Name = "4. Phần mềm Java 7u3"; Url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/jre-7u3-windows-i586.zip" },
    @{ Name = "4. Phần mềm Java 8u121"; Url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/jre-8u121-windows-i586.zip" }
)

# Thêm dữ liệu vào Checkbox List
foreach ($app in $softwareList) {
    [void]$checkListBox.Items.Add($app.Name)
}

# Nút Chọn tất cả
$btnSelectAll = New-Object System.Windows.Forms.Button
$btnSelectAll.Text = "Chọn tất cả"
$btnSelectAll.Location = New-Object System.Drawing.Point(20, 300)
$btnSelectAll.Size = New-Object System.Drawing.Size(100, 30)
$btnSelectAll.Add_Click({
    for ($i = 0; $i -lt $checkListBox.Items.Count; $i++) {
        $checkListBox.SetItemChecked($i, $true)
    }
})
$form.Controls.Add($btnSelectAll)

# Nút Bỏ chọn tất cả
$bDeselectAll = New-Object System.Windows.Forms.Button
$bDeselectAll.Text = "Bỏ chọn"
$bDeselectAll.Location = New-Object System.Drawing.Point(130, 300)
$bDeselectAll.Size = New-Object System.Drawing.Size(100, 30)
$bDeselectAll.Add_Click({
    for ($i = 0; $i -lt $checkListBox.Items.Count; $i++) {
        $checkListBox.SetItemChecked($i, $false)
    }
})
$form.Controls.Add($bDeselectAll)

# Nút Cài Đặt
$btnInstall = New-Object System.Windows.Forms.Button
$btnInstall.Text = "Thực hiện Tải & Cài đặt"
$btnInstall.Location = New-Object System.Drawing.Point(360, 300)
$btnInstall.Size = New-Object System.Drawing.Size(150, 30)
$btnInstall.BackColor = "LightGreen"
$form.Controls.Add($btnInstall)

# Hộp text hiển thị Log trạng thái
$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Location = New-Object System.Drawing.Point(20, 340)
$txtLog.Size = New-Object System.Drawing.Size(490, 200)
$txtLog.Multiline = $true
$txtLog.ScrollBars = "Vertical"
$txtLog.ReadOnly = $true
$form.Controls.Add($txtLog)

# Hàm ghi Log lên giao diện
function Write-Log {
    param([string]$Message)
    $txtLog.AppendText("$(Get-Date -Format 'HH:mm:ss') - $Message `r`n")
    $txtLog.SelectionStart = $txtLog.Text.Length
    $txtLog.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents() # Giữ giao diện không bị treo
}

# Xử lý sự kiện khi bấm nút Cài đặt
$btnInstall.Add_Click({
    $selectedItems = $checkListBox.CheckedItems
    if ($selectedItems.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Vui lòng chọn ít nhất 1 phần mềm!", "Thông báo", 0, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    $btnInstall.Enabled = $false # Khóa nút tránh bấm nhiều lần
    $installDir = "C:\CKS_AutoInstall"
    
    if (!(Test-Path $installDir)) { 
        New-Item -ItemType Directory -Path $installDir | Out-Null 
    }
    Write-Log "Đã khởi tạo thư mục lưu trữ: $installDir"

    foreach ($itemName in $selectedItems) {
        # Tìm phần mềm tương ứng trong mảng dựa trên tên
        $app = $softwareList | Where-Object { $_.Name -eq $itemName }
        if ($app) {
            try {
                $fileName = [System.IO.Path]::GetFileName($app.Url)
                $filePath = Join-Path $installDir $fileName
                
                Write-Log "Đang tải xuống: $($app.Name)..."
                Invoke-WebRequest -Uri $app.Url -OutFile $filePath -UseBasicParsing
                
                # Cập nhật xử lý file .exe
                if ($fileName.EndsWith(".exe")) {
                    if ($fileName -match "viettel-tool-ki-so") {
                        Write-Log "Đang cài đặt ẩn $($app.Name) với tham số /Q..."
                        Start-Process -FilePath $filePath -ArgumentList "/Q" -Wait -NoNewWindow
                    } else {
                        Write-Log "Đang cài đặt ẩn $($app.Name)..."
                        Start-Process -FilePath $filePath -ArgumentList "/S", "/VERYSILENT", "/quiet" -Wait -NoNewWindow
                    }
                    Write-Log "Hoàn thành xử lý $($app.Name)."
                }
                elseif ($fileName.EndsWith(".zip")) {
                    $extractPath = Join-Path $installDir $fileName.Replace(".zip", "")
                    Write-Log "Đang giải nén $($app.Name)..."
                    Expand-Archive -Path $filePath -DestinationPath $extractPath -Force
                    
                    $setupFiles = Get-ChildItem -Path $extractPath -Include *.exe, *.msi -Recurse
                    foreach ($setup in $setupFiles) {
                        Write-Log "Đang cài đặt $($setup.Name)..."
                        if ($setup.Extension -eq ".msi") {
                            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$($setup.FullName)`" /qn" -Wait -NoNewWindow
                        } else {
                            Start-Process -FilePath $setup.FullName -ArgumentList "/S", "/VERYSILENT", "/quiet" -Wait -NoNewWindow
                        }
                        Write-Log "Hoàn thành cài đặt $($setup.Name)."
                    }
                }
            } catch {
                Write-Log "LỖI khi xử lý $($app.Name): $($_.Exception.Message)"
            }
        }
    }
    Write-Log "====== TẤT CẢ ĐÃ HOÀN TẤT ======"
    $btnInstall.Enabled = $true
})

# Hiển thị giao diện
[void]$form.ShowDialog()
