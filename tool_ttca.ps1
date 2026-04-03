# ===== TLS & ASSEMBLIES =====
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ===== DANH SÁCH TOOL TỔNG HỢP =====
$TOOLS = [ordered]@{
    "1. Cài đặt Foxit Reader" = @{ url = "https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/main/install_foxit_reader.cmd"; type = "cmd" }
    "2. Cài đặt Java 8.121" = @{ url = "https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/main/install_java8.cmd"; type = "cmd" }
    "3. Cài đặt Java 7.3" = @{ url = "https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/main/install_java7.cmd"; type = "cmd" }
    "4. Cài tool FPT" = @{ url = "https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/main/FPT_install.cmd"; type = "cmd" }
    "5. Cài plugin VNPT" = @{ url = "https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/main/vnpt_plugin"; type = "cmd" }
    "6. Cài tool ký BHXH free" = @{ url = "https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/main/tool_ky_bhxh_mienphi"; type = "cmd" }
    "7. Token: NCCA" = @{ url = "https://raw.githubusercontent.com/tankiem/TCT_CKS/fb250b28dc42adc15086a8514e8027fec7af5426/ncca_csp11_v1_installer_full.zip"; type = "zip"; silent = "/S" }
    "8. Token: Viettel" = @{ url = "https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/Token_manager/viettel-ca_v6.zip"; type = "zip"; silent = "/S" }
    "9. Token: FastCA" = @{ url = "https://raw.githubusercontent.com/tankiem/TCT_CKS/fb250b28dc42adc15086a8514e8027fec7af5426/Setup%20FAST.exe.zip"; type = "zip"; silent = "/SILENT" }
    "10. Esigner (Thuế ĐT)" = @{ url = "https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/main/esigner.cmd"; type = "cmd" }
    "11. CTSigningHub (DVC)" = @{ url = "https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/main/CTSigningHub.bat"; type = "cmd" }
}

# ===== FORM SETTINGS =====
$form = New-Object Windows.Forms.Form
$form.Text = "Tool Setup Tổng Hợp"
$form.Size = '600,600'
$form.StartPosition = "CenterScreen"
$form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font 

# ===== CHECKBOX (CHIA 2 CỘT) =====
$checkboxes = @{}
$x = 20
$y = 20
$count = 0

foreach ($name in $TOOLS.Keys) {
    $cb = New-Object Windows.Forms.CheckBox
    $cb.Text = $name
    $cb.Location = "$x,$y"
    $cb.AutoSize = $true
    $form.Controls.Add($cb)
    $checkboxes[$name] = $cb
    
    $y += 30
    $count++
    
    # Đủ 6 mục ở cột 1 thì đẩy sang cột 2
    if ($count -eq 6) {
        $x = 300
        $y = 20
    }
}

# ===== BUTTON =====
$btn = New-Object Windows.Forms.Button
$btn.Text = "Cài đặt các mục đã chọn"
$btn.Location = "20,210"
$btn.Size = "180,30"
$form.Controls.Add($btn)

# ===== LOG =====
$logBox = New-Object Windows.Forms.TextBox
$logBox.Multiline = $true
$logBox.ScrollBars = "Vertical"
$logBox.Location = "20,260"
$logBox.Size = "540,280"
$logBox.Font = "Consolas,9"
$form.Controls.Add($logBox)

# ===== LOG FUNCTION =====
function Log($msg) {
    $logBox.AppendText("$msg`r`n")
    [System.Windows.Forms.Application]::DoEvents() 
}

# ===== INSTALL FUNCTION =====
function Install-Tool($name, $cfg) {
    try {
        Log("==== $name ====")
        
        $ext = if ($cfg.type -eq "zip") { ".zip" } else { ".cmd" }
        $file = "$env:TEMP\temp_setup_file$ext"
        $outFolder = "$env:TEMP\temp_setup_out"

        Log("⬇️ Đang tải...")
        Invoke-WebRequest $cfg.url -OutFile $file -UseBasicParsing

        if ($cfg.type -eq "zip") {
            if (Test-Path $outFolder) { Remove-Item $outFolder -Recurse -Force }
            
            Log("📦 Đang giải nén...")
            Expand-Archive $file -DestinationPath $outFolder -Force

            $exe = Get-ChildItem $outFolder -Filter *.exe -Recurse | Select-Object -First 1

            if (-not $exe) {
                throw "Không tìm thấy file .exe trong tệp ZIP"
            }

            Log("🚀 Đang cài đặt ($($exe.Name))...")
            $p = Start-Process $exe.FullName -ArgumentList $cfg.silent -PassThru -Wait

            Start-Sleep 2 
            
            Remove-Item $outFolder -Recurse -Force -ErrorAction SilentlyContinue
            
        } else {
            Log("🚀 Đang chạy script...")
            $p = Start-Process "cmd.exe" -ArgumentList "/c `"$file`"" -PassThru -Wait
        }

        Remove-Item $file -Force -ErrorAction SilentlyContinue

        Log("✔ Thành công!")
    }
    catch {
        Log("❌ Lỗi: $($_.Exception.Message)")
    }
}

# ===== BUTTON CLICK =====
$btn.Add_Click({
    $btn.Enabled = $false
    Log("🚀 BẮT ĐẦU XỬ LÝ...")

    foreach ($name in $TOOLS.Keys) {
        if ($checkboxes[$name].Checked) {
            Install-Tool $name $TOOLS[$name]
            Log("------------------------")
        }
    }

    Log("===== HOÀN TẤT =====")
    $btn.Enabled = $true
    [System.Windows.Forms.MessageBox]::Show("Quá trình cài đặt đã hoàn tất!", "Thông báo", 0, [System.Windows.Forms.MessageBoxIcon]::Information)
})

# Chạy Form
$form.ShowDialog() | Out-Null
