@echo off
setlocal

set "DesktopPath=%UserProfile%\Desktop"
set "ZipFilePath=%DesktopPath%\FPT_Installer.zip"
set "ExtractPath=%DesktopPath%\"
set "DownloadUrl=https://drive.usercontent.google.com/download?id=1F9pQy1Lv6Jq4zDnwzp8mB1Au6gSM1XLU&export=download&authuser=1&confirm=t&uuid=ed60bb2c-9436-4ea9-9ecc-b53d1977ea10&at=AEz70l7-z2bzrTbQrGoTaZ0gjm7L:1741399826501"

echo Dang tai tep...
curl "%DownloadUrl%" --output "%ZipFilePath%"

if errorlevel 1 (
    echo Khong the tai tep.
    pause
    exit /b 1
)

echo Dang giai nen...
powershell -Command "Expand-Archive -Path '%ZipFilePath%' -DestinationPath '%ExtractPath%' -Force"

if errorlevel 1 (
    echo Khong the giai nen.
    pause
    exit /b 1
)

echo Dang cai dat Tool FPT...
for /r "%ExtractPath%" %%i in (FPT_Installer.exe) do (
    set "ExePath=%%i" 
    goto :run 
) 


echo Khong tim thay chuong trinh cai dat.
pause
exit /b 1

:run
"%ExePath%" /q
echo Da cai xong tool FPT.

echo Dang xoa file cai dat...
del "%ZipFilePath%"

if errorlevel 1 (
    echo Khong the xoa file...
    pause
    exit /b 1
)

echo Da xoa file cai dat.

endlocal
pause