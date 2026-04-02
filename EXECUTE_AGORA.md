# 🎯 PRÓXIMO PASSO: EXECUTE ISTO NO GCP

## Copie e cole isto NO TERMINAL (uma única linha):

```bash
git pull && docker-compose down -v && mkdir -p data/database && docker-compose build && docker-compose up -d && sleep 30 && docker-compose ps && curl http://localhost:8080/actuator/health
```

---

## O que este comando faz:

1. ✅ Baixa correção do Dockerfile do GitHub
2. ✅ Remove containers antigos
3. ✅ Cria pasta de dados
4. ✅ **Constrói imagem com correção** (5-10 min)
5. ✅ Inicia containers
6. ✅ Aguarda 30 seg
7. ✅ Mostra status
8. ✅ Testa backend

---

## ✅ Esperado ao final:

```
CONTAINER ID   IMAGE                      PORTS
abc123         minhavisita-backend:latest 0.0.0.0:8080->8080/tcp
def456         postgres:16-alpine         5432/tcp

{"status":"UP"}
```

**Se aparecer:** `{"status":"UP"}` = 🟢 **SUCESSO!**

---

## 🔓 Depois, abra firewall (5 cliques no GCP Console):

1. Vá: https://console.cloud.google.com/networking/firewalls
2. **CREATE FIREWALL RULE**
3. Name: `allow-minhavisita`
4. Direction: **Ingress** | Source: `0.0.0.0/0` | TCP: `8080`
5. **CREATE**

---

## 🌐 Acesse seu app:

```bash
# No GCP, obtenha seu IP:
curl -s ifconfig.me

# No navegador:
http://SEU_IP_RETORNADO:8080
```

---

## 👤 Login:

```
Email: admin@nevt.com.br
Senha: 123
```

---

**Agora execute o comando de uma linha acima! 🚀**
