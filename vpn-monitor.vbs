'   Nome: vpn-monitor_002.ps1
'	Data: 05/03/2026 - 14h21
'	Versão: 1.1
'	Criado: Thiago Boeira
'			tcboeira@gmail.com
		
'	Função/Descrição:	Serve para chamada de arquivo PS1 via Inicialização automatica do Windows;


'   Versão // Data - Hora // Alteração-Descrição
'    1.1 //  06/03/2026 - 14h   // - Incremento para que possa ser usado sem a necessidade de alterar as politicas gerais de execução de script do Windows;
'    1.0 //  05/03/2026 - 10h50 // - Criação;


' Obsoletado em 06/03/2026
' Set objShell = CreateObject("WScript.Shell")
' objShell.Run "powershell -WindowStyle Hidden -ExecutionPolicy Bypass -Command ""& 'C:\VPNMonitor\vpn-monitor_002.ps1'""", 0, False

' Inserido em06/03/2026
Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""C:\VPNMonitor\vpn-monitor_002.ps1""", 0, False