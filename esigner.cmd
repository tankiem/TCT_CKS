@echo off
setlocal enabledelayedexpansion

:: ===== CONFIG =====
set "WORKDIR=%TEMP%\esigner_setup"
set "ZIPFILE=%WORKDIR%\esigner.zip"
set "DownloadUrl=https://drive.usercontent.google.com/download?id=15Y-Up7vdIjOnVjdW0akdYjUDTs_ZPYIW&export=download&authuser=0&confirm=t&uuid=aa0c6cc3-982e-49d8-8af0-4c97f3dcfc2f&at=AEz70l7kwAuZPqxpOM0PWB4ZzxVd:1741482999890"

:: ===== TAO THU MUC TAM =====
if not exist "%WORKDIR%" mkdir "%WORKDIR%"

:: ===== DOWNLOAD =====
echo Dang tai tep...
curl -L -# "%DownloadUrl%" -o "%ZIPFILE%"

if not exist "%ZIPFILE%" (
    echo Khong the tai tep.
    pause
    exit /b 1
)

echo Tai thanh cong!

:: ===== GIAI NEN =====
echo Dang giai nen...
powershell -Command "Expand-Archive -Path '%ZIPFILE%' -DestinationPath '%WORKDIR%' -Force"

if errorlevel 1 (
    echo Khong the giai nen.
    pause
    exit /b 1
)

:: ===== TIM FILE EXE =====
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
echo Tim thay: %ExePath%
echo Dang cai dat tool ky thue...

start /wait "" "%ExePath%" /SILENT /FORCECLOSEAPPLICATIONS

if errorlevel 1 (
    echo Cai dat that bai.
    pause
    exit /b 1
)

echo Da cai xong tool ky thue eSigner!

:: ===== CLEAN =====
echo Dang xoa file cai dat...
del /f /q "%ZIPFILE%" >nul 2>&1
del /f /q "%ExePath%" >nul 2>&1

:: Xoa ca thu muc tam
rd /s /q "%WORKDIR%" >nul 2>&1

echo Da don dep file tam.

endlocal
pause
