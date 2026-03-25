@echo off
setlocal enabledelayedexpansion

set "WORKDIR=%TEMP%\eSigner_setup"
set "ZIPFILE=%WORKDIR%\eSigner.zip"
set "DownloadUrl=https://cksvietnam.vn/download/eSigner_1.1.0_setup.zip"

if not exist "%WORKDIR%" mkdir "%WORKDIR%"

echo ==== DANG TAI FILE ====

powershell -Command ^
"try { ^
    Invoke-WebRequest -Uri '%DownloadUrl%' -OutFile '%ZIPFILE%' -UseBasicParsing ^
} catch { exit 1 }"

if not exist "%ZIPFILE%" (
    echo Loi: Khong tai duoc file
    pause
    exit /b 1
)

for %%A in ("%ZIPFILE%") do set size=%%~zA
echo Dung luong: !size! bytes

if !size! LSS 500000 (
    echo Loi: File khong hop le
    pause
    exit /b 1
)

echo ==== GIAI NEN ====

powershell -Command ^
"Expand-Archive -Path '%ZIPFILE%' -DestinationPath '%WORKDIR%' -Force"

echo ==== TIM FILE CAI DAT ====

set "ExePath="

for /r "%WORKDIR%" %%i in (*.exe) do (
    echo Tim thay: %%i
    set "ExePath=%%i"
    goto run
)

echo Khong tim thay file exe
pause
exit /b 1

:run
echo ==== CAI DAT SILENT ====

:: thử nhiều kiểu silent phổ biến
start /wait "" "%ExePath%" /S || ^
start /wait "" "%ExePath%" /silent || ^
start /wait "" "%ExePath%" /VERYSILENT

echo ==== DONE ====

del /f /q "%ZIPFILE%" >nul 2>&1
rd /s /q "%WORKDIR%" >nul 2>&1

echo Da don dep
pause
endlocal
