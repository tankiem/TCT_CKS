@echo off
:menu
echo.
echo Chon script de chay:
echo.
echo 1. Cai dat Foxit Reader
echo 2. Cai dat Java 8.121
echo 3. Cai dat Java 7.3
echo 4. Exit
echo.
choice /c 1234
if errorlevel 4 goto :exit
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
:exit
exit