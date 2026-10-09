# SentinelX Security Operations

SentinelX is a mobile-first defensive security operations dashboard for websites and networks that you own or are explicitly authorized to assess.

## Included in this first build

- Authorized target registry with scope notes
- Safe, non-destructive website posture checks
- Findings triage and explainable risk scoring
- Live dashboard events over WebSockets
- Optional AI research summaries through the managed runtime API
- MySQL persistence, Dockerfile, Docker Compose, and YAML configuration

## Safety boundary

SentinelX intentionally does not execute unrestricted exploits, brute-force credentials, deliver payloads, create persistence, or scan arbitrary targets. Assessment jobs only run for enabled records in the target registry and are rate-limited. Any future intrusive testing must be separately approved and restricted to a designated test scope.

## Local run with Docker

```bash
cp .env.example .env
docker compose up --build
```

Open `http://localhost:3000`.

## Local run with your local MySQL root account
This mode uses the MySQL server installed on your computer. The setup script asks for the root password without echoing it, creates the `sentinelx` database, applies the schema, and writes a URL-encoded connection string to `.env`. The password is not written to the repository and `.env` is ignored by Git.

```bash
git clone <your-repository-url>
cd SentinelX_Full
chmod +x scripts/*.sh
./scripts/setup-local-mysql.sh
./scripts/run-local.sh
```

In a second terminal, verify the running service:

```bash
cd SentinelX_Full
./scripts/check-local.sh
```

Open `http://localhost:3000`.

If your MySQL server uses a different host, port, or database name, set these before setup:

```bash
SENTINELX_DB_HOST=127.0.0.1 SENTINELX_DB_PORT=3306 SENTINELX_DB_NAME=sentinelx ./scripts/setup-local-mysql.sh
```

## Local run without the helper script

```bash
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
export DATABASE_URL='mysql+pymysql://root:URL_ENCODED_PASSWORD@127.0.0.1:3306/sentinelx'
uvicorn backend.app.main:app --host 0.0.0.0 --port 3000 --reload
```

## Push every project file and folder to GitHub
Create an empty repository on GitHub first. Do not create or upload `.env`; it contains your local database password.

```bash
cd SentinelX_Full
git init
git branch -M main
git add .
git status --short
git commit -m "Recreate SentinelX security operations system"
git remote add origin https://github.com/<YOUR_USERNAME>/<YOUR_REPOSITORY>.git
git push -u origin main
```

For future changes:

```bash
git add .
git commit -m "Describe the change"
git push
```

Before the first push, confirm that `.env` is not staged:

```bash
git status --short --ignored
git diff --cached --name-only
```

If `.env` was ever staged accidentally, remove it from Git tracking before pushing:

```bash
git restore --staged .env
git rm --cached .env
```

## Runtime configuration

- `DATABASE_URL`: MySQL-compatible DSN
- `MANUS_API_URL` and `MANUS_API_KEY`: optional managed AI runtime adapter
- `MANUS_PROJECT_ID`, `MANUS_OAUTH_PORTAL_URL`, `MANUS_OAUTH_API_URL`, `MANUS_JWT_SECRET`: optional managed account login integration
- `PORT`: listener port, default `3000`

## API highlights

- `GET /api/health`
- `GET /api/overview`
- `GET/POST /api/targets`
- `GET /api/findings`
- `POST /api/scan-jobs`
- `POST /api/research/brief`
- `WS /api/ws/events`
