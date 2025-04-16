@echo off
set "SCRIPT_URL=fpt_tool.ps1"
set "TEMP_PS1=%~dp0%SCRIPT_URL%"

:: Kiểm tra PowerShell
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo PowerShell không tồn tại. Vui lòng cài PowerShell 2.0 trở lên.
    pause
    exit /b
)

:: Chạy PowerShell script
powershell -ExecutionPolicy Bypass -File "%TEMP_PS1%"
pause
