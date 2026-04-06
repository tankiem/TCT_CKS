# ===== TLS, ASSEMBLIES & PREFERENCES =====
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Tắt Progress Bar của PowerShell để tăng tốc độ Download (Rất quan trọng)
$ProgressPreference = 'SilentlyContinue'

# Bật giao diện Windows hiện đại (Visual Styles)
[System.Windows.Forms.Application]::EnableVisualStyles()

# ===== DANH SÁCH TOOL =====
$TOOLS = [ordered]@{
    "1. Foxit Reader" = @{ url = "https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/main/install_foxit_reader.cmd"; type = "cmd" }
    "2. Java 8" = @{ url = "https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/main/install_java8.cmd"; type = "cmd" }
    "3. Java 7" = @{ url = "https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/main/install_java7.cmd"; type = "cmd" }
    "4. Tool gen FPT" = @{ url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/FPT_Installer.zip"; type = "zip"; silent = "/S" }
    "5. Plugin VNPT Office" = @{ url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/VNPT-CA.Plugin_Office_Setup.1.0.5.0.zip"; type = "zip"; silent = "/S" }
    "6. Plugin BHXH Free" = @{ url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/vss-declaration-Setup_2.0.7.19.exe"; type = "exe"; silent = "/S" }
    "7. Token NCCA" = @{ url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/ncca_csp11_v1_installer_full.zip"; type = "zip"; silent = "/S" }
    "8. Token Viettel V6" = @{ url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/viettel-ca_v6.zip"; type = "zip"; silent = "/S" }
    "9. Token FASTCA" = @{ url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/Setup.FAST.zip"; type = "zip"; silent = "/SILENT" }
    "10. Plugin eSigner" = @{ url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/eSigner_1.1.0_setup.zip"; type = "zip"; silent = "/S" }
    "11. CTSigningHub" = @{ url = "https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/main/CTSigningHub.bat"; type = "cmd" }
    "12. iTaxViewer" = @{ url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/iTaxViewer2.7.2_v1.zip"; type = "zip"; silent = "/S" }
    "13. SFive Browser" = @{ url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/SFive-Browser.exe"; type = "exe"; silent = "/S" }
    "14. Tool Ky Kho Bac" = @{ url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/SignatureAppXp_Setup_2.0.zip"; type = "zip"; silent = "/S" }
    "15. Tool Ky Hoa Don Viettel" = @{ url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/viettel-tool-ki-so-1.0.1.exe"; type = "exe"; silent = "/S" }
    "16. Tool Gen VNPT CAMS" = @{ url = "https://github.com/tankiem/TCT_CKS/releases/latest/download/VNPT_CAMS_Plugin_Setup.exe"; type = "exe"; silent = "/S" }
}

# ===== FORM =====
$form = New-Object Windows.Forms.Form
$form.Text = "Tool Setup Tong Hop"
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# ===== CHECKBOX =====
$checkboxes = @{}
$x = 20
$y = 20
$colCount = 0

# Tự động chia đều 2 cột
$itemsPerCol = [math]::Ceiling($TOOLS.Count / 2)

foreach ($name in $TOOLS.Keys) {
    $cb = New-Object Windows.Forms.CheckBox
    $cb.Text = $name
    $cb.Location = "$x,$y"
    $cb.AutoSize = $true
    $form.Controls.Add($cb)
    $checkboxes[$name] = $cb
    
    $y += 30
    $colCount++

    if ($colCount -ge $itemsPerCol) {
        $x = 320
        $y = 20
        $colCount = 0
    }
}

# Tự động tính tọa độ Y cho nút bấm và log để không bị đè
$bottomY = ($itemsPerCol * 30) + 30

# ===== BUTTON =====
$btn = New-Object Windows.Forms.Button
$btn.Text = "Cai dat cac muc da chon"
$btn.Location = New-Object System.Drawing.Point(20, $bottomY)
$btn.Size = "250,35"
$form.Controls.Add($btn)

# ===== LOG =====
$logY = $bottomY + 45
$logBox = New-Object Windows.Forms.TextBox
$logBox.Multiline = $true
$logBox.ScrollBars = "Vertical"
$logBox.Location = New-Object System.Drawing.Point(20, $logY)
$logBox.Size = "600, 250"
$logBox.Font = "Consolas,9"
$form.Controls.Add($logBox)

# Resize form khớp với nội dung
$form.ClientSize = New-Object System.Drawing.Size(640, ($logY + 270))

function Log($msg) {
    $logBox.AppendText("$msg`r`n")
    # Cuộn xuống dòng cuối cùng
    $logBox.SelectionStart = $logBox.Text.Length
    $logBox.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

# ===== INSTALL FUNCTION =====
function Install-Tool($name, $cfg) {
    # Dùng GUID tạo tên file độc nhất, tránh lỗi trùng lặp / locked file
    $uniqueId = [guid]::NewGuid().ToString().Substring(0,8)
    $file = "$env:TEMP\setup_$uniqueId.$($cfg.type)"
    $outFolder = "$env:TEMP\out_$uniqueId"

    try {
        Log("==== $name ====")
        Log("Downloading...")
        Invoke-WebRequest $cfg.url -OutFile $file -UseBasicParsing -ErrorAction Stop

        if ($cfg.type -eq "zip") {
            Log("Extracting...")
            Expand-Archive $file -DestinationPath $outFolder -Force -ErrorAction Stop

            $exe = Get-ChildItem $outFolder -Filter *.exe -Recurse | Select-Object -First 1

            if (-not $exe) { throw "Khong tim thay file .exe trong file zip" }

            Log("Installing: $($exe.Name)")
            $process = Start-Process $exe.FullName -ArgumentList $cfg.silent -Wait -PassThru
            if ($process.ExitCode -ne 0 -and $process.ExitCode -ne $null) {
                Log("Warning: Process exited with code $($process.ExitCode)")
            }

        } elseif ($cfg.type -eq "exe") {
            Log("Installing EXE...")
            Start-Process $file -ArgumentList $cfg.silent -Wait

        } elseif ($cfg.type -eq "cmd") {
            Log("Running CMD...")
            Start-Process "cmd.exe" -ArgumentList "/c `"$file`"" -Wait
        }

        Log("Success")
    } catch {
        Log("Error: $($_.Exception.Message)")
    } finally {
        # Dọn dẹp rác (Luôn chạy kể cả khi có lỗi)
        Remove-Item $file -Force -ErrorAction SilentlyContinue
        if (Test-Path $outFolder) { Remove-Item $outFolder -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

# ===== CLICK =====
$btn.Add_Click({
    $btn.Enabled = $false
    Log("Start installing...")

    $selectedAny = $false
    foreach ($name in $TOOLS.Keys) {
        if ($checkboxes[$name].Checked) {
            $selectedAny = $true
            Install-Tool $name $TOOLS[$name]
            Log("----------------------")
        }
    }

    if (-not $selectedAny) {
        Log("Ban chua chon tool nao!")
    } else {
        Log("Done")
        [System.Windows.Forms.MessageBox]::Show("Da cai dat hoan tat!", "Thong bao", 0, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    $btn.Enabled = $true
})

$form.ShowDialog() | Out-Null
