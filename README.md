# Minha Visita (API)

MVP backend para check-in/check-out por geolocalizacao.

## Como rodar

```powershell
mvn spring-boot:run
```

O servidor sobe em `http://localhost:8080`.

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
curl -X POST http://localhost:8080/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{"nome":"Joao","email":"joao@exemplo.com","senha":"123456"}'
```

```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"joao@exemplo.com","senha":"123456"}'
```

```bash
curl -X POST http://localhost:8080/api/visitas \
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
curl -X POST http://localhost:8080/api/checkins \
  -H "Content-Type: application/json" \
  -d '{
    "visitaId":1,
    "latitude":-23.5506,
    "longitude":-46.6333,
    "dataHora":"2026-04-01T10:05:00-03:00"
  }'
```

```bash
curl -X POST http://localhost:8080/api/checkins/1/checkout \
  -H "Content-Type: application/json" \
  -d '{
    "latitude":-23.5506,
    "longitude":-46.6333,
    "dataHora":"2026-04-01T11:05:00-03:00"
  }'
```

## Banco

Por padrao usa H2 em memoria. Para Postgres, ajuste `spring.datasource.*` em `src/main/resources/application.yml`.

## Observacao sobre login

O endpoint `/auth/login` retorna um token simples (UUID) apenas para MVP. Ainda nao existe middleware de autenticacao validando esse token nas rotas.

## Mobile (Flutter)

O esqueleto do app esta em `mobile/`. Veja `mobile/README.md` para rodar.
