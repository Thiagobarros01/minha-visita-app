# Deploy no GCP - Passo a Passo

## 1. Instalar Docker e Docker Compose

```bash
# Instalar Docker
sudo apt install -y docker.io docker-compose

# Permitir rodar docker sem sudo (opcional mas recomendado)
sudo usermod -aG docker $USER
newgrp docker

# Verificar instalação
docker --version
docker-compose --version
```

## 2. Clonar o Repositório (ou transferir via Git)

```bash
cd ~/nevt-minhavisita

# Opção A: Se você tem Git configurado
git clone https://seu-repositorio.git .

# Opção B: Se quiser transferir via SCP do seu PC
# Do seu PC Windows (PowerShell):
# scp -r "C:\caminho\do\projeto\*" thiagosbarrosdev@SEU_IP_GCP:~/nevt-minhavisita/
```

## 3. Criar a Pasta de Dados (para persistência)

```bash
mkdir -p data/database
chmod -R 755 data
```

## 4. Configurar Variáveis de Ambiente (Opcional)

Se precisar sobrescrever o IP do CORS (se for diferente de 34.95.224.29):

```bash
# Criar arquivo .env
cat > .env << 'EOF'
APP_CORS_ALLOWED_ORIGIN_PATTERNS=http://localhost:*,http://127.0.0.1:*,http://SEU_IP_PUBLICO_GCP,https://SEU_IP_PUBLICO_GCP
POSTGRES_PASSWORD=sua_senha_segura
EOF
```

## 5. Rodar com Docker Compose

```bash
# Construir a imagem
docker-compose build

# Rodar os containers em background
docker-compose up -d

# Ver logs em tempo real
docker-compose logs -f backend
docker-compose logs -f db

# Parar quando necessário
docker-compose down
```

## 6. Acessar a Aplicação

```bash
# Backend está em http://SEU_IP_GCP:8081
# Health check:
curl http://localhost:8081/actuator/health

# Criar usuários de teste:
curl -X POST http://localhost:8081/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Admin",
    "email": "admin@test.com",
    "senha": "123",
    "perfil": "ADMIN"
  }'
```

## Troubleshooting

```bash
# Ver status dos containers
docker-compose ps

# Acessar logs completos
docker-compose logs backend

# Limpar volumes (cuidado! apaga DB)
docker-compose down -v

# Reconstruir uma imagem
docker-compose build --no-cache

# Entrar no container
docker exec -it minhavisita-backend bash
```
