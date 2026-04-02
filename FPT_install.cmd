@echo off
setlocal enabledelayedexpansion

:: ==============================
:: CONFIG
:: ==============================
set "DesktopPath=%UserProfile%\Desktop"
set "ZipFilePath=%DesktopPath%\FPT_Installer.zip"
set "ExtractPath=%DesktopPath%\FPT_Extract"

:: Link latest (khuyên dùng)
set "DownloadUrl=https://github.com/tankiem/TCT_CKS/releases/latest/download/FPT_Installer.zip"

:: ==============================
:: DOWNLOAD
:: ==============================
echo.
echo =====================================
echo [1/4] DOWNLOADING...
echo =====================================

set RETRY=3
set COUNT=0

:download_retry
set /a COUNT+=1
echo [+] Attempt !COUNT!...

curl -L --fail --retry 3 --retry-delay 2 ^
--connect-timeout 15 --speed-time 15 --speed-limit 1000 ^
-o "%ZipFilePath%" "%DownloadUrl%"

if exist "%ZipFilePath%" (
    echo [+] Download success!
) else (
    if !COUNT! lss %RETRY% (
        echo [!] Retry download...
        timeout /t 2 >nul
        goto download_retry
    ) else (
        echo [X] Download FAILED!
        pause
        exit /b 1
    )
)

:: ==============================
:: VERIFY FILE
:: ==============================
for %%A in ("%ZipFilePath%") do set size=%%~zA
if !size! LSS 100000 (
    echo [X] File too small -> download error!
    del "%ZipFilePath%" >nul 2>&1
    pause
    exit /b 1
)

:: ==============================
:: EXTRACT
:: ==============================
echo.
echo =====================================
echo [2/4] EXTRACTING...
echo =====================================

if exist "%ExtractPath%" rmdir /s /q "%ExtractPath%"
mkdir "%ExtractPath%"

powershell -NoProfile -Command ^
"try { Expand-Archive -Path '%ZipFilePath%' -DestinationPath '%ExtractPath%' -Force } catch { exit 1 }"

if errorlevel 1 (
    echo [X] Extract FAILED!
    pause
    exit /b 1
)

echo [+] Extract success!

:: ==============================
:: FIND INSTALLER
:: ==============================
echo.
echo =====================================
echo [3/4] FINDING INSTALLER...
echo =====================================

set "ExePath="

:: lấy file exe mới nhất
for /f "delims=" %%i in ('dir "%ExtractPath%\*.exe" /b /a-d /o-d 2^>nul') do (
    set "ExePath=%ExtractPath%\%%i"
    goto found
)

:found
if not defined ExePath (
    echo [X] Installer not found!
    pause
    goto cleanup
)

echo [+] Found: !ExePath!

:: ==============================
:: INSTALL
:: ==============================
echo.
echo =====================================
echo [4/4] INSTALLING...
echo =====================================

start "" /wait "!ExePath!" /q

if errorlevel 1 (
    echo [!] Install returned error, trying fallback...
    start "" /wait "!ExePath!" /silent /verysilent
)

echo [+] Install completed!

:: ==============================
:: CLEANUP
:: ==============================
:cleanup
echo.
echo =====================================
echo CLEANING...
echo =====================================

if exist "%ZipFilePath%" del /f /q "%ZipFilePath%"
if exist "%ExtractPath%" rmdir /s /q "%ExtractPath%"

echo [+] Done!
pause
endlocal
