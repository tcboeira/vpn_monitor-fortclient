O "vpn_monitor-fortclient" é um script simples, criado para que um usuario possa monitorar o tempo de uso de Túnel usando Fortclient. 
Criado - para uso pessoal - devido a uma demanda da empresa para que tenha um limite diário para o uso dela, visando possibilidade de pagamento de PPR, além de monitorias de trabalho.

Esta avaliação de tempo de conexão de VPN, quando estabelecido, alerta com 3h50 - proximo de 4h -, que sugere pausa para almoço. E alerta perto das 8h10, que sugere desconexão - ou encerrento de jornada de trabalho. 


DESCRIPTION:
    Este script monitora o estado da VPN Fortinet no computador. Ele registra sessões de conexão, calcula o tempo total diário e gera relatórios e gráficos de uso.

FUNÇÕES INTERNAS USADAS NO SCRIPT:
    Função               Responsabilidade
    ------               ----------------
    Write-VpnLog         grava histórico de sessões de VPN
    Get-TotalTime        lê tempo total acumulado do dia
    Save-TotalTime       salva tempo total acumulado
    New-TimeIcon         cria ícone dinâmico para o systray
    Generate-VpnChart    gera gráfico de horas de VPN por dia
    Generate-MonthReport gera relatório mensal em CSV

Autor: Thiago Boeira
Versão: 0.6
Data: 2026
