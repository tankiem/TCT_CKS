@echo off
setlocal enabledelayedexpansion

title eSigner Auto Installer

:: ===== CONFIG =====
set "WORKDIR=%TEMP%\eSigner_auto"
set "ZIPFILE=%WORKDIR%\eSigner.zip"

:: Danh sách link fallback (ưu tiên từ trên xuống)
set URL1=https://cksvietnam.vn/download/eSigner_1.1.0_setup.zip
set URL2=https://cksvietnam.vn/download/eSigner_setup.zip

:: ===== INIT =====
if exist "%WORKDIR%" rd /s /q "%WORKDIR%"
mkdir "%WORKDIR%"

echo =====================================
echo   eSigner AUTO INSTALL
echo =====================================

:: ===== DOWNLOAD FUNCTION =====
set "DOWNLOAD_OK=0"

for %%U in ("%URL1%" "%URL2%") do (
    if "!DOWNLOAD_OK!"=="0" (
        echo.
        echo Dang thu tai: %%~U

        powershell -Command ^
        "try { ^
            Invoke-WebRequest -Uri '%%~U' -OutFile '%ZIPFILE%' -UseBasicParsing -TimeoutSec 30 ^
        } catch { exit 1 }"

        if exist "%ZIPFILE%" (
            for %%A in ("%ZIPFILE%") do set size=%%~zA

            echo Dung luong: !size! bytes

            if !size! GTR 500000 (
                echo Tai thanh cong!
                set DOWNLOAD_OK=1
            ) else (
                echo File khong hop le, thu link khac...
                del /f /q "%ZIPFILE%" >nul 2>&1
            )
        )
    )
)

if "%DOWNLOAD_OK%"=="0" (
    echo.
    echo ❌ Tat ca link deu loi. Khong tai duoc eSigner.
    pause
    exit /b 1
)

:: ===== CHECK FILE ZIP =====
echo.
echo Kiem tra file zip...

powershell -Command ^
"try { ^
    Add-Type -AssemblyName System.IO.Compression.FileSystem; ^
    [IO.Compression.ZipFile]::OpenRead('%ZIPFILE%').Dispose() ^
} catch { exit 1 }"

if errorlevel 1 (
    echo ❌ File zip bi loi (co the la HTML)
    pause
    exit /b 1
)

:: ===== EXTRACT =====
echo.
echo Dang giai nen...

powershell -Command ^
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

start /wait "" "%ExePath%" /SILENT /FORCECLOSEAPPLICATIONS

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
