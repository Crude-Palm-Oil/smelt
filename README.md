# smelt

Docker Compose orchestration for the Smelt platform. Smelt is a scan analysis and reporting tool composed of multiple services connected via a Caddy reverse proxy.

## Architecture

| Service | Container | Description |
|---|---|---|
| `ui` | `smelt-analysis-ui` | Next.js frontend |
| `backend` | `smelt-backend` | Configuration and auth API |
| `analysis` | `smelt-analysis-api` | Scan analysis API |
| `analysis-worker` | `smelt-analysis-worker` | Background worker for scan processing (Redis queue) |
| `analysis-redis` | `smelt-analysis-redis` | Redis queue for the analysis worker |
| `reports` | `smelt-reports` | Report generation service (uses Ollama) |
| `reports-ollama` | `smelt-reports-ollama` | Local LLM (Ollama) for AI-generated reports |
| `s3` | `smelt-s3` | RustFS S3-compatible object storage |
| `db` | `smelt-db` | PostgreSQL 14 database |
| `proxy` | `smelt-proxy` | Caddy reverse proxy (ports 80/443) |

## Prerequisites

- Docker running in WSL/Linux/macOS
- Docker Compose

## Deploy

1. Clone this repository and all Smelt service repositories **at the same directory level**:

```bash
git clone https://github.com/Crude-Palm-Oil/smelt
git clone https://github.com/Crude-Palm-Oil/smelt-frontend
git clone https://github.com/Crude-Palm-Oil/smelt-backend
git clone https://github.com/Crude-Palm-Oil/smelt-analysis
git clone https://github.com/Crude-Palm-Oil/smelt-reports
```

The expected layout is:

```
parent-directory/
├── smelt/              ← this repo
├── smelt-frontend/
├── smelt-backend/
├── smelt-analysis/
└── smelt-reports/
```

2. Create a `.env` file in this directory. Copy the example and edit the values:

```bash
cp .env.example .env
```

Key variables to update for production:

| Variable | Description |
|---|---|
| `AUTH_SECRET_KEY` | Secret key used for JWT signing — change this |
| `POSTGRES_PASSWORD` | PostgreSQL password |
| `S3_BUCKET_ACCESS_KEY` / `S3_BUCKET_SECRET_KEY` | RustFS credentials |
| `ANALYSIS_WORKER_CONCURRENCY` | Number of parallel scan workers |
| `TZ` | Timezone for the analysis worker (default: `Australia/Brisbane`) |

3. Start all services:

```bash
docker compose up -d
```

4. Access the web UI at `http://localhost` using the default credentials `test@admin.com:password`.

## Notes

- The Ollama container (`reports-ollama`) is built from the local `ollama.Dockerfile` and may pull a model on first start — this can take some time.
- Object storage buckets used: `configs`, `scans`, and `reports`.
- The database schema is automatically initialised from `schema.sql` on first run.
