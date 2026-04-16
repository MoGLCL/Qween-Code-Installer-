@echo off
title Qwen Smart Installer - MoGlitch
setlocal enabledelayedexpansion

REM =========================
REM COLORS (ANSI)
REM =========================
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

set "C_RESET=%ESC%[0m"
set "C_TITLE=%ESC%[96m"
set "C_INFO=%ESC%[97m"
set "C_OK=%ESC%[92m"
set "C_WARN=%ESC%[93m"
set "C_ERR=%ESC%[91m"

cls

echo %C_TITLE%
echo ==================================================
echo             QWEN SMART INSTALLER
echo ==================================================
echo %C_RESET%

echo %C_INFO% Author  : MoGlitch
echo GitHub  : https://github.com/MoGLCL/Qween-Code-Installer
echo Discord : https://discord.gg/pgkwfRZGZH
echo ==================================================
echo %C_RESET%

REM =========================
REM FAST NODE CHECK (NO DELAY)
REM =========================
echo %C_INFO%[*] Checking Node.js...%C_RESET%

node -v >nul 2>&1

if %ERRORLEVEL% EQU 0 (
    for /f "delims=" %%i in ('where node') do set "NODE_PATH=%%~dpi"
    echo %C_OK%[+] Node.js detected ✔%C_RESET%
) else (
    echo %C_WARN%[!] Node.js not found%C_RESET%
    set "NODE_PATH="
)

REM =========================
REM INSTALL NODE ONLY IF MISSING
REM =========================
if "%NODE_PATH%"=="" (
    echo.
    echo %C_INFO%[*] Select folder for Node.js installation%C_RESET%

    for /f "delims=" %%i in ('powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $f=New-Object System.Windows.Forms.FolderBrowserDialog; if($f.ShowDialog() -eq \"OK\"){ $f.SelectedPath }"') do set "INSTALL_DIR=%%i"

    if "%INSTALL_DIR%"=="" (
        echo %C_ERR%[X] No folder selected%C_RESET%
        pause
        exit /b 1
    )

    echo %C_OK%[+] Selected: %INSTALL_DIR%%C_RESET%

    set "TEMP_DIR=%TEMP%\qwen-node"
    if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

    set "NODE_VERSION=20.18.1"
    set "ARCH=x64"
    set "NODE_URL=https://nodejs.org/dist/v!NODE_VERSION!/node-v!NODE_VERSION!-!ARCH!.msi"
    set "NODE_INSTALLER=%TEMP_DIR%\node.msi"

    echo.
    echo %C_INFO%[*] Downloading Node.js...%C_RESET%

    powershell -Command "Invoke-WebRequest -Uri '!NODE_URL!' -OutFile '!NODE_INSTALLER!'"

    echo.
    echo %C_WARN%Install Node.js in:%C_RESET%
    echo %INSTALL_DIR%\nodejs
    pause

    start "" "!NODE_INSTALLER!"

    echo.
    echo %C_INFO%Press any key after installation...%C_RESET%
    pause

    set "NODE_PATH=%INSTALL_DIR%\nodejs\"
)

REM =========================
REM FAST PROGRESS
REM =========================
echo.
call :progress "Initializing" 10

REM =========================
REM NPM SETUP
REM =========================
if exist "!NODE_PATH!\npm.cmd" (
    set "NPM_CMD=!NODE_PATH!\npm.cmd"
) else (
    set "NPM_CMD=npm"
)

REM =========================
REM CHOOSE QWEN FOLDER
REM =========================
echo.
echo %C_INFO%[*] Choose Qwen install folder%C_RESET%

for /f "delims=" %%i in ('powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $f=New-Object System.Windows.Forms.FolderBrowserDialog; if($f.ShowDialog() -eq \"OK\"){ $f.SelectedPath }"') do set "QWEN_DIR=%%i"

if "%QWEN_DIR%"=="" (
    echo %C_ERR%[X] No folder selected%C_RESET%
    pause
    exit /b 1
)

set "NPM_GLOBAL=%QWEN_DIR%\qwen-global"
if not exist "!NPM_GLOBAL!" mkdir "!NPM_GLOBAL!"

echo %C_OK%[+] Qwen path: %NPM_GLOBAL%%C_RESET%

call "!NPM_CMD!" config set prefix "!NPM_GLOBAL!" >nul

REM =========================
REM INSTALL QWEN (FAST OUTPUT)
REM =========================
echo.
echo %C_INFO%[*] Installing Qwen Code...%C_RESET%

call "!NPM_CMD!" install -g @qwen-code/qwen-code@latest --registry https://registry.npmmirror.com

if %ERRORLEVEL% NEQ 0 (
    echo %C_ERR%[X] Installation failed%C_RESET%
    pause
    exit /b 1
)

REM =========================
REM PATH UPDATE
REM =========================
set "QWEN_BIN=%NPM_GLOBAL%"
setx PATH "%PATH%;%QWEN_BIN%" >nul

echo.
echo %C_TITLE%==================================================%C_RESET%
echo %C_OK%          INSTALLATION COMPLETE ✔%C_RESET%
echo %C_TITLE%==================================================%C_RESET%

echo.
echo %C_INFO%Qwen installed in:%C_RESET%
echo %QWEN_BIN%
echo.

echo %C_OK%Run command: qwen%C_RESET%
echo.

pause
exit /b 0

REM =========================
REM FAST PROGRESS FUNCTION
REM =========================
:progress
set "msg=%~1"
set "max=%~2"
set /a i=0

:loop
set /a i+=1
set /a p=(i*100)/max

<nul set /p=%C_INFO%%msg% [ %C_RESET%
for /l %%a in (1,1,!i!) do <nul set /p=#
for /l %%a in (!i!,1,%max%) do <nul set /p=.
echo %C_INFO% ] !p!%%%C_RESET%

timeout /t 0 >nul
if !i! LSS %max% goto loop

exit /b