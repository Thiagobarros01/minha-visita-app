# ✅ DEPLOY CORRIGIDO - INSTRUÇÕES ATUALIZADAS

## 🔧 O que foi corrigido?

Dockerfile atualizado para permitir build no Chainguard Maven.

✅ Código já foi atualizado no GitHub  
✅ Git push já realizado  

---

## 🚀 EXECUTE AGORA NO GCP (Copie e Cole)

Estando na pasta `~/nevt-minhavisita/minha-visita-app`, execute:

```bash
git pull && docker-compose down -v && mkdir -p data/database && docker-compose build && docker-compose up -d && sleep 30 && docker-compose ps && curl http://localhost:8081/actuator/health
```

---

## ⏱️ Timeouts Expected

- **Docker build:** 5-10 minutos (primeira vez, compilando Java)
- **Containers iniciando:** 30-60 segundos
- **Total:** ~10-15 minutos

Não interrompa! Deixe rodar até completar.

---

## 🎯 Sinais de Sucesso

**✅ Build concluído com sucesso:**
```
Step 10/10 : ENTRYPOINT ["java", "-jar", "app.jar"]
 ---> xyz123
Successfully built xyz123
Successfully tagged minhavisita-backend:latest
```

**✅ Containers rodando:**
```
CONTAINER ID   IMAGE                      COMMAND                  PORTS
abc123         minhavisita-backend:latest "java -jar app.jar"     0.0.0.0:8081->8081/tcp
def456         postgres:16-alpine         "postgres"              5432/tcp
```

**✅ Backend respondendo:**
```
{"status":"UP"}
```

Se todos os 3 aparecerem = **🟢 DEPLOY PRONTO!**

---

## 🔓 Abrir Firewall (IMPORTANTE!)

Após deploy estar ok, **ANTES de tentar acessar**, abra porta 8081:

### Via Console GCP (5 cliques)
- https://console.cloud.google.com/networking/firewalls
- **CREATE FIREWALL RULE**
- Name: `allow-minhavisita`
- Direction: **Ingress**
- Source: `0.0.0.0/0`
- Protocols: **TCP 8081**
- **CREATE**

### OU via Terminal (1 comando)
```bash
gcloud compute firewall-rules create allow-minhavisita --allow=tcp:8081 --source-ranges=0.0.0.0/0
```

---

## 🌐 Acessar Seu App

Após firewall aberto, execute NO GCP:

```bash
# Ver seu IP público
curl -s ifconfig.me
```

Depois acesse no navegador:
```
http://SEU_IP_RETORNADO:8081
```

Exemplo:
```
http://34.95.224.29:8081
```

---

## 👤 Credenciais Automáticas

```
Email: admin@nevt.com.br
Senha: 123
Perfil: ADMIN

Email: operador@nevt.com.br
Senha: 123
Perfil: OPERADOR
```

---

## 🛠️ Se Algo Der Errado

### Ver logs + detalhes
```bash
docker-compose logs backend
```

### Limpar tudo e recomeçar
```bash
docker-compose down -v
rm -rf data/
git pull
docker-compose build --no-cache
docker-compose up -d
```

### Verificar portas
```bash
sudo netstat -tlnp | grep 8081
```

---

## 📊 Status Esperado

```
✅ Docker build concluído
✅ 2 containers rodando ("Up")
✅ Backend responde com {"status":"UP"}
✅ Firewall aberto (consegue acessar http://IP:8081)
✅ Usuários criados (pode fazer login)
✅ Banco PostgreSQL sincronizado
```

---

## 🎉 PRÓXIMOS PASSOS

1. Execute o comando `git pull && docker-compose... ` acima
2. Aguarde 10-15 minutos
3. Se tudo ok, abra firewall
4. Acesse `http://SEU_IP:8081`
5. Faça login com credenciais acima
6. Comece a usar! 🚀

---

**Tudo pronto! Execute agora! 💪**
