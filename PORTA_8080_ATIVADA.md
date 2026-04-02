# ✅ STATUS ATUAL - PORTA 8080 ATIVADA

## O que foi feito:

✅ Dockerfile - EXPOSE 8080  
✅ docker-compose.yml - SERVER_PORT:8080 e ports:8080:8080  
✅ mobile/lib/main.dart - Todas 3 URLs atualizadas para 8080  
✅ README.md - Todos os exemplos de curl com 8080  
✅ mobile/README.md - URLs com 8080  
✅ Documentação de deploy - Firewall 8080  

✅ **2 commits feitos:**
- feat: change backend port from 8081 to 8080
- docs: update all references from port 8081 to 8080

---

## Próximo passo NO GCP:

```bash
git pull
docker-compose down -v
mkdir -p data/database
docker-compose build
docker-compose up -d
sleep 30
docker-compose ps
curl http://localhost:8080/actuator/health
```

---

## Firewall (Google Cloud Console):

- **Port: TCP 8080** (não 8081!)
- **Name:** allow-minhavisita
- **Direction:** Ingress
- **Source:** 0.0.0.0/0

---

## Acessar:

```
http://34.95.224.29:8080
```

Login:
- admin@nevt.com.br / 123

---

**Tudo pronto! Execute no GCP agora! 🚀**
