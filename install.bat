REM 
REM 	Nome: install.bat
REM 	Data Criação: 13/03/2026
REM     Ultima Revisão: 18/03/2026
REM 	Versão: 2.0
REM 	Criado: Thiago Boeira
REM 			tcboeira@gmail.com
REM		
REM 	Função/Descrição: "Instalador" do VPN Monitor
REM
REM     VERSÃO  -     DATA    - DESCRIÇÃO
REM     2.0     - 18/03/2026  - Inserido alertas e obervações de remoção de bloqueios de seguranca dos arquivos e indica uso de "Unblock-File"
REM     1.0     - 13/03/2026  - Criação
REM     


@echo off
cls
title VPN Monitor - Instalacao

echo ========================================
echo VPN Monitor - Instalador
echo ========================================
echo.

REM ========================================
REM VERIFICAR POWERSHELL
REM ========================================

echo Verificando versao do PowerShell...

    for /f "delims=" %%v in ('powershell -NoProfile -Command "$PSVersionTable.PSVersion.Major"') do set PSVER=%%v

    if not defined PSVER (
    echo ERRO: Nao foi possivel identificar a versao do PowerShell.
    pause
    exit /b
    )

    if %PSVER% LSS 5 (
    echo.
    echo ERRO: PowerShell 5.1 ou superior eh necessario.
    echo Versao detectada: %PSVER%
    echo.
    pause
    exit /b
    )

echo PowerShell OK (versao %PSVER%)
echo.

REM ========================================
REM VERIFICAR FORTICLIENT
REM ========================================

echo Verificando FortiClient...

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

REM ========================================
REM DESBLOQUEAR ARQUIVOS (SMARTSCREEN)
REM ========================================

echo Removendo bloqueios de seguranca dos arquivos...

    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Get-ChildItem '%~dp0' -Recurse | Unblock-File" >nul 2>&1

echo Arquivos desbloqueados.
echo.

REM ========================================
REM DEFINIR CAMINHOS
REM ========================================

set INSTALL_DIR=C:\VPNMonitor
set STARTUP=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup

echo Pasta de instalacao: %INSTALL_DIR%
echo.

REM ========================================
REM CRIAR PASTA
REM ========================================

echo Criando pasta de instalacao...

if not exist "%INSTALL_DIR%" (
mkdir "%INSTALL_DIR%"
)

if errorlevel 1 (
echo ERRO: Falha ao criar pasta de instalacao.
pause
exit /b
)

echo Pasta OK.
echo.

REM ========================================
REM COPIAR ARQUIVOS
REM ========================================

echo Copiando arquivos...

copy "%~dp0script\vpn-monitor_002.ps1" "%INSTALL_DIR%" /Y >nul
copy "%~dp0script\vpn-monitor.vbs" "%INSTALL_DIR%" /Y >nul

if errorlevel 1 (
echo ERRO: Falha ao copiar arquivos.
pause
exit /b
)

echo Arquivos copiados com sucesso.
echo.

REM ========================================
REM CRIAR ATALHO NA INICIALIZACAO
REM ========================================

echo Criando atalho de inicializacao...

if exist "%STARTUP%\VPN Monitor.lnk" del "%STARTUP%\VPN Monitor.lnk"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$WshShell = New-Object -ComObject WScript.Shell; ^
$Shortcut = $WshShell.CreateShortcut('%STARTUP%\VPN Monitor.lnk'); ^
$Shortcut.TargetPath = '%INSTALL_DIR%\vpn-monitor.vbs'; ^
$Shortcut.WorkingDirectory = '%INSTALL_DIR%'; ^
$Shortcut.WindowStyle = 7; ^
$Shortcut.Save()"

if errorlevel 1 (
echo ERRO: Falha ao criar atalho.
pause
exit /b
)

echo Atalho criado com sucesso.
echo.

REM ========================================
REM VALIDAR EXECUCAO
REM ========================================

echo Validando execucao do script...

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Start-Process '%INSTALL_DIR%\vpn-monitor.vbs'" >nul 2>&1

if errorlevel 1 (
echo.
echo AVISO: O Windows pode ter bloqueado o script.
echo Caso nao funcione, execute manualmente:
echo powershell Unblock-File "%INSTALL_DIR%\vpn-monitor_002.ps1"
)

echo.

REM ========================================
REM FINALIZACAO
REM ========================================

echo ========================================
echo Instalacao concluida com sucesso!
echo O VPN Monitor iniciara automaticamente com o Windows.
echo ========================================
echo.

pause
