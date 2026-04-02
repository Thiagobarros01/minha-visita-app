#!/bin/bash

# Script de Deploy - Minha Visita App no GCP
# Executar: bash deploy-gcp.sh

set -e

echo "=========================================="
echo "Deploy Minha Visita App - GCP"
echo "=========================================="

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Função para log
log_step() {
    echo -e "${GREEN}[PASSO]${NC} $1"
}

log_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

# 1. Verificar Docker
log_step "Verificando Docker..."
if ! command -v docker &> /dev/null; then
    log_error "Docker não está instalado!"
    echo "Instale com: sudo apt install -y docker.io docker-compose"
    exit 1
fi
log_info "Docker versão: $(docker --version)"

# 2. Verificar Docker Compose
log_step "Verificando Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    log_error "Docker Compose não está instalado!"
    echo "Instale com: sudo apt install -y docker-compose"
    exit 1
fi
log_info "Docker Compose versão: $(docker-compose --version)"

# 3. Criar diretórios de dados
log_step "Criando estrutura de diretórios..."
mkdir -p data/database
chmod -R 755 data
log_info "Pasta data/database criada"

# 4. Parar containers antigos (se houver)
log_step "Parando containers antigos..."
docker-compose down 2>/dev/null || true
log_info "Containers parados"

# 5. Limpar imagens antigas (opcional)
# docker system prune -f

# 6. Construir imagem
log_step "Construindo imagem Docker..."
docker-compose build --no-cache
log_info "Imagem construída com sucesso"

# 7. Iniciar containers
log_step "Iniciando containers..."
docker-compose up -d
log_info "Containers iniciados em background"

# 8. Aguardar banco de dados
log_step "Aguardando banco de dados ficar pronto..."
for i in {1..30}; do
    if docker exec minhavisita-db pg_isready -U minhavisita -d minhavisita &> /dev/null; then
        log_info "Banco de dados pronto!"
        break
    fi
    echo -n "."
    sleep 1
done

# 9. Aguardar backend
log_step "Aguardando backend iniciar..."
sleep 5
for i in {1..60}; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081/actuator/health 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" == "200" ]; then
        log_info "Backend pronto!"
        break
    fi
    echo -n "."
    sleep 1
done

# 10. Criar usuários de teste
log_step "Criando usuários de teste..."

create_user() {
    local nome=$1
    local email=$2
    local perfil=$3
    
    RESPONSE=$(curl -s -X POST http://localhost:8081/api/usuarios \
      -H "Content-Type: application/json" \
      -d "{\"nome\": \"$nome\", \"email\": \"$email\", \"senha\": \"123\", \"perfil\": \"$perfil\"}")
    
    if echo "$RESPONSE" | grep -q "id"; then
        log_info "✓ Usuário criado: $email ($perfil)"
    else
        log_info "✓ Usuário já existe: $email ($perfil)"
    fi
}

create_user "Admin NEVT" "admin@nevt.com.br" "ADMIN"
create_user "Operador NEVT" "operador@nevt.com.br" "OPERADOR"

# 11. Status final
echo ""
log_step "Deploy concluído com sucesso!"
echo ""
echo "=========================================="
echo "📍 Endpoints disponíveis:"
echo "=========================================="
echo "  Backend: http://localhost:8081"
echo "  Health:  http://localhost:8081/actuator/health"
echo "  Docs:    http://localhost:8081/swagger-ui.html"
echo ""
echo "=========================================="
echo "👤 Usuários de teste:"
echo "=========================================="
echo "  Email: admin@nevt.com.br (ADMIN)"
echo "  Email: operador@nevt.com.br (OPERADOR)"
echo "  Senha: 123"
echo ""
echo "=========================================="
echo "🔍 Comandos úteis:"
echo "=========================================="
echo "  Ver logs:       docker-compose logs -f backend"
echo "  Ver status:     docker-compose ps"
echo "  Parar:          docker-compose down"
echo "  Remover dados:  docker-compose down -v"
echo "=========================================="
