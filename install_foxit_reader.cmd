@echo off
setlocal

set "DesktopPath=%UserProfile%\Desktop"
set "ExeFilePath=%DesktopPath%\FoxitPDFReader1212_enu_Setup_Prom.exe"
set "DownloadUrl=https://cksvietnam.vn/download/FoxitPDFReader1212_enu_Setup_Prom.exe"

echo Dang tai file cai dat...
curl "%DownloadUrl%" --output "%ExeFilePath%"

if errorlevel 1 (
    echo Khong the tai tep.
    pause
    exit /b 1
)

echo Dang cai dat Foxit Reader...
"%ExeFilePath%" /verysilent

if errorlevel 1 (
    echo Cai dat Foxit Reader that bai.
    pause
    exit /b 1
)

echo Foxit Reader da cai dat thanh cong!

echo Dang xoa file cai dat...
del "%ExeFilePath%"

if errorlevel 1 (
    echo Khong the xoa file...
    pause
    exit /b 1
)

echo Da xoa file cai dat.


endlocal
pause
