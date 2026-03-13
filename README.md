# vpn_monitor-fortclient

![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-5391FE?logo=powershell&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Windows-blue)
![FortiClient](https://img.shields.io/badge/VPN-FortiClient-orange)
![Status](https://img.shields.io/badge/status-active-success)

Script em PowerShell para monitoramento de tempo de uso de VPN Fortinet (FortiClient), com geração de relatórios, gráficos e alertas automáticos.


---

## 📚 Sumário

## 📚 Sumário
- [Quick Start](#-quick-start)
- [Descrição](#descrição)
- [Funcionamento](#funcionamento)
- [Recursos](#recursos)
- [Arquitetura do Script](#arquitetura-do-script)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Integração com Telegram](#integração-com-telegram-opcional)
- [Requisitos](#requisitos)
- [Licença](#licença)
- [Autor](#autor)

---

## 🚀 Quick Start

Passos rápidos para executar o monitor de VPN.

### 1️⃣ Clonar o repositório
git clone https://github.com/SEU-USUARIO/vpn_monitor-fortclient.git


### 2️⃣ Acessar a pasta do projeto
cd vpn_monitor-fortclient


### 3️⃣ Executar o script PowerShell
powershell -ExecutionPolicy Bypass -File script/vpn-monitor.ps1


### 4️⃣ (Opcional) Executar automaticamente com VBS
Crie as pastas e mova cuidadosamente os arquivos como orientado


---


## Descrição

O **vpn_monitor-fortclient** é um script desenvolvido em **PowerShell** que permite monitorar o tempo de uso de conexões VPN realizadas através do **FortiClient**.

O objetivo do script é permitir que o usuário acompanhe o tempo total diário de conexão VPN, registrando sessões, gerando relatórios e exibindo alertas automáticos ao longo do dia.

Este projeto foi criado inicialmente para **uso pessoal**, devido a uma demanda corporativa relacionada ao controle de tempo de conexão diária de VPN, possibilitando monitorias de jornada e análise de métricas de trabalho remoto, incluindo possíveis cenários de **PPR (Programa de Participação em Resultados)**.

---

## Funcionamento

O script monitora continuamente o estado da VPN e registra o tempo total de conexão ao longo do dia.

Durante o uso, ele gera alertas automáticos com base no tempo acumulado.

Principais alertas:

- ⏰ **3h50 de conexão** → sugestão de pausa para almoço  
- ⏰ **8h10 de conexão** → sugestão de encerramento da jornada ou desconexão da VPN

---

## Recursos

O script oferece os seguintes recursos:

- Monitoramento da conexão VPN do **FortiClient**
- Contador automático de tempo diário
- Registro histórico de sessões de VPN
- Geração de gráficos automáticos de utilização
- Relatório mensal em formato **CSV**
- Ícone dinâmico no **System Tray**
- Alertas de jornada de trabalho
- Sugestão de pausa para almoço
- Desconexão automática da VPN
- Integração opcional com **Telegram** para envio de notificações

---

## Arquitetura do Script

O script é composto por diversas funções responsáveis por diferentes partes da lógica de monitoramento.

| Função | Responsabilidade |
|------|------|
| Send-TelegramMessage | Envia mensagens de alerta ao Telegram |
| Send-TelegramPhoto | Envia imagens (gráficos) ao Telegram |
| Write-VpnLog | Registra histórico de sessões de VPN |
| Get-TotalTime | Lê o tempo total acumulado do dia |
| Save-TotalTime | Salva o tempo total acumulado |
| New-TimeIcon | Cria ícone dinâmico no System Tray |
| Generate-VpnChart | Gera gráfico de horas de VPN por dia |
| Generate-MonthReport | Gera relatório mensal em CSV |
| Disconnect-VPN | Desconecta a VPN automaticamente |
| Show-LunchDialog | Exibe sugestão de pausa para almoço |
| Show-Alert | Exibe mensagens de alerta ao usuário |

---

## Estrutura do Projeto

A organização do repositório segue uma estrutura simples para facilitar manutenção e documentação.

```
vpn_monitor-fortclient
│
├── script
│   ├── vpn-monitor.ps1
│   └── vpn-monitor.vbs
│
├── docs
│   └── telegram_setup.md
│
├── logs
├── reports
│
├── README.md
├── LICENSE
├── CHANGELOG.md
├── CONTRIBUTING.md
└── SECURITY.md
```

### Descrição das pastas

| Pasta | Descrição |
|------|------|
| script | Contém os scripts principais do projeto |
| docs | Documentação adicional |
| logs | Arquivos de log gerados automaticamente pelo script |
| reports | Relatórios e gráficos gerados automaticamente durante a execução |

---

## Integração com Telegram (Opcional)

O script pode enviar alertas e gráficos automaticamente para o **Telegram**.

Exemplos de notificações enviadas:

- Conexão da VPN
- Desconexão da VPN
- Alertas de jornada
- Gráfico diário de uso

📘 Guia completo de configuração:

[Configurar Bot do Telegram](docs/telegram_setup.md)

---

## Requisitos

Para execução do script são necessários:

- Sistema operacional **Windows**
- **PowerShell 5.1 ou superior**
- **FortiClient** instalado

Requisitos opcionais:

- Conexão com internet para envio de notificações
- Bot do **Telegram** configurado

---

## Licença

Este projeto é distribuído para **fins educacionais e de uso pessoal**.

O código pode ser utilizado como base de estudo, adaptação ou aprendizado, desde que respeitando os termos de uso e responsabilidade do usuário.

---

## Autor

**Thiago Boeira**

Versão: 0.8.1d  
Ano: 2026
