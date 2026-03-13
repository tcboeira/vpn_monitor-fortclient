REM 
REM 	Nome: install.bat
REM 	Data: 13/03/2026
REM 	Versão: 1.1
REM 	Criado: Thiago Boeira
REM 			tcboeira@gmail.com
REM		
REM 	Função/Descrição: "Instalador" do VPN Monitor
REM

@echo off
setlocal

title VPN Monitor - Instalacao

echo ========================================
echo Verificando requisitos...
echo ========================================

REM ========================================
REM Verificar versao do PowerShell
REM ========================================

for /f "delims=" %%v in ('powershell -NoProfile -Command "$PSVersionTable.PSVersion.Major"') do set PSVER=%%v

if %PSVER% LSS 5 (
    echo.
    echo ERRO: PowerShell 5.1 ou superior eh necessario.
    echo Versao detectada: %PSVER%
    echo.
    pause
    exit /b
)

echo PowerShell OK (versao %PSVER%)

REM ========================================
REM Verificar FortiClient
REM ========================================

reg query "HKLM\SOFTWARE\Fortinet\FortiClient" >nul 2>&1

if errorlevel 1 (
    echo.
    echo ERRO: FortiClient nao foi encontrado neste computador.
    echo Instale o FortiClient antes de continuar.
    echo.
    pause
    exit /b
)

echo FortiClient detectado.

echo.
echo ========================================
echo Requisitos validados com sucesso
echo Iniciando instalacao...
echo ========================================

set INSTALL_DIR=C:\VPNMonitor
set STARTUP=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup

echo.
echo Criando pasta de instalacao...

if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%"
)

echo.
echo Copiando arquivos...

copy "%~dp0script\vpn-monitor_002.ps1" "%INSTALL_DIR%\" /Y >nul
copy "%~dp0script\vpn-monitor.vbs" "%INSTALL_DIR%\" /Y >nul

echo.
echo Criando atalho de inicializacao...

if exist "%STARTUP%\VPN Monitor.lnk" del "%STARTUP%\VPN Monitor.lnk"

powershell -Command ^
"$WshShell = New-Object -ComObject WScript.Shell; ^
$Shortcut = $WshShell.CreateShortcut('%STARTUP%\VPN Monitor.lnk'); ^
$Shortcut.TargetPath = '%INSTALL_DIR%\vpn-monitor.vbs'; ^
$Shortcut.Save()"

echo.
echo ========================================
echo Instalacao concluida com sucesso!
echo O monitor iniciara automaticamente com o Windows.
echo ========================================

pause

