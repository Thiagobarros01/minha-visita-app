# 🎯 RESUMO - O QUE FAZER AGORA

Você já está no GCP neste caminho:
```
~/nevt-minhavisita/minha-visita-app$
```

**Escolha UMA das 3 opções abaixo e execute:**

---

## ✅ OPÇÃO 1: MAIS RÁPIDO (Uma linha - RECOMENDADO)

```bash
mkdir -p data/database && docker-compose build && docker-compose up -d && sleep 30 && docker-compose ps && curl http://localhost:8081/actuator/health
```

✓ Cria pastas  
✓ Constrói Docker  
✓ Inicia containers  
✓ Verifica status  
✓ Testa health  

**Esperado:** `{"status":"UP"}`  ✅ = PRONTO!

---

## ✅ OPÇÃO 2: AUTOMÁTICO COM SCRIPT

```bash
bash DEPLOY_FINAL_GCP.sh
```

✓ Faz tudo automaticamente com 6 passos  
✓ Mostra progresso  
✓ Cria usuários de teste  
✓ Mostra informações finais  

---

## ✅ OPÇÃO 3: MANUAL DETALHADO

```bash
mkdir -p data/database
docker-compose build
docker-compose up -d
sleep 30
docker-compose ps
curl http://localhost:8081/actuator/health
docker-compose logs -f backend
```

---

## 🔓 FIREWALL - OBRIGATÓRIO (escolha uma)

### Via Console GCP (mais fácil - 5 cliques)
1. Abra: https://console.cloud.google.com/networking/firewalls
2. **CREATE FIREWALL RULE**
3. Name: `allow-minhavisita`
4. Direction: **Ingress** | Source: `0.0.0.0/0` | TCP: **8081**
5. **CREATE**

### Via CLI GCP (1 comando)
```bash
gcloud compute firewall-rules create allow-minhavisita --allow=tcp:8081 --source-ranges=0.0.0.0/0
```

---

## 🎬 SEQUÊNCIA DE EXECUÇÃO

1. **Escolha uma opção acima** (1, 2 ou 3)
2. **Cole no terminal GCP**
3. **Aguarde build concluir** (5-10 minutos)
4. **Se tudo ok**: `{"status":"UP"}` aparece ✅
5. **Abra firewall** (se não fez ainda)
6. **Descobra IP público**: `curl -s ifconfig.me`
7. **Acesse**: `http://SEU_IP:8081`

---

## 📊 VALIDAÇÃO

Após executar, rode isto para validar:

```bash
# Ver containers
docker-compose ps

# Testar health
curl http://localhost:8081/actuator/health

# Ver logs
docker-compose logs backend | tail -20
```

---

## 👤 CREDENCIAIS DE TESTE

Automaticamente criadas:

```
admin@nevt.com.br    - Senha: 123 (Perfil: ADMIN)
operador@nevt.com.br - Senha: 123 (Perfil: OPERADOR)
```

---

## 🔧 COMANDOS ÚTEIS DEPOIS

```bash
# Ver logs em tempo real
docker-compose logs -f backend

# Parar (sem deletar dados)
docker-compose stop

# Iniciar novamente
docker-compose start

# Parar e deletar dados
docker-compose down -v

# Seu IP público
curl -s ifconfig.me

# Status completo
docker-compose ps
docker images
docker volume ls
```

---

## ❌ TROUBLESHOOTING

**Backend não inicia:**
```bash
docker-compose logs backend
# Veja a mensagem de erro
```

**Porta 8081 já em uso:**
```bash
sudo netstat -tlnp | grep 8081
```

**Recomeçar do zero:**
```bash
docker-compose down -v && rm -rf data/
docker-compose build --no-cache
docker-compose up -d
```

---

## 🎉 QUANDO ESTIVER TUDO OK

1. ✅ Containers rodando (`docker-compose ps` mostra 2 linhas)
2. ✅ Health respondendo (`curl` retorna UP)
3. ✅ Firewall aberto (consegue acessar `http://IP:8081`)
4. ✅ Usuários criados (pode fazer login)

**Parabéns! Seu app está ONLINE no GCP! 🚀**

---

**Execute agora uma das 3 opções acima no terminal do GCP!**
