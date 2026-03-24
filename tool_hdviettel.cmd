@echo off
setlocal

set "DesktopPath=%UserProfile%\Desktop"
set "ExeFilePath=%DesktopPath%\viettel-tool-ki-so-1.0.1.exe"
set "DownloadUrl=https://cksvietnam.vn/download/viettel-tool-ki-so-1.0.1.exe"

echo Dang tai file cai dat...
curl "%DownloadUrl%" --output "%ExeFilePath%"

if errorlevel 1 (
    echo Khong the tai tep.
    pause
    exit /b 1
)

echo Dang cai dat Tool ky hoa don Viettel...
"%ExeFilePath%" /q

if errorlevel 1 (
    echo Cài đặt thất bại.
    pause
    exit /b 1
)

echo Da cai dat thanh cong!

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
