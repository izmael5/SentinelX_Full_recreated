#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"
DB_NAME="${SENTINELX_DB_NAME:-sentinelx}"
DB_HOST="${SENTINELX_DB_HOST:-127.0.0.1}"
DB_PORT="${SENTINELX_DB_PORT:-3306}"

if ! command -v mysql >/dev/null 2>&1; then
  echo "mysql client not found. Install MySQL client/server first, then rerun this script." >&2
  exit 1
fi

if [[ -z "${MYSQL_ROOT_PASSWORD+x}" ]]; then
  read -r -s -p "Local MySQL root password: " MYSQL_ROOT_PASSWORD
  echo
fi
export MYSQL_ROOT_PASSWORD

if ! MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql --protocol=tcp -h "$DB_HOST" -P "$DB_PORT" -u root -e "SELECT 1" >/dev/null 2>&1; then
  echo "Could not authenticate to MySQL as root over $DB_HOST:$DB_PORT." >&2
  echo "Check that MySQL is running and that the supplied password is correct." >&2
  exit 1
fi

MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql --protocol=tcp -h "$DB_HOST" -P "$DB_PORT" -u root <<SQL
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
SQL

MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql --protocol=tcp -h "$DB_HOST" -P "$DB_PORT" -u root "$DB_NAME" < "$ROOT_DIR/backend/migrations/001_initial.sql"

DATABASE_URL="$(MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" DB_HOST="$DB_HOST" DB_PORT="$DB_PORT" DB_NAME="$DB_NAME" python3 - <<'PY'
import os
from urllib.parse import quote
password = quote(os.environ['MYSQL_ROOT_PASSWORD'], safe='')
host = os.environ['DB_HOST']
port = os.environ['DB_PORT']
db = os.environ['DB_NAME']
print(f"mysql+pymysql://root:{password}@{host}:{port}/{db}")
PY
)"

umask 077
cat > "$ENV_FILE" <<EOF
PORT=3000
DATABASE_URL=$DATABASE_URL
# Optional managed runtime AI adapter
MANUS_API_URL=
MANUS_API_KEY=
# Optional Manus OAuth application login
MANUS_PROJECT_ID=
MANUS_OAUTH_PORTAL_URL=
MANUS_OAUTH_API_URL=
MANUS_JWT_SECRET=
EOF

chmod 600 "$ENV_FILE"
echo "Local MySQL database '$DB_NAME' is ready."
echo "Wrote credentials to $ENV_FILE (this file is ignored by Git)."
