#!/usr/bin/env bash
set -Eeuo pipefail

BASE_URL="${SENTINELX_URL:-http://127.0.0.1:${PORT:-3000}}"

health="$(curl --fail --silent --show-error "$BASE_URL/api/health")"
overview="$(curl --fail --silent --show-error "$BASE_URL/api/overview")"

printf 'Health:   %s\n' "$health"
printf 'Overview: %s\n' "$overview"
printf 'Dashboard: %s\n' "$BASE_URL/"
