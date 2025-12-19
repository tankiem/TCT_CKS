@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ================== CONFIG ==================
set "URL=https://drive.usercontent.google.com/download?id=1u_J3WdooG_M0CdKcLWwrrQljw5mYQRF-&export=download&authuser=0&confirm=t&uuid=795406f1-ef4a-4352-915c-e2ba56cedb98&at=ANTm3cw8Q9TtyCitUkD0dnc5lLPh%3A1766112694154"

REM App identity (used for detection). Adjust if your ARP DisplayName differs.
set "APP_MATCH=CTSigningHub"

REM Where to write logs (SCCM/Intune friendly)
set "LOGDIR=%ProgramData%\CTSigningHubDeploy"
set "LOG=%LOGDIR%\deploy.log"

REM Temp working folder (avoid Desktop in mass deployment)
set "WORKDIR=%ProgramData%\CTSigningHubDeploy\pkg"
set "ZIP=%WORKDIR%\CTSigningHub.zip"
set "EXE=%WORKDIR%\CTSigningHub.exe"

REM Optional: if installer drops a shortcut, we can attempt to resolve target later (per-user desktop may not exist under SYSTEM)
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
call :log "[1/5] Download package..."
where curl >nul 2>&1
if %errorlevel% neq 0 (
  call :log "ERROR: curl not found. Exit 10."
  exit /b 10
)

del /f /q "%ZIP%" >nul 2>&1
curl -L --fail --retry 3 --retry-delay 2 -o "%ZIP%" "%URL%"
if not exist "%ZIP%" (
  call :log "ERROR: Download failed. Exit 11."
  exit /b 11
)

REM ================== 2) EXTRACT ==================
call :log "[2/5] Extract ZIP..."
del /f /q "%EXE%" >nul 2>&1

where tar >nul 2>&1
if %errorlevel%==0 (
  tar -xf "%ZIP%" -C "%WORKDIR%"
) else (
  REM Fallback unzip only
  powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Expand-Archive -Force '%ZIP%' '%WORKDIR%'" >> "%LOG%" 2>&1
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

REM Optional launch: in mass deployment under SYSTEM, launching UI is usually pointless.
REM If you still want to trigger plugin initialization, do it only if a shortcut exists on Public Desktop.
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
del /f /q "%ZIP%" >nul 2>&1
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
REM 3010 not used as exit here; logged only (SCCM/Intune can handle separately if needed)
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

REM If app installed but no signals at all -> degraded
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
