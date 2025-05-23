@echo off
setlocal

set "DesktopPath=%UserProfile%\Desktop"
set "ZipFilePath=%DesktopPath%\eSigner_1.1.0_setup.zip"
set "ExtractPath=%DesktopPath%\"
set "DownloadUrl=https://drive.usercontent.google.com/download?id=15Y-Up7vdIjOnVjdW0akdYjUDTs_ZPYIW&export=download&authuser=0&confirm=t&uuid=aa0c6cc3-982e-49d8-8af0-4c97f3dcfc2f&at=AEz70l7kwAuZPqxpOM0PWB4ZzxVd:1741482999890"

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

echo Dang cai dat tool ky thue...
for /r "%ExtractPath%" %%i in (eSigner*.exe) do (
    set "ExePath=%%i" 
    goto :run 
) 


echo Khong tim thay chuong trinh cai dat.
pause
exit /b 1

:run
"%ExePath%" /SILENT /FORCECLOSEAPPLICATIONS
echo Da cai xong tool ky thue esigner.

echo Dang xoa file cai dat...
del "%ZipFilePath%"
del "%ExePath%"
if errorlevel 1 (
    echo Khong the xoa file...
    pause
    exit /b 1
)

echo Da xoa file cai dat.

endlocal
pause
