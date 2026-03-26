@echo off

set WORKDIR=%TEMP%\eSigner
set ZIPFILE=%WORKDIR%\eSigner.zip
set URL=https://cksvietnam.vn/download/eSigner_1.1.0_setup.zip

rd /s /q "%WORKDIR%" >nul 2>&1
mkdir "%WORKDIR%"

echo ==== eSigner AUTO INSTALL ====

echo Dang tai...
powershell -Command "(New-Object Net.WebClient).DownloadFile('%URL%','%ZIPFILE%')"

if not exist "%ZIPFILE%" echo Loi tai file & pause & exit /b

echo Dang giai nen...
powershell -Command "Expand-Archive '%ZIPFILE%' '%WORKDIR%' -Force"

echo Dang tim file setup...

for /r "%WORKDIR%" %%i in (*.exe) do call :check "%%i"

if not defined ExePath (
 echo Khong tim thay file exe
 pause
 exit /b
)

echo Chay file: %ExePath%
start /wait "" "%ExePath%" /SILENT

echo Hoan tat!
pause
exit /b

:check
set file=%~1
for %%A in ("%file%") do set size=%%~zA
if not defined MaxSize set MaxSize=0
if %size% GTR %MaxSize% (
 set MaxSize=%size%
 set ExePath=%file%
)
exit /b
