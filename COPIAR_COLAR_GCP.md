# 🎯 Comandos Prontos para Copiar e Colar no GCP

## SEQUÊNCIA DE COMANDOS - COPIE E COLE NA ORDEM

### 1️⃣ INSTALAR DOCKER (Copie e Cole)
```bash
sudo apt update && sudo apt install -y docker.io docker-compose git
```

### 2️⃣ CONFIGURAR USUÁRIO (Copie e Cole)
```bash
sudo usermod -aG docker $USER && newgrp docker
```

### 3️⃣ CRIAR PASTAS (Copie e Cole)
```bash
mkdir -p ~/nevt-minhavisita/data/database && cd ~/nevt-minhavisita
```

### 4️⃣ TRANSFERIR CÓDIGO (ESCOLHA UMA)

#### A) Se estiver no GitHub/GitLab
```bash
git clone https://seu-link-do-repositorio.git .
```

#### B) Se estiver no seu PC (execute NO PowerShell Windows, não no GCP):
```powershell
# No seu PC Windows
cd "C:\caminho\do\seu\projeto"
scp -r ".\*" thiagosbarrosdev@SEU_IP_GCP:~/nevt-minhavisita/
```

### 5️⃣ VERIFICAR SE COPIOU (Copie e Cole)
```bash
ls -la ~/nevt-minhavisita/
```
Deve aparecer: `docker-compose.yml`, `pom.xml`, `src/`, `Dockerfile`

### 6️⃣ CONSTRUIR E RODAR (Copie e Cole)
```bash
cd ~/nevt-minhavisita && docker-compose build && docker-compose up -d
```

### 7️⃣ AGUARDAR E VERIFICAR (Copie e Cole) - EXECUTE APÓS 30 SEGUNDOS
```bash
docker-compose ps
```

### 8️⃣ TESTAR SE TUDO OK (Copie e Cole)
```bash
curl http://localhost:8081/actuator/health
```

Se retornar: `{"status":"UP"}` ✅ = FUNCIONANDO!

### 9️⃣ VER LOGS (Copie e Cole)
```bash
docker-compose logs -f backend
```
Aperte `CTRL+C` para sair

---

## 🔥 SUPER ATALHO - TUDO EM UM SÓ COMANDO

Depois que o código estiver lá:

```bash
cd ~/nevt-minhavisita && docker-compose down -v 2>/dev/null; docker-compose build && docker-compose up -d && sleep 30 && docker-compose logs backend
```

---

## ⚠️ ANTES DE RODAR: ABRA A PORTA NO FIREWALL

No **Google Cloud Console**:
1. Vá para **VPC network** → **Firewall rules**
2. Clique em **CREATE FIREWALL RULE**
3. Nome: `allow-minhavisita`
4. Direction: **Ingress**
5. Source IP ranges: `0.0.0.0/0`
6. Protocols: **TCP** port **8081**
7. Create

OU via CLI:
```bash
gcloud compute firewall-rules create allow-minhavisita --allow=tcp:8081 --source-ranges=0.0.0.0/0
```

---

## 📍 COMANDOS PÓS-DEPLOY

### Ver o que está rodando
```bash
docker-compose ps
```

### Ver logs em tempo real
```bash
docker-compose logs -f backend
```

### Parar tudo
```bash
docker-compose stop
```

### Iniciar novamente
```bash
docker-compose start
```

### Deletar TUDO e recomeçar
```bash
docker-compose down -v && rm -rf data/
```

### Criar usuários de teste
```bash
curl -X POST http://localhost:8081/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{"nome":"Admin","email":"admin@nevt.com.br","senha":"123","perfil":"ADMIN"}'

curl -X POST http://localhost:8081/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{"nome":"Operador","email":"operador@nevt.com.br","senha":"123","perfil":"OPERADOR"}'
```

---

## 🎯 URL FINAL

Após rodar, acesse seu app em:

```
http://SEU_IP_PUBLICO_GCP:8081
```

Exemplo: `http://34.95.224.29:8081`

---

## ✅ CHECKLIST DE VERIFICAÇÃO

- [ ] Docker instalado (rode: `docker --version`)
- [ ] Docker Compose instalado (rode: `docker-compose --version`)
- [ ] Código copiado (rode: `ls docker-compose.yml`)
- [ ] Firewall porta 8081 aberto
- [ ] Containers rodando (rode: `docker-compose ps`)
- [ ] Backend responde (rode: `curl http://localhost:8081/actuator/health`)
- [ ] URL acessível do navegador: `http://SEU_IP:8081`

---

## 🆘 SE ALGO QUEBRAR

```bash
# Ver logs de erro
docker-compose logs backend

# Reconstruir do zero
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d

# Verificar porta
sudo netstat -tlnp | grep 8081

# Testar conexão com banco
docker exec minhavisita-db psql -U minhavisita -d minhavisita -c "SELECT version();"
```

---

**Pronto! Já pode colar os comandos na sua instância GCP! 🚀**
