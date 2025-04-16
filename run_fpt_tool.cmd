@echo off
set "SCRIPT_URL=https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/main/fpt_tool.ps1"
set "TEMP_PS1=%TEMP%pt_tool_online.ps1"

:: Kiểm tra PowerShell
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo PowerShell không tồn tại. Cài PowerShell để tiếp tục.
    pause
    exit /b
)

:: Tải file PowerShell từ GitHub
echo Dang tai script tu GitHub...
powershell -Command "Invoke-WebRequest -Uri '%SCRIPT_URL%' -OutFile '%TEMP_PS1%'"

:: Kiểm tra và chạy
if exist "%TEMP_PS1%" (
    powershell -ExecutionPolicy Bypass -File "%TEMP_PS1%"
) else (
    echo Khong tai duoc script. Kiem tra mang hoac link sai.
)

pause
