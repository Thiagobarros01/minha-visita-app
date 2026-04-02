# 🚀 Deploy da Minha Visita App no GCP - Guia Prático

## Prerequisitos
- Instância Linux (Debian) no GCP já criada
- Acesso SSH à instância
- IP público da instância anotado

---

## 📋 Passo 1: Conectar na Instância GCP

```bash
# Substitua SEU_IP_PUBLICO pelo IP da sua instância
ssh -i seu_key.pem thiagosbarrosdev@SEU_IP_PUBLICO
# Ou use a opção "SSH no navegador" do GCP Console
```

---

## 📋 Passo 2: Preparar a Instância

```bash
# Criar pasta do projeto
mkdir -p ~/nevt-minhavisita
cd ~/nevt-minhavisita

# Atualizar sistema
sudo apt update
sudo apt upgrade -y

# Instalar Docker e Docker Compose
sudo apt install -y docker.io docker-compose git

# Adicionar seu usuário ao grupo docker (sem precisar de sudo)
sudo usermod -aG docker $USER
newgrp docker

# Verificar instalação
docker --version
docker-compose --version
```

### ⏱️ Tempo estimado: 3-5 minutos

---

## 📋 Passo 3: Transferir o Código

### Opção A: Clonar do Git (RECOMENDADO)
```bash
cd ~/nevt-minhavisita
git clone https://seu-repositorio-git.com/minhavisita.git .
# Se tiver autenticação:
# git clone https://seu-usuario:seu-token@github.com/seu-repo.git .
```

### Opção B: Transferir via SCP (do seu PC Windows)
```powershell
# Execute no PowerShell do seu PC Windows
cd "C:\caminho\do\seu\projeto"
scp -r ".\*" thiagosbarrosdev@SEU_IP_PUBLICO:~/nevt-minhavisita/
```

### Opção C: Upload via Google Cloud Console
- Vá ao Console GCP → VM Instances → Clique na instância
- Use "Upload file" para enviar um ZIP do projeto

---

## 📋 Passo 4: Verificar Arquivos

```bash
cd ~/nevt-minhavisita
ls -la

# Deve haver:
# - docker-compose.yml
# - Dockerfile
# - pom.xml
# - src/
# - mobile/
# - deploy-gcp.sh (se copiou)
```

---

## 📋 Passo 5: Configurar Firewall (IMPORTANTE)

No **Google Cloud Console**:
1. Vá para **VPC network** → **Firewall rules**
2. Clique em **Create Firewall Rule**
3. Preencha assim:
   - **Name**: `allow-minhavisita`
   - **Direction**: Ingress
   - **Targets**: `All instances in the network`
   - **Source IP ranges**: `0.0.0.0/0` (ou seu IP específico)
   - **Protocols and ports**: TCP `8081`
4. Clique **Create**

Alternativa via gcloud CLI:
```bash
gcloud compute firewall-rules create allow-minhavisita \
  --allow=tcp:8081 \
  --source-ranges=0.0.0.0/0
```

---

## 📋 Passo 6: Rodar o Deploy (AUTOMÁTICO)

Se transferiu o script `deploy-gcp.sh`:

```bash
cd ~/nevt-minhavisita
bash deploy-gcp.sh
```

Este script vai automaticamente:
- ✅ Verificar Docker e Docker Compose
- ✅ Criar pastas de dados
- ✅ Construir imagens
- ✅ Iniciar containers
- ✅ Criar usuários de teste
- ✅ Verificar saúde do sistema

---

## 📋 Passo 7: Rodar o Deploy (MANUAL)

Se preferir fazer passo a passo:

```bash
cd ~/nevt-minhavisita

# Criar pasta de persistência
mkdir -p data/database

# Construir imagens
docker-compose build

# Iniciar containers
docker-compose up -d

# Verificar status
docker-compose ps

# Ver logs
docker-compose logs -f backend
```

### ⏱️ Tempo estimado: 5-10 minutos (dependendo do build)

---

## ✅ Passo 8: Verificar se Tudo Está Funcionando

```bash
# 1. Verificar containers
docker-compose ps
# Ambos devem estar "Up"

# 2. Testar health
curl http://localhost:8081/actuator/health

# 3. Ver logs do backend
docker-compose logs backend | tail -20
```

---

## 🌐 Passo 9: Acessar de Fora (Importante!)

Se quer acessar do seu PC local ou do app mobile:

```bash
# Seu IP público do GCP (copie de algum lugar):
http://SEU_IP_PUBLICO_GCP:8081

# Exemplo:
# http://34.95.224.29:8081/actuator/health
# http://34.95.224.29:8081/swagger-ui.html
```

**No app mobile**, atualize a URL para:
```dart
const String baseUrl = 'http://34.95.224.29:8081';
// ou
const String baseUrl = 'http://SEU_IP_PUBLICO_GCP:8081';
```

---

## 👤 Usuários Criados Automaticamente

```
Email: admin@nevt.com.br
Senha: 123
Perfil: ADMIN

Email: operador@nevt.com.br
Senha: 123
Perfil: OPERADOR
```

---

## 🔧 Troubleshooting

### Backend não inicia
```bash
docker-compose logs backend
# Veja qual é o erro

# Rebuild completo
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

### Porta 8081 já está em uso
```bash
# Ver o que está usando
sudo netstat -tlnp | grep 8081

# Ou mudar porta no docker-compose.yml
# Linha: ports: - "8082:8081"
```

### Banco de dados não conecta
```bash
docker-compose logs db

# Verificar saúde do banco
docker exec minhavisita-db pg_isready -U minhavisita -d minhavisita
```

### Limpar tudo e começar do zero
```bash
docker-compose down -v
docker system prune -a
mkdir -p data/database
docker-compose build --no-cache
docker-compose up -d
```

---

## 📊 Monitoramento Contínuo

```bash
# Ver logs em tempo real
docker-compose logs -f backend

# Ver só erros
docker-compose logs backend | grep -i error

# Verificar uso de memória/CPU
docker stats

# Parar (sem deletar dados)
docker-compose stop

# Resumir
docker-compose start

# Reiniciar
docker-compose restart
```

---

## 🛑 Para Quando Precisar Desligar

```bash
# Parar temporariamente (dados persistem)
docker-compose stop

# Desligar e manter dados
docker-compose down

# Deletar TUDO (cuidado!)
docker-compose down -v
rm -rf data/
```

---

## 📝 Próximos Passos (Opcional)

1. **SSL/HTTPS**: Configurar Let's Encrypt com Nginx reverse proxy
2. **Domínio**: Apontar domínio personalizado para o IP público
3. **Backup**: Automatizar backup do banco PostgreSQL
4. **Logs**: Configurar ELK Stack ou Google Cloud Logging
5. **CI/CD**: Automatizar deploys com Cloud Build

---

## ❓ Dúvidas?

```bash
# Ver todos os containers
docker ps -a

# Ver todas as imagens
docker images

# Ver redes
docker network ls

# Ver volumes
docker volume ls

# Inspecionar container
docker inspect minhavisita-backend
```

**Sucesso no deploy! 🎉**
