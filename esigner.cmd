@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

title eSigner Auto Installer

:: ===== CONFIG =====
set "WORKDIR=%TEMP%\eSigner_auto"
set "ZIPFILE=%WORKDIR%\eSigner.zip"
set "DownloadUrl=https://cksvietnam.vn/download/eSigner_1.1.0_setup.zip"

:: ===== INIT =====
if exist "%WORKDIR%" rd /s /q "%WORKDIR%"
mkdir "%WORKDIR%"

echo =====================================
echo   eSigner AUTO INSTALL
echo =====================================

:: ===== DOWNLOAD =====
echo.
echo Dang tai file...

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Invoke-WebRequest -Uri '%DownloadUrl%' -OutFile '%ZIPFILE%'"

if not exist "%ZIPFILE%" (
    echo ❌ Loi: Khong tai duoc file
    pause
    exit /b 1
)

for %%A in ("%ZIPFILE%") do set size=%%~zA
echo Dung luong: !size! bytes

if !size! LSS 500000 (
    echo ❌ File khong hop le
    pause
    exit /b 1
)

:: ===== EXTRACT =====
echo.
echo Dang giai nen...

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Expand-Archive -Path '%ZIPFILE%' -DestinationPath '%WORKDIR%' -Force"

:: ===== FIND EXE =====
echo.
echo Dang tim file cai dat...

set "ExePath="

for /r "%WORKDIR%" %%i in (*.exe) do (
    set "ExePath=%%i"
    echo Tim thay: %%i
    goto install
)

echo ❌ Khong tim thay file exe
pause
exit /b 1

:: ===== INSTALL =====
:install
echo.
echo Dang cai dat silent...

start /wait "" "%ExePath%" /SILENT

if errorlevel 1 (
    echo ❌ Cai dat that bai
    pause
    exit /b 1
)

:: ===== CLEAN =====
echo.
echo Don dep file tam...

del /f /q "%ZIPFILE%" >nul 2>&1
rd /s /q "%WORKDIR%" >nul 2>&1

echo.
echo ✅ CAI DAT HOAN TAT!
pause
endlocal
