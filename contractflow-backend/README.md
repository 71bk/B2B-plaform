# ContractFlow Backend

Spring Boot backend for ContractFlow, a B2B contract and refund workflow management system.

## Structure

```text
src/main/java/com/contractflow
├── common
├── auth
├── users
├── clients
├── projects
├── refunds
├── files
├── dashboard
├── audit
├── notifications
└── ai
```

## Run With Docker

The project is intended to run through Docker Compose during local integration work:

```bash
docker compose up --build backend
```

This starts:

| Service | Port |
|---|---|
| backend | `8080` |
| postgres | `5432` |

Health check:

```text
http://localhost:8080/api/health
```

## IntelliJ Run

For a unified Docker setup, prefer running from the terminal with Docker Compose instead of IntelliJ's local JVM run button:

```bash
docker compose up --build backend
```

IntelliJ can still be used for editing, Maven import, navigation, and tests.

Docker defaults:

| Setting | Value |
|---|---|
| Profile | `postgres` |
| App port | `8080` |
| Database host inside Docker | `postgres:5432` |
| Database exposed on host | `localhost:5432` |
| Database | `contractflow` |
| Username | `contractflow` |
| Password | `contractflow` |

## First Implementation Target

1. User / Role / Permission entities.
2. Login / Refresh Token.
3. Refund Case entity and state transition service.
4. Status Log and Audit Log writes.
