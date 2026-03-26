@echo off
setlocal enabledelayedexpansion

set WORKDIR=%USERPROFILE%\Desktop\eSigner_setup
set ZIPFILE=%WORKDIR%\eSigner.zip
set URL=https://cksvietnam.vn/download/eSigner_1.1.0_setup.zip

if exist "%WORKDIR%" rd /s /q "%WORKDIR%"
mkdir "%WORKDIR%"

echo =====================================
echo eSigner AUTO INSTALL
echo =====================================
echo Thu muc: %WORKDIR%
echo.

echo Dang tai file...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$wc=New-Object System.Net.WebClient;$wc.DownloadFile('%URL%','%ZIPFILE%')"

if not exist "%ZIPFILE%" (
 echo Loi: khong tai duoc file
 pause
 exit /b 1
)

for %%A in ("%ZIPFILE%") do set size=%%~zA
echo Size: !size!

if !size! LSS 500000 (
 echo File loi (co the la HTML)
 pause
 exit /b 1
)

echo Dang giai nen...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%ZIPFILE%' -DestinationPath '%WORKDIR%' -Force"

set ExePath=

for /r "%WORKDIR%" %%i in (*setup*.exe) do (
 set ExePath=%%i
 goto run
)

for /r "%WORKDIR%" %%i in (*.exe) do (
 set ExePath=%%i
 goto run
)

echo Khong tim thay file setup
pause
exit /b 1

:run
echo Tim thay: %ExePath%
echo Dang cai dat...

start /wait "" "%ExePath%" /SILENT

echo Hoan tat!
pause
endlocal
