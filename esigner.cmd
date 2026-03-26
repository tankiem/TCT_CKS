@echo off
setlocal enabledelayedexpansion

set WORKDIR=%USERPROFILE%\Desktop\eSigner_setup
set ZIPFILE=%WORKDIR%\eSigner.zip
set URL=https://cksvietnam.vn/download/eSigner_1.1.0_setup.zip

if exist "%WORKDIR%" rd /s /q "%WORKDIR%"
mkdir "%WORKDIR%"

echo ==== eSigner AUTO INSTALL ====

echo Dang tai file...
powershell -Command "$wc=New-Object Net.WebClient;$wc.DownloadFile('%URL%','%ZIPFILE%')"

if not exist "%ZIPFILE%" (
 echo Loi tai file
 pause
 exit /b 1
)

echo Dang giai nen...
powershell -Command "Expand-Archive '%ZIPFILE%' '%WORKDIR%' -Force"

echo Dang tim file cai dat...

set MaxSize=0
set ExePath=

for /r "%WORKDIR%" %%i in (*.exe) do (
 set size=%%~zi
 if !size! GTR !MaxSize! (
  set MaxSize=!size!
  set ExePath=%%i
 )
)

if not defined ExePath (
 echo Khong tim thay exe
 pause
 exit /b 1
)

echo File duoc chon: %ExePath%
echo Size: %MaxSize%

echo Dang cai dat...

start /wait "" "%ExePath%" /SILENT

echo Hoan tat!
pause
