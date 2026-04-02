# Minha Visita (API)

MVP backend para check-in/check-out por geolocalizacao.

## Como rodar

Execute este comando na raiz do projeto, onde fica o `pom.xml`:

```powershell
mvn spring-boot:run
```

O servidor sobe em `http://localhost:8081`.

Depois, rode o app Flutter em `mobile/` para consumir essa API.

## Rodar com Docker Compose (backend + banco)

Na raiz do projeto:

```powershell
docker compose up -d --build
```

Isso sobe:

- `backend` (Spring Boot) em `http://localhost:8081`
- `db` (PostgreSQL) em `localhost:5432`

Comandos uteis:

```powershell
# ver status
docker compose ps

# ver logs
docker compose logs -f backend
docker compose logs -f db

# parar mantendo dados do banco
docker compose down

# parar removendo volume (zera banco)
docker compose down -v
```

## Endpoints principais

- `POST /api/usuarios`
- `GET /api/usuarios`
- `POST /auth/login`
- `POST /api/visitas`
- `GET /api/visitas?usuarioId={id}&data=YYYY-MM-DD`
- `GET /api/visitas/{id}`
- `POST /api/checkins`
- `POST /api/checkins/{id}/checkout`

## Exemplo rapido (curl)

```bash
curl -X POST http://localhost:8081/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{"nome":"Joao","email":"joao@exemplo.com","senha":"123456"}'
```

```bash
curl -X POST http://localhost:8081/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"joao@exemplo.com","senha":"123456"}'
```

```bash
curl -X POST http://localhost:8081/api/visitas \
  -H "Content-Type: application/json" \
  -d '{
    "usuarioId":1,
    "clienteNome":"Cliente A",
    "endereco":"Rua 1",
    "latitude":-23.55052,
    "longitude":-46.633308,
    "dataAgendada":"2026-04-01T10:00:00-03:00",
    "raioMetros":100
  }'
```

```bash
curl -X POST http://localhost:8081/api/checkins \
  -H "Content-Type: application/json" \
  -d '{
    "visitaId":1,
    "latitude":-23.5506,
    "longitude":-46.6333,
    "dataHora":"2026-04-01T10:05:00-03:00"
  }'
```

```bash
curl -X POST http://localhost:8081/api/checkins/1/checkout \
  -H "Content-Type: application/json" \
  -d '{
    "latitude":-23.5506,
    "longitude":-46.6333,
    "dataHora":"2026-04-01T11:05:00-03:00"
  }'
```

## Banco

Por padrao fora do Docker usa H2 em arquivo local (`./data/minhavisita`).
No Docker Compose, o backend usa PostgreSQL via variaveis de ambiente.

## Observacao sobre login

O endpoint `/auth/login` retorna um token simples (UUID) apenas para MVP. Ainda nao existe middleware de autenticacao validando esse token nas rotas.

## Mobile (Flutter)

O esqueleto do app esta em `mobile/`. Veja `mobile/README.md` para rodar.
