# ===== TLS =====
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ===== CONFIG TOOL =====
# Đã thêm [ordered] để danh sách hiển thị đúng thứ tự từ trên xuống dưới
$TOOLS = [ordered]@{
    "NCCA" = @{
        url = "https://raw.githubusercontent.com/tankiem/TCT_CKS/fb250b28dc42adc15086a8514e8027fec7af5426/ncca_csp11_v1_installer_full.zip"
        type = "zip"
        silent = "/S"
    }
    "Viettel" = @{
        url = "https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/Token_manager/viettel-ca_v6.zip"
        type = "zip"
        silent = "/S"
    }
    "FastCA" = @{
        url = "https://raw.githubusercontent.com/tankiem/TCT_CKS/fb250b28dc42adc15086a8514e8027fec7af5426/Setup%20FAST.exe.zip"
        type = "zip"
        silent = "/SILENT"
    }
    "eSigner" = @{
        url = "https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/main/esigner.cmd"
        type = "cmd"
    }
    "CTHub" = @{
        url = "https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/main/CTSigningHub.bat"
        type = "cmd"
    }
}

# ===== FORM =====
$form = New-Object Windows.Forms.Form
$form.Text = "Token Manager"
$form.Size = '600,550'
$form.StartPosition = "CenterScreen"
# Thêm thuộc tính này để code Form hiển thị mượt hơn ở một số độ phân giải
$form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font 

# ===== CHECKBOX =====
$checkboxes = @{}
$y = 20

foreach ($name in $TOOLS.Keys) {
    $cb = New-Object Windows.Forms.CheckBox
    $cb.Text = $name
    $cb.Location = "20,$y"
    $cb.AutoSize = $true # Cho phép checkbox tự dãn theo độ dài chữ
    $form.Controls.Add($cb)
    $checkboxes[$name] = $cb
    $y += 30
}

# ===== BUTTON =====
$btn = New-Object Windows.Forms.Button
$btn.Text = "Cài đặt"
$btn.Location = "20,$y"
$form.Controls.Add($btn)

# ===== LOG =====
$logBox = New-Object Windows.Forms.TextBox
$logBox.Multiline = $true
$logBox.ScrollBars = "Vertical"
$logBox.Location = "20,200"
$logBox.Size = "540,280"
$logBox.Font = "Consolas,9"
$form.Controls.Add($logBox)

# ===== LOG FUNCTION =====
function Log($msg) {
    $logBox.AppendText("$msg`r`n")
    # Thay vì chỉ Refresh, DoEvents giúp Form không bị đơ trong lúc tải/cài đặt
    [System.Windows.Forms.Application]::DoEvents() 
}

# ===== INSTALL FUNCTION =====
function Install-Tool($name, $cfg) {
    try {
        Log("==== $name ====")
        
        # Xác định đuôi file dựa vào type
        $ext = if ($cfg.type -eq "zip") { ".zip" } else { ".cmd" }
        $file = "$env:TEMP\$name$ext"
        $outFolder = "$env:TEMP\$name-out"

        # download
        Log("⬇️ Đang tải...")
        Invoke-WebRequest $cfg.url -OutFile $file -UseBasicParsing

        if ($cfg.type -eq "zip") {
            # Xóa thư mục giải nén cũ nếu còn tồn tại
            if (Test-Path $outFolder) { Remove-Item $outFolder -Recurse -Force }
            
            Log("📦 Đang giải nén...")
            Expand-Archive $file -DestinationPath $outFolder -Force

            $exe = Get-ChildItem $outFolder -Filter *.exe -Recurse | Select-Object -First 1

            if (-not $exe) {
                throw "Không tìm thấy file .exe trong tệp ZIP"
            }

            Log("🚀 Đang cài đặt ($($exe.Name))...")
            $p = Start-Process $exe.FullName -ArgumentList $cfg.silent -PassThru -Wait

            Start-Sleep 2 # Chờ thêm 1 chút để hệ thống ổn định sau cài đặt
            
            # Dọn dẹp rác sau khi cài xong
            Remove-Item $outFolder -Recurse -Force -ErrorAction SilentlyContinue
            
        } else {
            Log("🚀 Đang chạy script...")
            # Truyền tham số an toàn hơn bằng ArgumentList
            $p = Start-Process "cmd.exe" -ArgumentList "/c `"$file`"" -PassThru -Wait
        }

        # Dọn dẹp file tải về
        Remove-Item $file -Force -ErrorAction SilentlyContinue

        Log("✔ $name thành công!")
    }
    catch {
        Log("❌ $name lỗi: $($_.Exception.Message)")
    }
}

# ===== BUTTON CLICK =====
$btn.Add_Click({
    # Vô hiệu hóa nút nhấn để tránh người dùng bấm 2 lần
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
    [System.Windows.Forms.MessageBox]::Show("Quá trình xử lý đã xong!", "Thông báo", 0, [System.Windows.Forms.MessageBoxIcon]::Information)
})

# Chạy Form
$form.ShowDialog() | Out-Null