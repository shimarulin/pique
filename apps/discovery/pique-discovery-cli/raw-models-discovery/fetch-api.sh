#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${ENV_FILE:-.env}"
URLS_JSON="${URLS_JSON:-urls.json}"
OUT_DIR="${OUT_DIR:-.}"

[[ -f "$ENV_FILE" ]]  || { echo "✗ нет $ENV_FILE"  >&2; exit 1; }
[[ -f "$URLS_JSON" ]] || { echo "✗ нет $URLS_JSON" >&2; exit 1; }

# --- загрузка .env ---
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

mkdir -p "$OUT_DIR"

while IFS=$'\t' read -r url envname; do
  [[ -n "$url" ]] || continue

  host="${url#*://}"
  host="${host%%/*}"

  # если envName не задан — генерим из хоста: API_EXAMPLE_COM_TOKEN
  if [[ -z "$envname" ]]; then
    envname="$(printf '%s' "$host" | tr '[:lower:].' '[:upper:]_')_TOKEN"
  fi

  token="$(printenv "$envname" || true)"
  if [[ -z "$token" ]]; then
    echo "✗ $envname не задан — пропускаю $url" >&2
    continue
  fi

  outfile="$OUT_DIR/${host}.json"
  echo "→ $url → $outfile  (env: $envname)"

  if curl -fsS "$url" -H "Authorization: Bearer $token" | jq . > "$outfile"; then
    echo "  ✓ ok"
  else
    echo "  ✗ ошибка" >&2
    rm -f "$outfile"
    exit 1
  fi
done < <(jq -r '.[] | [.url, (.envName // "")] | @tsv' "$URLS_JSON")
