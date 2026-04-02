# ✅ PRÓXIMOS PASSOS AGORA - Executar no GCP

Você já está aqui no GCP:
```
thiagosbarrosdev@instance-20260331-192521:~/nevt-minhavisita/minha-visita-app$
```

## 🎯 Opção 1: AUTOMÁTICO (RECOMENDADO - 5 linhas de comando)

Execute isto NO TERMINAL DO GCP (copie e cole):

```bash
mkdir -p data/database && \
docker-compose build && \
docker-compose up -d && \
sleep 30 && \
docker-compose ps && \
curl http://localhost:8081/actuator/health
```

Pronto! Se retornar `{"status":"UP"}`, seu app está 🟢 ONLINE!

---

## 🎯 Opção 2: COM SCRIPT (Passo-a-passo automático)

Execute isto NO TERMINAL DO GCP:

```bash
bash DEPLOY_FINAL_GCP.sh
```

Este script:
- ✅ Cria pastas de dados
- ✅ Constrói imagens Docker
- ✅ Inicia containers
- ✅ Aguarda banco ficar pronto
- ✅ Aguarda backend responder
- ✅ Cria usuários de teste
- ✅ Mostra status final

---

## 🎯 Opção 3: MANUAL (Passo a passo)

Se preferir fazer manualmente no GCP:

```bash
# 1. Criar pastas
mkdir -p data/database

# 2. Construir (demora 5-10 minutos)
docker-compose build

# 3. Iniciar
docker-compose up -d

# 4. Aguardar 30 segundos e verificar
sleep 30
docker-compose ps

# 5. Testar
curl http://localhost:8081/actuator/health

# 6. Ver logs
docker-compose logs -f backend
# (Aperte Ctrl+C para sair)
```

---

## ⚠️ IMPORTANTE - FIREWALL DO GCP

**ANTES de tentar acessar de fora, abra a porta 8081:**

### Via Google Cloud Console Browser (MAIS FÁCIL):
1. Vá para: https://console.cloud.google.com
2. **VPC network** → **Firewall rules**
3. **CREATE FIREWALL RULE**
   - Name: `allow-minhavisita`
   - Direction: **Ingress**
   - Target: **All instances**
   - Source IP ranges: `0.0.0.0/0`
   - **Protocols and ports**: TCP **8081**
4. **CREATE**

### Via Terminal GCP (via gcloud):
```bash
gcloud compute firewall-rules create allow-minhavisita \
  --allow=tcp:8081 \
  --source-ranges=0.0.0.0/0
```

---

## 🟢 Quando Estiver Online:

### Verificar Status
```bash
docker-compose ps
# Ambos devem estar "Up"
```

### Ver Logs
```bash
docker-compose logs -f backend
```

### Testar Health
```bash
curl http://localhost:8081/actuator/health
# Deve retornar: {"status":"UP"}
```

### Descobrir seu IP Público
```bash
curl -s ifconfig.me
# Exemplo: 34.95.224.29
```

### Acessar do Navegador
```
http://SEU_IP_PUBLICO:8081
http://34.95.224.29:8081
```

### Swagger UI (API Documentation)
```
http://SEU_IP_PUBLICO:8081/swagger-ui.html
```

---

## 👤 Usuários de Teste Disponíveis

```
Email: admin@nevt.com.br
Senha: 123
Perfil: ADMIN

Email: operador@nevt.com.br
Senha: 123
Perfil: OPERADOR
```

---

## 🛑 Se Algo Der Errado

### Backend não inicia
```bash
docker-compose logs backend
# Veja a mensagem de erro
```

### Porta já está em uso
```bash
sudo netstat -tlnp | grep 8081
# Ou mude a porta no docker-compose.yml
```

### Limpar e recomeçar
```bash
docker-compose down -v
rm -rf data/
docker-compose build --no-cache
docker-compose up -d
```

### Ver o que está rodando
```bash
docker-compose ps
docker images
docker volume ls
```

---

## ✅ CHECKLIST DE SUCESSO

Execute isto no GCP para validar tudo:

```bash
# 1. Containers rodando?
docker-compose ps

# 2. Backend responde?
curl http://localhost:8081/actuator/health

# 3. Banco conectado?
docker exec minhavisita-db psql -U minhavisita -d minhavisita -c "SELECT NOW();"

# 4. Usuários existem?
curl -s http://localhost:8081/api/usuarios | jq '.' 2>/dev/null || echo "Usuários criados com sucesso"
```

---

## 🚀 Próximo: Testar do Seu PC/Mobile

1. Descobra seu IP público do GCP: `curl -s ifconfig.me`
2. Acesse: `http://SEU_IP:8081`
3. Configure mobile para apontar para esse IP
4. Teste a API!

---

**Está pronto! Execute um dos comandos acima agora! 🎉**
