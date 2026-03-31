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
            
            # LƯU Ý: Đã bỏ tham số -Wait ở cuối lệnh này
            $p = Start-Process $exe.FullName -ArgumentList $cfg.silent -PassThru 

            # VÒNG LẶP CHỜ THÔNG MINH (Không làm đơ UI)
            while ($p -and -not $p.HasExited) {
                [System.Windows.Forms.Application]::DoEvents()
                Start-Sleep -Milliseconds 500
            }

            Start-Sleep -Seconds 2 # Chờ thêm 2 giây để hệ thống ổn định sau cài đặt
            
            # Dọn dẹp rác sau khi cài xong
            Remove-Item $outFolder -Recurse -Force -ErrorAction SilentlyContinue
            
        } else {
            Log("🚀 Đang chạy script...")
            # LƯU Ý: Đã bỏ tham số -Wait ở cuối lệnh này
            $p = Start-Process "cmd.exe" -ArgumentList "/c `"$file`"" -PassThru
            
            # VÒNG LẶP CHỜ THÔNG MINH
            while ($p -and -not $p.HasExited) {
                [System.Windows.Forms.Application]::DoEvents()
                Start-Sleep -Milliseconds 500
            }
        }

        # Dọn dẹp file tải về
        Remove-Item $file -Force -ErrorAction SilentlyContinue

        Log("✔ $name thành công!")
    }
    catch {
        Log("❌ $name lỗi: $($_.Exception.Message)")
    }
}
