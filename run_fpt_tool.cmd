@echo off
set "SCRIPT_URL=https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/main/fpt_tool.ps1"
set "TEMP_PS1=%TEMP%\fpt_tool_online.ps1"

:: Kiểm tra PowerShell
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo PowerShell không tồn tại. Cài PowerShell để tiếp tục.
    pause
    exit /b
)

:: Kiểm tra xem script đã được chạy dưới quyền admin chưa
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Chay lai script voi quyen admin...
    :: Dùng PowerShell để khởi chạy lại script dưới quyền admin
    powershell -Command "Start-Process cmd.exe -ArgumentList '/c %~dp0run_fpt_tool_with_admin.cmd' -Verb RunAs"
    exit
)

:: Nếu đã có quyền admin, tải script từ GitHub và chạy
echo Dang tai script tu GitHub...
powershell -Command "Invoke-WebRequest -Uri '%SCRIPT_URL%' -OutFile '%TEMP_PS1%'"

:: Kiểm tra và chạy
if exist "%TEMP_PS1%" (
    powershell -ExecutionPolicy Bypass -File "%TEMP_PS1%"
) else (
    echo Khong tai duoc script. Kiem tra mang hoac link sai.
)

pause
