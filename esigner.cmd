@echo off
setlocal enabledelayedexpansion

set "WORKDIR=%TEMP%\eSigner_1.1.0_setup"
set "ZIPFILE=%WORKDIR%\eSigner_1.1.0_setup.zip"
set "DownloadUrl=https://cksvietnam.vn/download/eSigner_1.1.0_setup.zip"

if not exist "%WORKDIR%" mkdir "%WORKDIR%"

echo Dang tai tep...
curl -L -# "%DownloadUrl%" -o "%ZIPFILE%"

if not exist "%ZIPFILE%" (
    echo Khong the tai tep.
    pause
    exit /b 1
)

:: Check dung luong file
for %%A in ("%ZIPFILE%") do set size=%%~zA

if !size! LSS 100000 (
    echo File tai ve khong hop le (co the la HTML tu Google Drive)
    pause
    exit /b 1
)

echo Tai thanh cong

echo Dang giai nen...
powershell -Command "Expand-Archive -Path '%ZIPFILE%' -DestinationPath '%WORKDIR%' -Force"

echo Dang tim file cai dat...
set "ExePath="

for /r "%WORKDIR%" %%i in (eSigner*.exe) do (
    set "ExePath=%%i"
    goto run
)

echo Khong tim thay chuong trinh cai dat.
pause
exit /b 1

:run
echo Dang cai dat eSigner...
start /wait "" "%ExePath%" /SILENT /FORCECLOSEAPPLICATIONS

echo Cai dat xong!

del /f /q "%ZIPFILE%" >nul 2>&1
rd /s /q "%WORKDIR%" >nul 2>&1

echo Da don dep file tam.

endlocal
pause
