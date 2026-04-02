# ✅ PASSO FINAL - DEPLOY COMPLETO

## No GCP, execute isto (copie e cole):

```bash
git pull && docker-compose down -v && mkdir -p data/database && docker-compose build && docker-compose up -d && sleep 30 && docker-compose ps && curl http://localhost:8080/actuator/health
```

---

## ✅ Se terminar com sucesso:

Verá ao final:
```
CONTAINER ID   IMAGE                      PORTS
xxx            minhavisita-backend:latest 0.0.0.0:8080->8080/tcp
yyy            postgres:16-alpine         5432/tcp

{"status":"UP"}
```

---

## 🔓 Depois abra firewall (no GCP Console):

https://console.cloud.google.com/networking/firewalls

**CREATE FIREWALL RULE:**
- Name: `allow-minhavisita`
- Direction: **Ingress**
- Source: `0.0.0.0/0`
- Protocols: **TCP 8081**
- **CREATE**

---

## 🌐 Acesse:

```
http://34.95.224.29:8080
```

---

## 👤 Login:

```
admin@nevt.com.br
123
```

---

## ❌ Se der erro:

Veja em [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

**Tudo pronto! Execute agora! 🚀**
