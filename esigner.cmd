@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

title eSigner Auto Installer

:: ===== CONFIG =====
set "WORKDIR=%USERPROFILE%\Desktop\eSigner_setup"
set "ZIPFILE=%WORKDIR%\eSigner.zip"
set "URL=https://cksvietnam.vn/download/eSigner_1.1.0_setup.zip"

:: ===== INIT =====
if exist "%WORKDIR%" rd /s /q "%WORKDIR%"
mkdir "%WORKDIR%"

echo =====================================
echo   eSigner AUTO INSTALL
echo =====================================

echo.
echo Thu muc tai file: %WORKDIR%
echo File zip: %ZIPFILE%

:: ===== DOWNLOAD =====
echo.
echo Dang tai file...

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$wc = New-Object System.Net.WebClient; $wc.DownloadFile('%URL%', '%ZIPFILE%')"

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

:: ===== FIND SETUP EXE (QUAN TRONG) =====
echo.
echo Dang tim file cai dat...

set "ExePath="

:: Ưu tiên file có chữ setup
for /r "%WORKDIR%" %%i in (*setup*.exe) do (
    set "ExePath=%%i"
    goto found
)

:: nếu không có thì fallback
for /r "%WORKDIR%" %%i in (*.exe) do (
    set "ExePath=%%i"
    goto found
)

:found
if not defined ExePath (
    echo ❌ Khong tim thay file cai dat
    pause
    exit /b 1
)

echo Tim thay file: %ExePath%

:: ===== INSTALL =====
echo.
echo Dang cai dat silent...

start /wait "" "%ExePath%" /SILENT

if errorlevel 1 (
    echo ❌ Cai dat that bai
    pause
    exit /b 1
)

:: ===== DONE =====
echo.
echo ✅ CAI DAT HOAN TAT!

echo.
echo File da tai va giai nen tai:
echo %WORKDIR%

pause
endlocal
