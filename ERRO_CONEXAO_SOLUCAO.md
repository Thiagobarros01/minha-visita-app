# 🆘 ERRO DE CONEXÃO - Solução Rápida

## Erro que apareceu:
```
ClientException with SocketException: Connection failed 
(OS Error: Permission denied, errno = 13)
address = 34.95.224.29, port = 8080
```

---

## 🔧 PASSO 1: Verificar Backend NO GCP

**Conecte no GCP terminal e execute:**

```bash
# Ver containers
docker-compose ps

# Status esperado:
# minhavisita-db: Up
# minhavisita-backend: Up
```

Se não estão **Up**, inicie:
```bash
docker-compose up -d
```

---

## 🔧 PASSO 2: Testar Backend (NO GCP)

```bash
# Health check
curl http://localhost:8080/actuator/health

# Esperado: {"status":"UP"}
```

Se retornar erro, veja logs:
```bash
docker-compose logs backend
```

---

## 🔧 PASSO 3: Abrir Firewall (CRUCIAL!)

**ISSO É O MAIS COMUM QUE FALTA:**

### Via Google Cloud Console (5 cliques):
1. Abra: https://console.cloud.google.com/networking/firewalls
2. Clique: **CREATE FIREWALL RULE**
3. Preencha:
   - **Name:** `allow-minhavisita`
   - **Direction:** Ingress
   - **Target:** All instances
   - **Source IP ranges:** `0.0.0.0/0`
   - **Protocols and ports:** TCP **8080**
4. Clique: **CREATE**

### OU via terminal GCP (1 comando):
```bash
gcloud compute firewall-rules create allow-minhavisita \
  --allow=tcp:8080 \
  --source-ranges=0.0.0.0/0
```

---

## 🔧 PASSO 4: Verificar Firewall (NO GCP)

```bash
# Listar firewall rules
gcloud compute firewall-rules list

# Procure por: allow-minhavisita (deve estar com allow,tcp8080)
```

---

## 🔧 PASSO 5: Testar Conexão do Seu PC

Depois de abrir firewall, teste no seu PC:

```bash
# Testar health do GCP
curl http://34.95.224.29:8080/actuator/health

# Esperado: {"status":"UP"}
```

Se retornar erro, firewall ainda não está pronto (espere 1-2 min)

---

## 📱 PASSO 6: Testar no App

Depois que `curl` funciona no PC, tente login no app novamente:

```
Email: admin@nevt.com.br
Senha: 123
```

---

## 🚨 Se ainda não funcionar:

```bash
# Ver todas as regras de firewall
gcloud compute firewall-rules describe allow-minhavisita

# Deletar regra antiga (se houver)
gcloud compute firewall-rules delete allow-minhavisita

# Recriar
gcloud compute firewall-rules create allow-minhavisita \
  --allow=tcp:8080 \
  --source-ranges=0.0.0.0/0
```

---

## ✅ Checklist Final

- [ ] Backend rodando: `docker-compose ps` (2x Up)
- [ ] Health ok: `curl http://localhost:8080/actuator/health` (UP)
- [ ] Firewall criado: `gcloud compute firewall-rules list` (allow-minhavisita presente)
- [ ] Acesso remoto: `curl http://34.95.224.29:8080/actuator/health` (UP)
- [ ] App conecta: Tenta login no app (sem erro)

---

**Faça esses passos nessa ordem e avisa o resultado!** 🚀
