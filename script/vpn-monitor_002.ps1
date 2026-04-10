<#
.SYNOPSIS
    Monitor de uso de VPN para usuários.

.DESCRIPTION
    Este script monitora o estado da VPN Fortinet no computador.
    Ele registra sessões de conexão, calcula o tempo total diário,
    gera relatórios e gráficos de uso e envia notificações via Telegram.

    O script também possui controle de jornada, podendo sugerir pausa
    para almoço, alertar sobre tempo de conexão e desconectar a VPN
    automaticamente quando o limite diário de horas for atingido.

Funções internas do script:

    Função                  Responsabilidade
    ------                  ----------------
    Send-TelegramMessage    Envia mensagens de alerta ao Telegram
    Send-TelegramPhoto      Envia imagens (gráficos) ao Telegram
    Write-VpnLog            Grava histórico de sessões de VPN
    Get-TotalTime           Lê tempo total acumulado do dia
    Save-TotalTime          Salva tempo total acumulado
    New-TimeIcon            Cria ícone dinâmico para o systray
    Generate-VpnChart       Gera gráfico de horas de VPN por dia
    Generate-MonthReport    Gera relatório mensal em CSV
    Disconnect-VPN          Desconecta a VPN automaticamente
    Show-LunchDialog        Exibe sugestão de pausa para almoço
    Show-Alert              Exibe mensagens de alerta ao usuário
	Generate-MonthReport	Calcula o total de horas de VPN por dia no mês atual e exporta para CSV.
    

.EXAMPLE
    .\vpn-monitor_002.ps1

    Inicia o monitor de uso da VPN no computador local.
    O script passa a monitorar a conexão VPN Fortinet, registrar o
    tempo de uso e gerar alertas conforme as regras definidas.

.NOTES
    Autor: Thiago Boeira
    Versão: 1.0.0
    Data: 2026
#>

<#
	Nome: vpn-monitor_002.ps1
	Data: 05/03/2026 - 14h21
    Última revisão: 10/04/2026 - 9h15

	Versão: 1.0.0
	Criado: Thiago Boeira
			tcboeira@gmail.com
		
	Função/Descrição:	Avaliar tempo de conexão de VPN, quando estabelecido, e avisar com 4h e 8h10, sugerindo pausa para almoço, bem como desconexão.
                        É para questões de ajuste visando PPR e monitorias de trabalho

    Dependências:
    - PowerShell 5.1+
    - Fortinet SSL VPN Adapter
    - Acesso à API Telegram (opcional)

    Ambiente:
    - Windows 10 / Windows 11
    - Uso local (não requer privilégios administrativos)

	###########################
	# Anotações de Alterações #
	#
	Versão // Data - Hora // Alteração-Descrição

   1.0.0 // 10/04/2026 - 9h15 // - Corrigido e melhorado versões para coleta de dados do dia e envio de imagens/relatorios do dia;
                                 - Melhora quanto ao uso do token no que toca uso do Bot do Telegram
                                 - Incluso AUTO Update;
                                 - Tornado versão de produção
   
   0.12d // 27/03/2026 - 9h15 // - Incremento de funções que melhora o controle de reconexão da VPN, para evitar que o script herde um tempo antigo caso seja reiniciado ou haja uma interrupção, verificando o timestamp da última execução e resetando o contador se necessário.;
                                 - Melhora do alerta de reconexão para diferenciar entre início do dia e reconexões ao longo do dia, enviando mensagens distintas ao Telegram para cada caso.
  
   0.11.1d // 26/03/2026 - 9h // - Aperfeiçoamento das correções e ajustes da versão 0.11d;
    
   0.11d // 25/03/2026 - 12h25 // - Correção da captura de tempo conectado para evitar erros de leitura e cálculo do tempo total diário;
                                  - Melhoria na geração de gráficos e relatórios para refletir corretamente o tempo de conexão diário, mesmo em casos de desconexões inesperadas.
                                  - Ajustado timing para alerta de desconexão acidental da VPN  

   0.10d // 24/03/2026 - 13h25 // - Ajuste de alerta e exibição em telegram
                                  - Melhora do controle de conexão, para melhor alertar casos de deconexão

    0.9d // 17/03/2026 - 16h05 //   - Corrigido questões a cerca de controle de desconexão e coleta de dados para controle diario de conexão e dados para reports dia e mês;

    0.8.1d // 13/03/2026 - 8h55 // - Alterado função de envio de mensagens via Telegram para que use codificação UTF-8;

    0.8d // 12/03/2026 - 13h30 // - Sugestão automática de pausa próxima das 12h (almoço);
                                  - Desconexão automática ao atingir 8h de jornada;
                                  - Integração com Telegram (avisos de conexão, desconexão e alertas);
                                  - Envio automático do gráfico diário ao Telegram;
                                  - Aplicado timeout em chamadas da API para evitar travamento;
                                  - Correção de duplicação de processamento ao desconectar VPN;
                                  - Melhor tratamento de erros na leitura de arquivos de controle;

    
    0.7d // 11/03/2026 - 13h30 // - Incrementado com sugestão de conexão proximo das 12h para indicar horario de almoço;
                                  - Forçar desconexão próximo das 18h para evitar horas extras indesejadas;
    
    0.6d // 06/03/2026 - 10h50 // - Corrigido para que se evite abrir duas vezes;
                                 - Efetua gravação de histórico de uso;
                                 - Gera gráfico automático, relatório mensal;
                                 - Contador diário;
                                 - Ícone dinâmico no systray;
                                 - Melhora e refina alertas de jornada;
                                 - Aplicado tolerância a erro de leitura de arquivo;

    0.5d // 05/03/2026 - 15h27 // - Detecta VPN Fortinet e Calcula tempo da sessão e Calcula tempo total do dia;
                                 - Incrementado contador: Zera automaticamente todo dia; Mantém histórico em CSV e Evita carregar tempo do dia anterior;
                                 - Interface: Ícone muda quando conecta/desconecta; tempo aparece no tooltip (VPN: 02:15 | Total: 04:38);

    0.4d // 05/03/2026 - 15h27 // - Ícone do Systray muda conforme o estado da VPN;
                                 - Visão mais ampla de tempo de conexão de VPN no icone: "VPN: 02:15 | Total: 04:38";
                                 - Status da VPN de forma geral;
                                 - Melhor leitura da data do arquivo;
                                 - Organização visual melhor/reorganizado script em blocos claros;

	0.3d // 05/03/2026 - 14h // Ajustes e melhor exibição do corpo deste Script;

	0.2d // 05/03/2026 - 12h // Correções de exibição de informação de tempo, no systray;

	0.1d // 05/03/2026 - 10h // Criação;


    NOTA:
        p - Produção (oculto descrição)
        d - Desenvolvimento (exibe descrição, até chegar na versão de produção)

#>


########################################################################################
# Informa qual versão do PowerShell é necessária para rodar este script e ativa o modo estrito para evitar erros comuns de codificação.
########################################################################################
    #Requires -Version 5.1


########################################################################################
# Inibe erros em tela de usuarios durante a execução
########################################################################################
    $ErrorActionPreference = "SilentlyContinue"


########################################################################################
# Ativa o modo estrito para a versão mais recente do PowerShell, o que ajuda a identificar erros de codificação e práticas inseguras.
########################################################################################
    Set-StrictMode -Version Latest


########################################################################################
# REFERÊNCIAS
########################################################################################
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName System.Windows.Forms.DataVisualization


########################################################################################
# EVITA MÚLTIPLAS INSTÂNCIAS
########################################################################################
    $MUTEX = New-Object System.Threading.Mutex($false, "VPNMonitorScript")

        if (-not $MUTEX.WaitOne(0, $false)) {
            [System.Windows.Forms.MessageBox]::Show("VPN Monitor já está em execução.")
            exit
        }


########################################################################################
# CONFIGURAÇÕES
########################################################################################
    $ADAPTERPATTERN = "*Fortinet SSL VPN*"

    $BASEPATH = "C:\VPNMonitor"

        if (!(Test-Path $BASEPATH)) {
            New-Item -ItemType Directory -Path $BASEPATH | Out-Null
        }

    $STARTFILE = "$BASEPATH\vpn-start.txt"
    $TOTALFILE = "$BASEPATH\vpn-total.txt"
    $LOGFILE = "$BASEPATH\vpn-log.csv"
    $CHARTFILE = "$BASEPATH\vpn-chart.png"

    $STATEFILE = "$BASEPATH\vpn-state.json"


########################################################################################
# VARIÁVEIS DE CONTROLE
########################################################################################
    $ALERTLUNCH = $false
    $ALERTEND = $false
    $ALERTMAXHOURS = $false
    $VPNCONNECTED = $false
    $LASTDAY = (Get-Date).Date
    $LASTVPNSTATE = $false
    $MANUALDISCONNECT = $false


########################################################################################
# Trecho adicionado para evitar que o script herde um tempo antigo caso seja reiniciado ou haja uma interrupção, verificando o timestamp da última execução e resetando o contador se necessário.
########################################################################################
    $LASTRUNFILE = "$BASEPATH\last-run.txt"

    if (Test-Path $LASTRUNFILE) {
        try {
            $LASTRUN = Get-Content $LASTRUNFILE | Get-Date
            $NOW = Get-Date

            # Se passou muito tempo desde última execução → considera reboot/interrupção
            if (($NOW - $LASTRUN).TotalMinutes -gt 10) {
                Remove-Item $TOTALFILE -ErrorAction SilentlyContinue
            }
        }
        catch {
            Remove-Item $TOTALFILE -ErrorAction SilentlyContinue
        }
    }

    # Atualiza timestamp da execução atual
    (Get-Date) | Set-Content $LASTRUNFILE

    # Marca início do script (proteção anti-trigger imediato)
    $SCRIPTSTART = Get-Date


#####################################
#####################################
# v ÁREA DE DECLARAÇÃO DE FUNÇÕES v #
#####################################
#####################################

    ########################################################################################
    # Função para enviar mensagens via Telegram
	 function Send-TelegramMessage($TEXT) {

        $CONFIG = Get-Config
        $TOKEN = $CONFIG.TelegramToken
        $CHATID = $CONFIG.ChatId

		try {
			Invoke-RestMethod `
				-Uri "https://api.telegram.org/bot$TOKEN/sendMessage" `
				-Method Post `
				-Body @{
					chat_id = $CHATID
					text    = $TEXT
				} `
				-ContentType "application/x-www-form-urlencoded" `
				-TimeoutSec 5 | Out-Null
		}
		catch {
			Write-Host "Erro ao enviar mensagem Telegram"
		}
	}


	########################################################################################
	# Função para enviar imagens da conexão/dia ao Telegram
	function Send-TelegramPhoto($FILE) {

    $CONFIG = Get-Config
    $TOKEN = $CONFIG.TelegramToken
    $CHATID = $CONFIG.ChatId

		if (!(Test-Path $FILE)) { return }

		try {
			Invoke-RestMethod `
				-Uri "https://api.telegram.org/bot$TOKEN/sendPhoto" `
				-Method Post `
				-Form @{
				chat_id = $CHATID
				photo   = Get-Item $FILE
			} `
				-TimeoutSec 10 | Out-Null
		}
		catch {
			Write-Host "Erro ao enviar foto Telegram"
		}
	}

	########################################################################################
	# Função para salvar o estado atual da VPN (se é a primeira conexão do dia ou não) em um arquivo JSON, para referência futura.
    function Save-State($IsFirstConnectionDone, $LastConnectionTime) {

        $OBJ = @{
            Date = (Get-Date).ToString("yyyy-MM-dd")
            FirstConnectionDone = $IsFirstConnectionDone
            LastConnectionTime = $LastConnectionTime
            User = $env:USERNAME
            Computer = $env:COMPUTERNAME
        }

        $OBJ | ConvertTo-Json | Set-Content $STATEFILE
    }

	########################################################################################
	# Função para ler o estado salvo da VPN a partir do arquivo JSON e determinar se é a primeira conexão do dia ou não, retornando um valor booleano.
    function Get-State {

        if (!(Test-Path $STATEFILE)) {
            return $false
        }

        try {
            $DATA = Get-Content $STATEFILE -Raw | ConvertFrom-Json

            if ($DATA.Date -ne (Get-Date).ToString("yyyy-MM-dd")) {
                return $false
            }

            return $DATA.FirstConnectionDone
        }
        catch {
            return $false
        }
    }

	########################################################################################
	# Função para desconectar a VPN 
	function Disconnect-VPN {

		$VPN = Get-NetAdapter | Where-Object {
			($_.Name -like "*Fortinet*" -or $_.InterfaceDescription -like $ADAPTERPATTERN) `
				-and $_.Status -eq "Up"
		}

		if ($VPN) {
			Disable-NetAdapter -Name $VPN.Name -Confirm:$false
		}
	}

	########################################################################################
	# Função de exibição de tela proximo ao almoço
	function Show-LunchDialog {

		$RESULT = [System.Windows.Forms.MessageBox]::Show(
			"Já são 12h.`n`nHorário de almoço.`nDeseja desconectar a VPN agora?",
			"VPN Monitor",
			[System.Windows.Forms.MessageBoxButtons]::YesNo,
			[System.Windows.Forms.MessageBoxIcon]::Question
		)

		if ($RESULT -eq "Yes") {

			$global:MANUALDISCONNECT = $true
			Disconnect-VPN
			Start-Sleep -Seconds 3



		}
	}

    ########################################################################################
    # Função para registrar sessão de uso da VPN em um arquivo CSV ($LOGFILE), 
    function Write-VpnLog($START, $END, $DURATION) {

        $OBJ = [PSCustomObject]@{
            DataInicio = $START
            DataFim    = $END
            Duracao    = $DURATION.ToString()
        }

        if (!(Test-Path $LOGFILE)) {
            $OBJ | Export-Csv $LOGFILE -NoTypeInformation -Encoding UTF8
        }
        else {
            $OBJ | Export-Csv $LOGFILE -Append -NoTypeInformation -Encoding UTF8 -Force
        }
    }

    ###############################################################################################################
    # Função para exibir uma janela de alerta (MessageBox) ao usuário com uma mensagem ($MSG) e um título ($TITLE).
    function Show-Alert($MSG, $TITLE) {
        [System.Windows.Forms.MessageBox]::Show($MSG, $TITLE)
    }

    ############################################################################################################################
    # Função para ler do arquivo ($TOTALFILE) o tempo total acumulado de uso da VPN no dia e retorná-lo como um objeto TimeSpan.
    function Get-TotalTime {
        if (!(Test-Path $TOTALFILE)) {
            return New-TimeSpan
        }

        try {
            $CONTENT = Get-Content $TOTALFILE -Raw | ConvertFrom-Json
            $TODAY = (Get-Date).ToString("yyyy-MM-dd")

            if ($CONTENT.Date -ne $TODAY) {
                # RESET automático se for outro dia
                return New-TimeSpan
            }

            return [timespan]::Parse($CONTENT.Total)
        }
        catch {
            return New-TimeSpan
        }
    }


    ###############################################################################################################
    # Função para salvar no arquivo ($TOTALFILE) o tempo total acumulado de uso da VPN no dia, no formato TimeSpan.
    function Save-TotalTime($TS) {
        $OBJ = @{
            Date  = (Get-Date).ToString("yyyy-MM-dd")
            Total = $TS.ToString()
        }

        $OBJ | ConvertTo-Json | Set-Content $TOTALFILE -Encoding UTF8
    }

    ########################################################################################
    # Função para criar um ícone 16x16 com texto dinâmico ($TEXT) para exibição no systray.
    function New-TimeIcon($TEXT) {

        $BMP = New-Object System.Drawing.Bitmap 16, 16
        $G = [System.Drawing.Graphics]::FromImage($BMP)

        $G.Clear([System.Drawing.Color]::Black)

        $FONT = New-Object System.Drawing.Font("Arial", 7, [System.Drawing.FontStyle]::Bold)
        $BRUSH = [System.Drawing.Brushes]::White

        $G.DrawString($TEXT, $FONT, $BRUSH, 0, 0)

        $ICONHANDLE = $BMP.GetHicon()
        $ICON = [System.Drawing.Icon]::FromHandle($ICONHANDLE).Clone()

        [System.Runtime.InteropServices.Marshal]::Release($ICONHANDLE)

        $G.Dispose()
        $BMP.Dispose()

        return $ICON
    }

    #################################################
    # Gera um gráfico PNG com as horas de VPN por dia
    function Generate-VpnChart {

        if (!(Test-Path $LOGFILE)) { return }

        $DATA = Import-Csv $LOGFILE
        if (!$DATA) { return }

        $GROUP = $DATA | ForEach-Object {
            try {
                $DAY = (Get-Date $_.DataInicio).Date
                $DUR = [timespan]::Parse($_.Duracao)
            }
            catch {
                return
            }

            [PSCustomObject]@{
                Day   = $DAY
                Hours = $DUR.TotalHours
            }

        } | Group-Object Day | ForEach-Object {

            [PSCustomObject]@{
                Day   = $_.Name
                Hours = ($_.Group | Measure-Object Hours -Sum).Sum
            }

        }

        $CHART = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
        $CHART.Width = 800
        $CHART.Height = 400

        $AREA = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
        $AREA.AxisX.Interval = 1
        $AREA.AxisX.LabelStyle.Angle = -45
        $AREA.AxisY.Title = "Horas de VPN"

        $CHART.ChartAreas.Add($AREA)

        $SERIES = New-Object System.Windows.Forms.DataVisualization.Charting.Series
        $SERIES.ChartType = "Column"

        foreach ($ROW in $GROUP) {
            $SERIES.Points.AddXY($ROW.Day, $ROW.Hours)
        }

        $CHART.Series.Add($SERIES)
        $CHART.SaveImage($CHARTFILE, "Png")
    }

    ########################################################################################
    # Função que calcula o total de horas de VPN por dia no mês atual e exporta para CSV.
    function Generate-MonthReport {

        if (!(Test-Path $LOGFILE)) { return }

        $DATA = Import-Csv $LOGFILE
        $MONTH = (Get-Date).ToString("yyyy-MM")

        $MONTHDATA = $DATA | Where-Object {
            $_.DataInicio -like "$MONTH*"
        }

        $GROUP = $MONTHDATA | ForEach-Object {

            $DAY = (Get-Date $_.DataInicio).Date
            $DUR = [timespan]::Parse($_.Duracao)

            [PSCustomObject]@{
                Day   = $DAY
                Hours = $DUR.TotalHours
            }

        } | Group-Object Day | ForEach-Object {

            [PSCustomObject]@{
                Day   = $_.Name
                Hours = ($_.Group | Measure-Object Hours -Sum).Sum
            }

        }

        $GROUP | Export-Csv "$BASEPATH\vpn-month-report.csv" -NoTypeInformation -Encoding UTF8
    }

    ######################################################################################################################################
    # Função que salva o histórico diário de sessões de VPN em um arquivo CSV, incluindo data, duração da sessão e total acumulado no dia.
    function Save-DailyHistory($SESSION, $TOTAL) {
        $FILE = "$BASEPATH\daily-history.csv"

        $OBJ = [PSCustomObject]@{
            Date            = (Get-Date).ToString("yyyy-MM-dd")
            SessionDuration = $SESSION.ToString("hh\:mm\:ss")
            TotalAtMoment   = $TOTAL.ToString("hh\:mm\:ss")
        }

        if (!(Test-Path $FILE)) {
            $OBJ | Export-Csv $FILE -NoTypeInformation -Encoding UTF8
        }
        else {
            $OBJ | Export-Csv $FILE -Append -NoTypeInformation -Encoding UTF8
        }
    }

    ##################################
    # Funão para de fechamento do dia
    function Close-Day {
        Generate-VpnChart

        if (Test-Path $CHARTFILE) {
            Send-TelegramPhoto $CHARTFILE
        }

        $TOTAL = Get-TotalTime

        Send-TelegramMessage "Resumo do dia:`nTempo total: $($TOTAL.ToString("hh\:mm"))"
    }


    ##################################
    # Funão correção quanto ao uso dos Tokens
    function Get-Config {
        $CONFIGFILE = "$BASEPATH\config.json"
        if (!(Test-Path $CONFIGFILE)) {
            throw "Arquivo de configuração não encontrado!"
        }
        return Get-Content $CONFIGFILE -Raw | ConvertFrom-Json
    }


############################################
############################################
# ^ FIM DA ÁREA DE DECLARAÇÃO DE FUNÇÕES ^ #
############################################
############################################

###########################################
###########################################
# v FUNÇÕES EXCLUSIVAS PARA AUTO UPDATE v #
###########################################
###########################################

    $SCRIPT_VERSION = "1.0.0"
    $UPDATECHECKFILE = "$BASEPATH\last-update-check.txt"
    $VERSION_URL = "https://raw.githubusercontent.com/tcboeira/vpn_monitor-fortclient/main/script/version.json"


    # Função para normalizar versões para o formato padrão (ex: 1.0 → 1.0.0) permitindo comparação correta entre versões
    function Normalize-Version($v) {
        $parts = $v.ToString().Trim().Split('.')
        while ($parts.Count -lt 3) { $parts += "0" }
        return ($parts -join '.')
    }

    # Função para Verifica se já passou o intervalo definido (3 horas) desde a última checagem de atualização
    function Should-CheckUpdate {

        if (!(Test-Path $UPDATECHECKFILE)) {
            return $true
        }

        try {
            $LAST = Get-Content $UPDATECHECKFILE | Get-Date

            # 🔥 ALTERADO PARA 3 HORAS
            if ((Get-Date) - $LAST -gt (New-TimeSpan -Hours 3)) {
                return $true
            }
        }
        catch {
            return $true
        }

        return $false
    }

    # Função que consulta a versão remota no GitHub, compara com a versão local e, se houver atualização, notifica o usuário e abre o link para download.
    function Check-ForUpdate {

        try {
            $REMOTE = Invoke-RestMethod -Uri $VERSION_URL -TimeoutSec 5

            if (-not $REMOTE.version) { return }

            $REMOTE_VERSION = Normalize-Version $REMOTE.version
            $LOCAL_VERSION  = Normalize-Version $SCRIPT_VERSION

            if ([version]$REMOTE_VERSION -gt [version]$LOCAL_VERSION) {

                $MSG = "Nova versão disponível: $REMOTE_VERSION`nVersão atual: $LOCAL_VERSION`n`nDeseja atualizar agora?"

                $RESULT = [System.Windows.Forms.MessageBox]::Show(
                    $MSG,
                    "Atualização disponível",
                    [System.Windows.Forms.MessageBoxButtons]::YesNo,
                    [System.Windows.Forms.MessageBoxIcon]::Information
                )

            if ($RESULT -eq "Yes" -and $REMOTE.download -and $REMOTE.download -like "http*") {
                Start-Process $REMOTE.download
                exit
            }

            }
        }
        catch {
            # silencioso conforme padrão do script
        }
        finally {
            (Get-Date) | Set-Content $UPDATECHECKFILE
        }
    }

##########################################################
##########################################################
# ^ FIM DA ÁREA DE FUNÇÕES EXCLUSIVAS PARA AUTO UPDATE ^ #
##########################################################
##########################################################



#######################################
# EXECUTA AUTO UPDATE (execução única)
#######################################
    try {
        if (Should-CheckUpdate) {
            Check-ForUpdate
        }
    }
    catch {
        # silencioso
    }


########################################################################################
# Cria ícone na bandeja do sistema (systray) para monitoramento da VPN, com opções de menu para mostrar tempo, resetar contador, abrir gráfico e sair.
########################################################################################
    $NOTIFY = New-Object System.Windows.Forms.NotifyIcon
    $NOTIFY.Visible = $true

    $ICONDISCONNECTED = [System.Drawing.SystemIcons]::Error
    $ICONCONNECTED = [System.Drawing.SystemIcons]::Information

    $NOTIFY.Icon = $ICONDISCONNECTED
    $NOTIFY.Text = "VPN Monitor"

    ########################################################################################
    # MENU de opções ao clicar com o botão direito no ícone do systray
        $MENU = New-Object System.Windows.Forms.ContextMenuStrip

        $ITEMSHOW = New-Object System.Windows.Forms.ToolStripMenuItem
        $ITEMSHOW.Text = "Mostrar tempo hoje"

        $ITEMRESET = New-Object System.Windows.Forms.ToolStripMenuItem
        $ITEMRESET.Text = "Resetar contador"

        $ITEMCHART = New-Object System.Windows.Forms.ToolStripMenuItem
        $ITEMCHART.Text = "Abrir gráfico"

        $ITEMEXIT = New-Object System.Windows.Forms.ToolStripMenuItem
        $ITEMEXIT.Text = "Sair"

        $MENU.Items.Add($ITEMSHOW)
        $MENU.Items.Add($ITEMRESET)
        $MENU.Items.Add($ITEMCHART)
        $MENU.Items.Add($ITEMEXIT)

        $NOTIFY.ContextMenuStrip = $MENU

    ########################################################################################
    # Eventos dos itens do menu do Systray
        $ITEMSHOW.Add_Click({

                $TOTAL = Get-TotalTime

                [System.Windows.Forms.MessageBox]::Show(
                    "Tempo total hoje: $($TOTAL.ToString("hh\:mm"))",
                    "VPN Monitor"
                )

            })

        $ITEMRESET.Add_Click({

                Remove-Item $TOTALFILE -ErrorAction SilentlyContinue

                [System.Windows.Forms.MessageBox]::Show(
                    "Contador resetado.",
                    "VPN Monitor"
                )

            })

        $ITEMCHART.Add_Click({

                Generate-VpnChart

                if (Test-Path $CHARTFILE) {
                    Start-Process $CHARTFILE
                }

            })

        $ITEMEXIT.Add_Click({

                $NOTIFY.Visible = $false
                $NOTIFY.Dispose()
                exit

            })


########################################################################################
# LOOP PRINCIPAL
########################################################################################
while ($true) {

    # Verifica se é meio-dia para sugerir pausa para almoço
    $NOW = Get-Date
    $CURRENTDAY = $NOW.Date

    if ($NOW.Hour -ge 12 -and $NOW.Hour -lt 13 -and !$ALERTLUNCH) {
            
        Show-LunchDialog
        $ALERTLUNCH = $true
    }

if ($CURRENTDAY -ne $LASTDAY) {
        # 🔴 FECHA SESSÃO SE AINDA ESTIVER CONECTADO
        if ($VPNCONNECTED -and (Test-Path $STARTFILE)) {

            try {
                $START = [datetime]::Parse((Get-Content $STARTFILE -First 1))
            }
            catch {
                $START = Get-Date
            }

            $ELAPSED = (Get-Date) - $START

            Write-VpnLog $START (Get-Date) $ELAPSED

            $TOTAL = Get-TotalTime
            $TOTAL = [timespan]::FromSeconds($TOTAL.TotalSeconds + $ELAPSED.TotalSeconds)
            Save-TotalTime $TOTAL

            Save-DailyHistory $ELAPSED $TOTAL

            Remove-Item $STARTFILE -ErrorAction SilentlyContinue
        }

        # 🟢 AGORA SIM: fecha o dia corretamente
        Close-Day

        Generate-MonthReport
        Remove-Item $TOTALFILE -ErrorAction SilentlyContinue
        
        Save-State $false

        $ALERTMAXHOURS = $false
        $ALERTLUNCH = $false
        $ALERTEND = $false

        $LASTDAY = $CURRENTDAY
    }


    $VPN = Get-NetAdapter | Where-Object {
        ($_.Name -like "*Fortinet*" -or $_.InterfaceDescription -like $ADAPTERPATTERN) `
            -and $_.Status -eq "Up"
    }

    $CURRENTSTATE = [bool]$VPN


    # =========================
    # DETECÇÃO DE MUDANÇA DE ESTADO 
    # =========================
    if ($LASTVPNSTATE -and -not $CURRENTSTATE) {
        if (-not $MANUALDISCONNECT -and ((Get-Date) - $SCRIPTSTART).TotalMinutes -gt 1) {
            Send-TelegramMessage "VPN caiu inesperadamente!"
        }
        $MANUALDISCONNECT = $false
    }

	if (-not $LASTVPNSTATE -and $CURRENTSTATE){
        $TOTAL = Get-TotalTime
        $ALREADYCONNECTEDTODAY = Get-State

        if (-not $ALREADYCONNECTEDTODAY) {
                Send-TelegramMessage "VPN conectada (início do dia)`nUsuário: $env:USERNAME`nComputador: $env:COMPUTERNAME`nHora: $(Get-Date -Format HH:mm)"
                Save-State -IsFirstConnectionDone $true -LastConnectionTime (Get-Date)
            } else {
                Send-TelegramMessage "VPN reconectada`nUsuário: $env:USERNAME`nComputador: $env:COMPUTERNAME`nHora: $(Get-Date -Format HH:mm)"
                Save-State -IsFirstConnectionDone $true -LastConnectionTime (Get-Date)
        }
    }

    $LASTVPNSTATE = $CURRENTSTATE

    if ($VPN) {

        if (-not $VPNCONNECTED) {
		
            # Evita herdar tempo antigo após reconexão
            $TOTAL = Get-TotalTime

            # proteção: nunca herdar lixo antigo
            if ($TOTAL.TotalHours -ge 12) {
                $TOTAL = New-TimeSpan
                Save-TotalTime $TOTAL
            }


            $ALERTMAXHOURS = $false

            $VPNCONNECTED = $true
            $ALERTLUNCH = $false
            $ALERTEND = $false

            $START = Get-Date
            $START.ToString("yyyy-MM-dd HH:mm:ss") | Set-Content $STARTFILE -Encoding UTF8

            $NOTIFY.Icon = $ICONCONNECTED

            $NOTIFY.ShowBalloonTip(
                5000,
                "VPN",
                "VPN conectada",
                [System.Windows.Forms.ToolTipIcon]::Info
            )
        }

        $STARTCONTENT = Get-Content $STARTFILE -First 1 -ErrorAction SilentlyContinue
        if (-not $STARTCONTENT) {
            $START = Get-Date
        }
        else {
            try {
                $START = [datetime]::Parse($STARTCONTENT)
            }
            catch {
                $START = Get-Date
            }
        }

        $ELAPSED = (Get-Date) - $START
        $TOTAL = Get-TotalTime

        # ✔ cálculo correto do total do dia (sem salvar)
       #$TOTALDAY = $TOTAL + $ELAPSED
        $TOTALDAY = [timespan]::FromSeconds(($TOTAL.TotalSeconds + $ELAPSED.TotalSeconds))

        if (
            $TOTALDAY.TotalHours -ge 8 `
                -and !$ALERTMAXHOURS `
                -and ((Get-Date) - $SCRIPTSTART).TotalMinutes -gt 2
        ) {


            $ALERTMAXHOURS = $true

            Show-Alert `
                "A VPN foi desconectada automaticamente.`n`nVocê atingiu 8h de jornada hoje." `
                "VPN Monitor"

            Send-TelegramMessage "VPN Monitor: limite de 8h atingido. VPN foi desconectada automaticamente."
            $global:MANUALDISCONNECT = $true
            Disconnect-VPN
            Start-Sleep -Seconds 3

        }


        $HOURS = [int]$ELAPSED.TotalHours
        $NOTIFY.Icon = New-TimeIcon("$HOURS")
        $NOTIFY.Text = "VPN: $($ELAPSED.ToString("hh\:mm")) | Total hoje: $($TOTALDAY.ToString("hh\:mm"))"

        if ($ELAPSED.TotalMinutes -ge 240 -and !$ALERTLUNCH) {
            Show-Alert "Voce esta perto de 4h de conexao.`nHora de pausa para almoço." "VPN Monitor"
            $ALERTLUNCH = $true

            Send-TelegramMessage "VPN Monitor: você está próximo de 4h de conexão. Hora de pausa."
        }

        if ($ELAPSED.TotalMinutes -ge 485 -and !$ALERTEND) {

            Show-Alert "Voce esta proximo de 8h10.`nSugestao: desconectar a VPN." "VPN Monitor"
            $ALERTEND = $true
        }
    }

    else {

        if ($VPNCONNECTED) {

            $VPNCONNECTED = $false
            $NOTIFY.Icon = $ICONDISCONNECTED
            $NOTIFY.Text = "VPN desconectada"

            $NOTIFY.ShowBalloonTip(
                4000,
                "VPN",
                "VPN desconectada",
                [System.Windows.Forms.ToolTipIcon]::Info
            )
                
            if (Test-Path $STARTFILE) {
                try {
                    $START = [datetime]::Parse((Get-Content $STARTFILE -First 1 -ErrorAction Stop))
                }
                catch {
                    $START = Get-Date
                }

                $ELAPSED = (Get-Date) - $START

                Write-VpnLog $START (Get-Date) $ELAPSED

                $TOTAL = Get-TotalTime
                $TOTAL = [timespan]::FromSeconds($TOTAL.TotalSeconds + $ELAPSED.TotalSeconds)
                Save-TotalTime $TOTAL

                Save-DailyHistory $ELAPSED $TOTAL

                Remove-Item $STARTFILE -ErrorAction SilentlyContinue

                Send-TelegramMessage "VPN desconectada. Tempo total hoje: $($TOTAL.ToString("hh\:mm"))"
            }
        }
    }

    Start-Sleep -Seconds 2 -ErrorAction SilentlyContinue

}



