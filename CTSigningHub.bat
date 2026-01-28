@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ================== CONFIG ==================
set "URL=https://download803.fshare.vn/dl/YE2-GeXdZYqU4DPzzZ4OMsMLgWO4R-fMqv+6thUzy121qo5E+KSkZEQ6fpRsVKR07TaEKuiLu3HJ9xmT/CTSigningHub_signed%20%281%29.rar"

REM App identity (used for detection). Adjust if your ARP DisplayName differs.
set "APP_MATCH=CTSigningHub"

REM Where to write logs (SCCM/Intune friendly)
set "LOGDIR=%ProgramData%\CTSigningHubDeploy"
set "LOG=%LOGDIR%\deploy.log"

REM Temp working folder (avoid Desktop in mass deployment)
set "WORKDIR=%ProgramData%\CTSigningHubDeploy\pkg"
set "RAR=%WORKDIR%\CTSigningHub.rar"
set "EXE=%WORKDIR%\CTSigningHub.exe"

REM Optional: if installer drops a shortcut, we can attempt to resolve target later
set "LNK_PUBLIC=%Public%\Desktop\CTSigningHub.lnk"

REM ================== INIT ==================
if not exist "%LOGDIR%" mkdir "%LOGDIR%" >nul 2>&1
if not exist "%WORKDIR%" mkdir "%WORKDIR%" >nul 2>&1

call :log "==== START Deploy_CTSigningHub ===="
call :log "Running as: %USERNAME%   Computer: %COMPUTERNAME%"

REM ================== 0) DETECT ALREADY INSTALLED ==================
call :detect_installed
if "%INSTALLED%"=="1" (
  call :log "App already installed. Skipping install."
  call :health_check
  call :log "==== END (already installed) ExitCode=%EXITCODE% ===="
  exit /b %EXITCODE%
)

REM ================== 1) DOWNLOAD ==================
call :log "[1/5] Download package (RAR)..."
where curl >nul 2>&1
if %errorlevel% neq 0 (
  call :log "ERROR: curl not found. Exit 10."
  exit /b 10
)

del /f /q "%RAR%" >nul 2>&1
curl -L --fail --retry 3 --retry-delay 2 -o "%RAR%" "%URL%"
if not exist "%RAR%" (
  call :log "ERROR: Download failed. Exit 11."
  exit /b 11
)

REM ================== 2) EXTRACT (RAR) ==================
call :log "[2/5] Extract RAR..."
del /f /q "%EXE%" >nul 2>&1

REM Clean old extracted contents (optional, but helpful)
REM WARNING: This deletes the workdir contents; comment out if you need to keep other files.
for %%F in ("%WORKDIR%\*") do (
  if /I not "%%~fF"=="%RAR%" del /f /q "%%~fF" >nul 2>&1
)

call :find_extractor
if not defined EXTRACTOR (
  call :log "ERROR: No RAR extractor found (7z.exe or unrar.exe). Install 7-Zip or WinRAR. Exit 13."
  exit /b 13
)

call :log "Using extractor: %EXTRACTOR%"
call :extract_rar "%RAR%" "%WORKDIR%"
if %errorlevel% neq 0 (
  call :log "ERROR: Extract failed. Exit 14."
  exit /b 14
)

if not exist "%EXE%" (
  call :log "ERROR: CTSigningHub.exe not found after extract at %EXE%. Exit 12."
  exit /b 12
)

REM ================== 3) INSTALL SILENT ==================
call :log "[3/5] Install silent: /qn"
start "" /wait "%EXE%" /qn
set "RC=%errorlevel%"
call :log "Installer exit code: %RC%"

REM Normalize common codes: 0=OK, 3010=OK (restart required)
if "%RC%"=="0" (
  set "INST_RC=0"
) else if "%RC%"=="3010" (
  set "INST_RC=0"
  set "REBOOT_REQUIRED=1"
) else (
  set "INST_RC=%RC%"
)

REM ================== 4) POST-DETECT ==================
call :log "[4/5] Post-install detection..."
call :detect_installed
if "%INSTALLED%"=="0" (
  call :log "ERROR: Install finished but app not detected. Exit 20."
  call :cleanup
  exit /b 20
)

REM ================== 5) HEALTH CHECK + (OPTIONAL) LAUNCH ==================
call :log "[5/5] Health check..."
call :health_check

if exist "%LNK_PUBLIC%" (
  call :log "Public desktop shortcut found. Attempt init launch (no UI guarantee)."
  call :launch_from_lnk "%LNK_PUBLIC%"
) else (
  call :log "No public desktop shortcut. Skip launch (SYSTEM context)."
)

call :cleanup

if defined REBOOT_REQUIRED (
  call :log "Reboot required flagged (3010)."
)

call :log "==== END ExitCode=%EXITCODE% ===="
exit /b %EXITCODE%

REM ================== FUNCTIONS ==================

:log
echo %DATE% %TIME% - %~1>> "%LOG%"
exit /b 0

:cleanup
del /f /q "%RAR%" >nul 2>&1
del /f /q "%EXE%" >nul 2>&1
exit /b 0

:detect_installed
set "INSTALLED=0"

REM Detect via Uninstall keys (HKLM 64/32)
for %%K in (
  "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall"
  "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
) do (
  for /f "tokens=*" %%A in ('reg query %%K 2^>nul ^| findstr /i /r "\\{.*\\}$"') do (
    for /f "tokens=2,*" %%B in ('reg query "%%A" /v "DisplayName" 2^>nul ^| findstr /i "DisplayName"') do (
      echo %%C | findstr /i "%APP_MATCH%" >nul && set "INSTALLED=1"
    )
  )
)

REM Also allow direct vendor key if exists (optional)
reg query "HKLM\Software\CTSigningHub" >nul 2>&1 && set "INSTALLED=1"
reg query "HKCU\Software\CTSigningHub" >nul 2>&1 && set "INSTALLED=1"

exit /b 0

:health_check
REM Exit code policy:
REM 0  = installed + passed basic checks
REM 30 = installed but basic signals missing (needs investigation)
set "EXITCODE=0"
set "OKSIG=0"

REM Signal 1: registry key
reg query "HKLM\Software\CTSigningHub" >nul 2>&1 && set /a OKSIG+=1
reg query "HKCU\Software\CTSigningHub" >nul 2>&1 && set /a OKSIG+=1

REM Signal 2: related service (best-effort)
sc query | findstr /i "CTSigning" >nul && set /a OKSIG+=1

REM Signal 3: ctfmon host running (only meaningful in user session, may be absent under SYSTEM)
tasklist | findstr /i "ctfmon.exe" >nul && set /a OKSIG+=1

call :log "Health signals count: !OKSIG! (reg/service/ctfmon)"

if "!OKSIG!"=="0" set "EXITCODE=30"
exit /b 0

:launch_from_lnk
REM Resolve TargetPath from .lnk with CMD+VBS then start it
set "LNKFILE=%~1"
set "VBS=%TEMP%\ctsignhub_resolve_lnk.vbs"

(
  echo Set o=WScript.CreateObject("WScript.Shell")
  echo Set s=o.CreateShortcut(WScript.Arguments(0))
  echo WScript.Echo s.TargetPath
) > "%VBS%"

set "TARGET_EXE="
for /f "usebackq delims=" %%P in (`cscript //nologo "%VBS%" "%LNKFILE%"`) do set "TARGET_EXE=%%P"
del /f /q "%VBS%" >nul 2>&1

if defined TARGET_EXE (
  if exist "%TARGET_EXE%" (
    start "" "%TARGET_EXE%"
    call :log "Launch attempted: %TARGET_EXE%"
  ) else (
    call :log "Launch skipped: resolved target not found: %TARGET_EXE%"
  )
) else (
  call :log "Launch skipped: cannot resolve TargetPath from %LNKFILE%"
)
exit /b 0

:find_extractor
REM Prefer 7-Zip if available; fallback to WinRAR unrar.exe

set "EXTRACTOR="

REM 1) If 7z is in PATH
where 7z >nul 2>&1 && set "EXTRACTOR=7z"

REM 2) Common 7-Zip install paths
if not defined EXTRACTOR (
  if exist "%ProgramFiles%\7-Zip\7z.exe" set "EXTRACTOR=%ProgramFiles%\7-Zip\7z.exe"
)
if not defined EXTRACTOR (
  if exist "%ProgramFiles(x86)%\7-Zip\7z.exe" set "EXTRACTOR=%ProgramFiles(x86)%\7-Zip\7z.exe"
)

REM 3) WinRAR unrar.exe
if not defined EXTRACTOR (
  if exist "%ProgramFiles%\WinRAR\UnRAR.exe" set "EXTRACTOR=%ProgramFiles%\WinRAR\UnRAR.exe"
)
if not defined EXTRACTOR (
  if exist "%ProgramFiles(x86)%\WinRAR\UnRAR.exe" set "EXTRACTOR=%ProgramFiles(x86)%\WinRAR\UnRAR.exe"
)

exit /b 0

:extract_rar
REM Args: %1=rar file, %2=dest folder
set "RARFILE=%~1"
set "DEST=%~2"

if not exist "%DEST%" mkdir "%DEST%" >nul 2>&1

REM If extractor is "7z" or ends with 7z.exe -> use 7z syntax
echo "%EXTRACTOR%" | findstr /i "7z" >nul
if %errorlevel%==0 (
  "%EXTRACTOR%" x -y "-o%DEST%" "%RARFILE%" >> "%LOG%" 2>&1
  exit /b %errorlevel%
)

REM If extractor is UnRAR.exe -> use unrar syntax
echo "%EXTRACTOR%" | findstr /i "unrar" >nul
if %errorlevel%==0 (
  "%EXTRACTOR%" x -y "%RARFILE%" "%DEST%\" >> "%LOG%" 2>&1
  exit /b %errorlevel%
)

REM Unknown extractor
exit /b 1
