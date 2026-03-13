# vpn_monitor-fortclient

Script para monitoramento de uso da VPN Fortinet.

---

## 📚 Sumário

- [Descrição](#descrição)
- [Funcionamento](#funcionamento)
- [Recursos](#recursos)
- [Arquitetura do Script](#arquitetura-do-script)
- [Integração com Telegram](#integração-com-telegram)
- [Requisitos](#requisitos)
- [Autor](#autor)

---

## Descrição

O **vpn_monitor-fortclient** é um script simples criado para que um usuário possa
monitorar o tempo de uso de túnel VPN utilizando o FortiClient.

Este script foi criado inicialmente para **uso pessoal**, devido a uma demanda
da empresa para controle de tempo de conexão diária de VPN, visando
monitorias de trabalho e possibilidade de pagamento de **PPR**.

---

## Funcionamento

O script avalia o tempo de conexão da VPN e gera alertas automáticos durante o dia.

Alertas principais:

- ⏰ **3h50 de conexão** → sugestão de pausa para almoço  
- ⏰ **8h10 de conexão** → sugestão de desconexão ou encerramento de jornada

---

## Recursos

- Monitoramento de conexão VPN FortiClient
- Contador de tempo diário
- Registro histórico de uso
- Gráficos automáticos de utilização
- Relatório mensal em CSV
- Ícone dinâmico no **System Tray**
- Alertas de jornada
- Sugestão de pausa para almoço
- Desconexão automática da VPN
- Integração com Telegram para notificações

---

## Arquitetura do Script

| Função | Responsabilidade |
|------|------|
| Send-TelegramMessage | Envia mensagens de alerta ao Telegram |
| Send-TelegramPhoto | Envia imagens (gráficos) ao Telegram |
| Write-VpnLog | Grava histórico de sessões de VPN |
| Get-TotalTime | Lê tempo total acumulado do dia |
| Save-TotalTime | Salva tempo total acumulado |
| New-TimeIcon | Cria ícone dinâmico no systray |
| Generate-VpnChart | Gera gráfico de horas de VPN por dia |
| Generate-MonthReport | Gera relatório mensal em CSV |
| Disconnect-VPN | Desconecta a VPN automaticamente |
| Show-LunchDialog | Exibe sugestão de pausa para almoço |
| Show-Alert | Exibe mensagens de alerta ao usuário |

---

## Integração com Telegram (Opcional)

O script pode enviar alertas e gráficos automaticamente para o Telegram.

Exemplos de notificações:

- Conexão da VPN
- Desconexão
- Alertas de jornada
- Gráfico diário de uso

📘 Guia de configuração:

[Configurar Bot do Telegram](docs/telegram_setup.md)

---

## Requisitos

- PowerShell 5.1 ou superior
- FortiClient instalado
- Windows
- Acesso à API do Telegram (opcional)

---

## Autor

**Thiago Boeira**

Versão: 0.8.1d  
Ano: 2026
