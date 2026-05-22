# smelt

## Prerequisites

- Docker running in WSL/Linux/macOS
- Docker Compose

## Deploy

1. Clone the Smelt services **outside** of this directory.

```bash
git clone https://github.com/Crude-Palm-Oil/smelt-frontend
git clone https://github.com/Crude-Palm-Oil/smelt-backend
git clone https://github.com/Crude-Palm-Oil/smelt-analysis
git clone https://github.com/Crude-Palm-Oil/smelt-reports
```

2. Create an `.env` file on this directory to be used by Docker Compose. An example is provided in `.env.example`.

3. Run the services using:

```bash
docker compose up -d
```

4. Access the website on `localhost` using the default credentials `test@admin.com:password`.
