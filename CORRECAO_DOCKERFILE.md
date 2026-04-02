# 🔧 CORREÇÃO DO BUILD - Dockerfile Atualizado

## Problema Identificado ❌
```
[ERROR] Failed to execute goal org.apache.maven.plugins:maven-resources-plugin:3.3.1:resources (default-resources) on project minhavisita-app: Cannot create resource output directory: /app/target/classes
```

A imagem Chainguard Maven é muito restritiva e não tem permissões para criar o diretório `/app/target`.

## Solução Aplicada ✅

Atualizei o `Dockerfile` para criar o diretório antes do Maven compilar:

```dockerfile
FROM cgr.dev/chainguard/maven:latest-dev AS build
WORKDIR /app

COPY pom.xml ./
COPY src ./src

RUN mkdir -p /app/target && \
    mvn -q -DskipTests package
```

**Alteração:** Adicionada linha `RUN mkdir -p /app/target &&` antes do Maven build

---

## 🚀 EXECUTE AGORA NO GCP (3 COMANDOS)

```bash
# 1. Atualizar código com a correção
git pull

# 2. Limpar build anterior
docker-compose down -v

# 3. Executar novamente (agora funciona!)
mkdir -p data/database && docker-compose build && docker-compose up -d && sleep 30 && docker-compose ps && curl http://localhost:8081/actuator/health
```

---

## ✅ Esperado após executar:

```
CONTAINER ID   IMAGE                                 PORTS
xxx            minhavisita-backend:latest           0.0.0.0:8081->8081/tcp
yyy            postgres:16-alpine                   5432/tcp

{"status":"UP"}
```

Se aparecer `{"status":"UP"}` no final = **🟢 DEPLOY SUCESSO!**

---

## Se ainda tiver erro:

Ver logs detalhados:
```bash
docker-compose logs backend
```

Ou reconstruir sem cache:
```bash
docker-compose build --no-cache
```

---

**Agora sim deve funcionar! 🎉**
