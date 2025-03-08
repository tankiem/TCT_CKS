@echo off
:menu
echo.
echo Chon script de chay:
echo.
echo 1. Cai dat Foxit Reader
echo 2. Cai dat Java 8.121
echo 3. Cai dat Java 7.3
echo 4. Cai tool FPT
echo 5. Cai plugin VNPT

echo.
choice /c 12345
if errorlevel 5 goto :vnpt
if errorlevel 4 goto :fpt
if errorlevel 3 goto :java7
if errorlevel 2 goto :java8
if errorlevel 1 goto :foxit


:foxit
curl https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/main/install_foxit_reader.cmd --output temp.cmd && temp.cmd && del temp.cmd
goto :menu

:java8
curl "https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/main/install_java8.cmd" --output temp.cmd && temp.cmd && del temp.cmd
goto :menu

:java7
curl "https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/main/install_java7.cmd" --output temp.cmd && temp.cmd && del temp.cmd
goto :menu

:fpt
curl https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/main/FPT_install.cmd --output fpt.cmd && fpt.cmd && del fpt.cmd
goto :menu

:vnpt
curl https://raw.githubusercontent.com/tankiem/TCT_CKS/refs/heads/main/vnpt_plugin --output vnpt.cmd && vnpt.cmd && del vnpt.cmd
goto :menu
:exit
exit
