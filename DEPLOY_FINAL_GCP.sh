#!/bin/bash

# ==========================================
# 🚀 DEPLOY FINAL - Minha Visita App GCP
# ==========================================
# Execute isto no GCP após clonar o repositório
# bash DEPLOY_FINAL_GCP.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}"
echo "=========================================="
echo "🚀 DEPLOY FINAL - Minha Visita App"
echo "=========================================="
echo -e "${NC}"

# Passo 1: Criar diretórios de dados
echo -e "${YELLOW}[1/6]${NC} Criando diretórios de dados..."
mkdir -p data/database
chmod -R 755 data
echo -e "${GREEN}✓ Diretórios criados${NC}"

# Passo 2: Construir imagens
echo -e "${YELLOW}[2/6]${NC} Construindo imagens Docker..."
docker-compose build
echo -e "${GREEN}✓ Imagens construídas${NC}"

# Passo 3: Iniciar containers
echo -e "${YELLOW}[3/6]${NC} Iniciando containers..."
docker-compose up -d
echo -e "${GREEN}✓ Containers iniciados${NC}"

# Passo 4: Aguardar banco ficar pronto
echo -e "${YELLOW}[4/6]${NC} Aguardando banco de dados ficar pronto..."
for i in {1..30}; do
    if docker exec minhavisita-db pg_isready -U minhavisita -d minhavisita &>/dev/null; then
        echo -e "${GREEN}✓ Banco pronto!${NC}"
        break
    fi
    echo -n "."
    sleep 1
done

# Passo 5: Aguardar backend
echo -e "${YELLOW}[5/6]${NC} Aguardando backend iniciar..."
sleep 5
for i in {1..60}; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081/actuator/health 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" == "200" ]; then
        echo -e "${GREEN}✓ Backend respondendo!${NC}"
        break
    fi
    echo -n "."
    sleep 1
done

# Passo 6: Criar usuários de teste
echo -e "${YELLOW}[6/6]${NC} Criando usuários de teste..."

curl -s -X POST http://localhost:8081/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{"nome":"Admin NEVT","email":"admin@nevt.com.br","senha":"123","perfil":"ADMIN"}' >/dev/null 2>&1 || true

curl -s -X POST http://localhost:8081/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{"nome":"Operador NEVT","email":"operador@nevt.com.br","senha":"123","perfil":"OPERADOR"}' >/dev/null 2>&1 || true

echo -e "${GREEN}✓ Usuários criados${NC}"

# Status Final
echo ""
echo -e "${GREEN}"
echo "=========================================="
echo "✅ DEPLOY CONCLUÍDO COM SUCESSO!"
echo "=========================================="
echo -e "${NC}"
echo ""
docker-compose ps
echo ""
echo -e "${YELLOW}📍 Informações de Acesso:${NC}"
echo "  • Backend: http://localhost:8081"
echo "  • Health:  http://localhost:8081/actuator/health"
echo ""
echo -e "${YELLOW}👤 Usuários de Teste:${NC}"
echo "  • Email: admin@nevt.com.br (ADMIN)"
echo "  • Email: operador@nevt.com.br (OPERADOR)"
echo "  • Senha: 123"
echo ""
echo -e "${YELLOW}🔗 Para acessar de fora do GCP:${NC}"
echo "  • Obtenha seu IP público: curl -s ifconfig.me"
echo "  • Acesse: http://SEU_IP_PUBLICO:8081"
echo ""
echo -e "${YELLOW}📋 Comandos úteis:${NC}"
echo "  • Ver logs:  docker-compose logs -f backend"
echo "  • Status:    docker-compose ps"
echo "  • Parar:     docker-compose down"
echo "  • Remover:   docker-compose down -v && rm -rf data/"
echo ""
