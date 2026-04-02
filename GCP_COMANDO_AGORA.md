# 🚀 EXECUTE AGORA NO GCP - Copia e Cola

## 1️⃣ COMANDO MAIS RÁPIDO (tudo em uma linha)

Copie e cole isto NO TERMINAL DO GCP:

```bash
mkdir -p data/database && docker-compose build && docker-compose up -d && sleep 30 && docker-compose ps && curl http://localhost:8081/actuator/health
```

Esperado: `{"status":"UP"}` ✅

---

## 2️⃣ SE QUISER MAIS DETALHADO (execute linha por linha)

```bash
# Passo 1: Criar pasta
mkdir -p data/database

# Passo 2: Construir (demora mais)
docker-compose build

# Passo 3: Iniciar
docker-compose up -d

# Passo 4: Ver se está ok
docker-compose ps

# Passo 5: Testar
curl http://localhost:8081/actuator/health
```

---

## 3️⃣ DEPOIS QUE ESTIVER ONLINE (testes)

```bash
# Ver logs
docker-compose logs -f backend

# Seu IP público
curl -s ifconfig.me

# Acessar do navegador
# http://SEU_IP_RETORNADO:8081
```

---

## ⚠️ FIREWALL - Abrir Porta 8081

**IMPORTANTE: Sem isso, não consegue acessar de fora!**

### Opção A: Clique aqui no GCP Console
https://console.cloud.google.com/networking/firewalls

Clique: **CREATE FIREWALL RULE**
- Name: `allow-minhavisita`
- Direction: **Ingress**
- Source: `0.0.0.0/0`
- TCP: `8081`
- Clique **CREATE**

### Opção B: Uma linha no terminal
```bash
gcloud compute firewall-rules create allow-minhavisita --allow=tcp:8081 --source-ranges=0.0.0.0/0
```

---

## 🟢 Status Final

Quando tudo estiver funcionando:

```
CONTAINER ID   IMAGE                                    PORTS
xxx            minhavisita-backend:latest              0.0.0.0:8081->8081/tcp
yyy            postgres:16-alpine                      5432/tcp
```

Ambas as linhas aparecem = ✅ PRONTO!

---

Agora é só colar um dos comandos acima no GCP e deixar rodar! 🎉
