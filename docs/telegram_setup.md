# Criando e Configurando BOT no Telegram

Este guia explica como configurar a integração com o Telegram para receber alertas do **vpn_monitor-fortclient**.

A integração permite receber notificações como:

- Conexão da VPN
- Desconexão da VPN
- Alertas de jornada
- Gráfico diário de uso

---

# 1. Criar um Bot no Telegram

A criação de bots no Telegram é feita através do bot oficial **BotFather**.

Passos:

1. Abra o Telegram  
2. Procure por **BotFather**  
3. Abra a conversa  
4. Clique em **Start**

Agora digite o comando:

```
/newbot
```

---

# 2. Definir o nome do Bot

Escolha um nome amigável.

Exemplo:

```
VPN Monitor Bot
```

---

# 3. Definir o Username do Bot

O username **deve obrigatoriamente terminar com "bot"**.

Exemplos válidos:

```
vpn_monitor_bot
vpnworkalert_bot
vpn_monitor_alert_bot
```

Após isso o Telegram criará o bot.

---

# 4. Copiar o Token do Bot

Após criar o bot, o BotFather enviará uma mensagem contendo o **token da API**.

Exemplo:

```
123456789:ABCDefGhIJKLmnoPQRstuVWxyz123456
```

⚠ **IMPORTANTE**

Esse token é a chave de acesso ao seu bot.

Nunca publique esse token em:

- repositórios públicos
- fóruns
- documentação pública

---

# 5. Iniciar conversa com o Bot

Bots do Telegram **não podem iniciar conversa com usuários**.

O usuário precisa iniciar manualmente.

Passos:

1. Procure o bot pelo **username**
2. Abra a conversa
3. Clique em **Start** ou envie qualquer mensagem

---

# 6. Descobrir o Chat ID

O **Chat ID** identifica para quem o bot enviará as mensagens.

Abra no navegador:

```
https://api.telegram.org/botTOKEN/getUpdates
```

Substitua `TOKEN` pelo token do seu bot.

Após enviar uma mensagem para o bot, a resposta será semelhante a:

```
{
  "message": {
    "chat": {
      "id": 123456789,
      "first_name": "Usuario",
      "type": "private"
    }
  }
}
```

O número exibido em:

```
"id": 123456789
```

é o **Chat ID**.

---

# 7. Inserir as informações no script

No script PowerShell configure:

```powershell
$TOKEN  = "SEU_TOKEN"
$CHATID = "SEU_CHATID"
```

---

# 8. Testar a integração

Execute o script e verifique se a mensagem de teste é recebida no Telegram.

Exemplo de mensagem recebida:

```
VPN conectada
Usuário: computador01
Hora: 09:00
```

---

# 9. Segurança

Para proteger seu bot:

- Nunca publique o **TOKEN**
- Se o token for exposto, utilize o comando `/revoke` no BotFather
- Isso gerará um novo token automaticamente

---

# 10. Observação

A integração com Telegram é **opcional**.

O script funcionará normalmente mesmo sem configurar o Telegram.
