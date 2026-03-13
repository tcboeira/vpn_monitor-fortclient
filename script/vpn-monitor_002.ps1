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

.EXAMPLE
    .\vpn-monitor_002.ps1

    Inicia o monitor de uso da VPN no computador local.
    O script passa a monitorar a conexão VPN Fortinet, registrar o
    tempo de uso e gerar alertas conforme as regras definidas.

.NOTES
    Autor: Thiago Boeira
    Versão: 0.8.1d
    Data: 2026
#>

<#
	Nome: vpn-monitor_002.ps1
	Data: 05/03/2026 - 14h21
    Última revisão: 12/03/2026 - 13h30

	Versão: 0.8.1d
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
    $MUTEX = New-Object System.Threading.Mutex($false,"VPNMonitorScript")

    if (-not $MUTEX.WaitOne(0,$false)) {
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
    $LOGFILE   = "$BASEPATH\vpn-log.csv"
    $CHARTFILE = "$BASEPATH\vpn-chart.png"


########################################################################################
# VARIÁVEIS DE CONTROLE
########################################################################################
    $ALERTLUNCH = $false
    $ALERTEND = $false
    $ALERTMAXHOURS = $false
    $VPNCONNECTED = $false
    $LASTDAY = (Get-Date).Date


#####################################
#####################################
# v ÁREA DE DECLARAÇÃO DE FUNÇÕES v #
#####################################
#####################################

   ########################################################################################
    # Função para enviar mensagens via Telegram
    function Send-TelegramMessage($TEXT){
        $TOKEN  = "SEU_TOKEN"
        $CHATID = "SEU_CHATID"

        $BODY = "chat_id=$CHATID&text=$TEXT"

        $BYTES = [System.Text.Encoding]::UTF8.GetBytes($BODY)

        try{
            Invoke-RestMethod `
            -Uri "https://api.telegram.org/bot$TOKEN/sendMessage" `
            -Method Post `
            -Body $BYTES `
            -ContentType "application/x-www-form-urlencoded" `
            -TimeoutSec 5 | Out-Null
        }
        catch{
            Write-Host "Erro ao enviar mensagem Telegram"
        }
    }

    ########################################################################################
    # Função para enviar imagens da conexão/dia ao Telegram
    function Send-TelegramPhoto($FILE){

    $TOKEN  = "SEU_TOKEN"
    $CHATID = "SEU_CHATID"

    if (!(Test-Path $FILE)){ return }

    try{
        Invoke-RestMethod `
        -Uri "https://api.telegram.org/bot$TOKEN/sendPhoto" `
        -Method Post `
        -Form @{
            chat_id = $CHATID
            photo   = Get-Item $FILE
        } `
        -TimeoutSec 10 | Out-Null
    }
    catch{
        Write-Host "Erro ao enviar foto Telegram"
    }
    }


    ########################################################################################
    # Função para desconectar a VPN 
    function Disconnect-VPN {

        $VPN = Get-NetAdapter | Where-Object {
            ($_.Name -like "*Fortinet*" -or $_.InterfaceDescription -like $ADAPTERPATTERN) `
            -and $_.Status -eq "Up"
        }

        if ($VPN){
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

    if ($RESULT -eq "Yes"){
        Disconnect-VPN
    }
}


    ########################################################################################
    # Função para registrar sessão de uso da VPN em um arquivo CSV ($LOGFILE), 
    function Write-VpnLog($START,$END,$DURATION){

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
    function Show-Alert($MSG,$TITLE){
        [System.Windows.Forms.MessageBox]::Show($MSG,$TITLE)
    }


    ############################################################################################################################
    # Função para ler do arquivo ($TOTALFILE) o tempo total acumulado de uso da VPN no dia e retorná-lo como um objeto TimeSpan.
    function Get-TotalTime {

        if (Test-Path $TOTALFILE){

            try{
                $CONTENT = Get-Content $TOTALFILE -First 1 -ErrorAction Stop
                return [timespan]::Parse($CONTENT)
            }
            catch{
                return New-TimeSpan
            }
        }

        return New-TimeSpan
    }

    ###############################################################################################################
    # Função para salvar no arquivo ($TOTALFILE) o tempo total acumulado de uso da VPN no dia, no formato TimeSpan.
    function Save-TotalTime($TS){
        $TS.ToString() | Set-Content $TOTALFILE -Encoding UTF8
    }


    ########################################################################################
    # Função para criar um ícone 16x16 com texto dinâmico ($TEXT) para exibição no systray.
    function New-TimeIcon($TEXT){

        $BMP = New-Object System.Drawing.Bitmap 16,16
        $G = [System.Drawing.Graphics]::FromImage($BMP)

        $G.Clear([System.Drawing.Color]::Black)

        $FONT = New-Object System.Drawing.Font("Arial",7,[System.Drawing.FontStyle]::Bold)
        $BRUSH = [System.Drawing.Brushes]::White

        $G.DrawString($TEXT,$FONT,$BRUSH,0,0)

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
            if (!$DATA){ return }

        $GROUP = $DATA | ForEach-Object {
            try{
                $DAY = (Get-Date $_.DataInicio).Date
                $DUR = [timespan]::Parse($_.Duracao)
            }
            catch{
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

        foreach ($ROW in $GROUP){
            $SERIES.Points.AddXY($ROW.Day,$ROW.Hours)
        }

        $CHART.Series.Add($SERIES)
        $CHART.SaveImage($CHARTFILE,"Png")
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


############################################
############################################
# ^ FIM DA ÁREA DE DECLARAÇÃO DE FUNÇÕES ^ #
############################################
############################################


########################################################################################
# SYSTRAY
########################################################################################
    $NOTIFY = New-Object System.Windows.Forms.NotifyIcon
    $NOTIFY.Visible = $true

    $ICONDISCONNECTED = [System.Drawing.SystemIcons]::Error
    $ICONCONNECTED = [System.Drawing.SystemIcons]::Information

    $NOTIFY.Icon = $ICONDISCONNECTED
    $NOTIFY.Text = "VPN Monitor"


########################################################################################
# MENU
########################################################################################
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
# AÇÕES MENU
########################################################################################
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

        if (Test-Path $CHARTFILE){
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
    while ($true){

        # Verifica se é meio-dia para sugerir pausa para almoço
        $NOW = Get-Date
        $CURRENTDAY = $NOW.Date

       #if ($NOW.Hour -eq 12 -and !$ALERTLUNCH){
        if ($NOW.Hour -ge 12 -and $NOW.Hour -lt 13 -and !$ALERTLUNCH){
            
            Show-LunchDialog
            $ALERTLUNCH = $true
        }



        #$CURRENTDAY = (Get-Date).Date
        if ($CURRENTDAY -ne $LASTDAY){
        Generate-MonthReport
        Remove-Item $TOTALFILE -ErrorAction SilentlyContinue

        $ALERTMAXHOURS = $false
        $ALERTLUNCH = $false
        $ALERTEND = $false

        $LASTDAY = $CURRENTDAY
        }


        $VPN = Get-NetAdapter | Where-Object {

            ($_.Name -like "*Fortinet*" -or $_.InterfaceDescription -like $ADAPTERPATTERN) `
            -and $_.Status -eq "Up"

        }

        if ($VPN){

            if (-not $VPNCONNECTED){

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
                Send-TelegramMessage "VPN conectada`nUsuário: $env:USERNAME`nComputador: $env:COMPUTERNAME`nHora: $(Get-Date -Format HH:mm)"
            }

          <#$STARTCONTENT = Get-Content $STARTFILE -First 1 -ErrorAction SilentlyContinue

            try{
                $START = [datetime]::Parse($STARTCONTENT)
            }
            catch{
                $START = Get-Date
            }

            $ELAPSED = (Get-Date) - $START
            $TOTAL = Get-TotalTime#>

            $STARTCONTENT = Get-Content $STARTFILE -First 1 -ErrorAction SilentlyContinue
            if (-not $STARTCONTENT){
                $START = Get-Date
            }
            else{
                try{
                    $START = [datetime]::Parse($STARTCONTENT)
                }
                catch{
                    $START = Get-Date
                }
            }


            $ELAPSED = (Get-Date) - $START
            $TOTAL = Get-TotalTime

            # NOVO TRECHO
            $TOTALDAY = $TOTAL + $ELAPSED

            if ($TOTALDAY.TotalHours -ge 8 -and !$ALERTMAXHOURS){

                $ALERTMAXHOURS = $true

                Show-Alert `
                    "A VPN foi desconectada automaticamente.`n`nVocê atingiu 8h de jornada hoje." `
                    "VPN Monitor"

                    Send-TelegramMessage "VPN Monitor: limite de 8h atingido. VPN foi desconectada automaticamente."

                Disconnect-VPN
            }


            $HOURS = [int]$ELAPSED.TotalHours

            $NOTIFY.Icon = New-TimeIcon("$HOURS")

           #$NOTIFY.Text = "VPN: $($ELAPSED.ToString("hh\:mm")) | Total hoje: $($TOTAL.ToString("hh\:mm"))"
            $NOTIFY.Text = "VPN: $($ELAPSED.ToString("hh\:mm")) | Total hoje: $($TOTALDAY.ToString("hh\:mm"))"

           #if ($ELAPSED.TotalMinutes -ge 230 -and !$ALERTLUNCH){
            if ($ELAPSED.TotalMinutes -ge 240 -and !$ALERTLUNCH){
                
                Show-Alert "Voce esta perto de 4h de conexao.`nHora de pausa para almoço." "VPN Monitor"
                $ALERTLUNCH = $true

                Send-TelegramMessage "VPN Monitor: você está próximo de 4h de conexão. Hora de pausa."

            }

            if ($ELAPSED.TotalMinutes -ge 485 -and !$ALERTEND){

                Show-Alert "Voce esta proximo de 8h10.`nSugestao: desconectar a VPN." "VPN Monitor"
                $ALERTEND = $true
            }
        }

        else{

            if ($VPNCONNECTED){

                $VPNCONNECTED = $false
                $NOTIFY.Icon = $ICONDISCONNECTED
                $NOTIFY.Text = "VPN desconectada"

                $NOTIFY.ShowBalloonTip(
                    4000,
                    "VPN",
                    "VPN desconectada",
                    [System.Windows.Forms.ToolTipIcon]::Info
                )
                
                if (Test-Path $STARTFILE){
                    try{
                        $START = [datetime]::Parse((Get-Content $STARTFILE -First 1 -ErrorAction Stop))
                    }
                    catch{
                        $START = Get-Date
                    }

                    $ELAPSED = (Get-Date) - $START

                    Write-VpnLog $START (Get-Date) $ELAPSED

                    Generate-VpnChart
                    if (Test-Path $CHARTFILE){
                        Send-TelegramPhoto $CHARTFILE
                    }

                    $TOTAL = Get-TotalTime
                    $TOTAL += $ELAPSED
                    Save-TotalTime $TOTAL

                    Remove-Item $STARTFILE -ErrorAction SilentlyContinue

                    Send-TelegramMessage "VPN desconectada. Tempo total hoje: $($TOTAL.ToString("hh\:mm"))"
                }
            }
        }

        Start-Sleep -Seconds 15

    }


