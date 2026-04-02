# 🆘 TROUBLESHOOTING - Se o build ainda falhar

## Se receber erro de permissão novamente:

```bash
# Limpar tudo completamente
docker system prune -af --volumes

# Tentar novamente
git pull
docker-compose down -v
docker-compose build --no-cache
```

---

## Se receber erro de "out of memory" ou timeout:

```bash
# Aumentar timeout
docker-compose build --no-cache --build-arg DOCKER_BUILDKIT=1
```

---

## Se Maven não conseguir baixar dependências:

```bash
# Verificar conectividade (no GCP)
ping -c 1 google.com

# Limpar cache Maven
docker exec minhavisita-backend find /root/.m2 -type f -name "*.lastUpdated" -delete
```

---

## Se tudo falhar, alternativa: usar imagem pré-compilada

Se o build continuar falhando, posso:
1. Compilar localmente (no seu PC)
2. Gerar JAR
3. Criar Dockerfile simples que só roda o JAR

---

## Status atual:

✅ Dockerfile atualizado com imagens Eclipse Temurin   
✅ Push realizado  
⏳ Aguardando: `git pull` + `docker-compose build` no GCP

**Próximo passo no GCP:**

```bash
git pull
docker-compose down -v
mkdir -p data/database
docker-compose build
```

Depois me passa:
- ✅ Se terminar com `Successfully tagged minhavisita-backend:latest`
- ❌ Se der erro (mensagem completa)
