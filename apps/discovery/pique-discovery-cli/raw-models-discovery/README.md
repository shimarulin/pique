# fetch-api

A small shell script that fetches JSON from a list of API endpoints, formats
the responses with `jq`, and saves each one to a file named after the host.

Reads API tokens from a `.env` file, so secrets never live inside the script
or the URL list. Works on **Arch Linux** and **macOS**, with both **bash** and
**zsh**.

## Features

- Endpoint list is defined in a JSON file, one object per URL.
- Tokens are pulled from environment variables loaded from `.env`.
- Per-endpoint `envName` lets you pick which variable to use; otherwise the
  name is auto-derived from the host.
- Responses are pretty-printed with `jq` and saved as `<host>.json`.
- Optional per-endpoint custom auth header (`x-api-key`, etc.).
- Fails fast: on the first HTTP error or invalid response the script exits.
- No secrets, no partial output files: they are removed on failure.

## Requirements

| Tool  | Notes                                                       |
|-------|-------------------------------------------------------------|
| `jq`  | Arch: `sudo pacman -S jq` · macOS: `brew install jq`        |
| `curl`| Ships with Arch and macOS                                   |
| bash  | 3.2+ (macOS default is fine) or zsh 5.x                     |

The script uses only POSIX-friendly primitives (`tr`, `printenv`,
`while read`, process substitution), so it runs unchanged under both shells,
including the ancient `/bin/bash` 3.2 that ships with macOS.

## Layout

```
.
├── fetch-api.sh     # the script
├── urls.json        # list of endpoints
├── .env             # tokens (gitignored)
└── README.md
```

## Configuration

### `urls.json`

An array of objects. Each object must contain a `url`. Optional fields:

| Field     | Description                                                              |
|-----------|--------------------------------------------------------------------------|
| `url`     | **Required.** Full endpoint URL.                                         |
| `envName` | Name of the environment variable holding the token. If omitted, derived from the host as `API_EXAMPLE_COM_TOKEN`. |
| `header`  | HTTP header name for the token. Defaults to `Authorization` with a `Bearer ` prefix. Any other value is sent as `<header>: <token>`. |

Example:

```json
[
  { "url": "https://api.example.com/v1/models", "envName": "EXAMPLE_COM_TOKEN" },
  { "url": "https://api.other.com/v2/users" },
  { "url": "https://api.third.com/v1/items", "envName": "THIRD_KEY", "header": "x-api-key" }
]
```

For the second entry, the script looks up `API_OTHER_COM_TOKEN`.

### `.env`

Plain `KEY=VALUE` lines. Loaded via `set -a; source .env; set +a`, so every
variable becomes exported.

```
EXAMPLE_COM_TOKEN=sk-xxxxxxxxxxxxxxxx
API_OTHER_COM_TOKEN=sk-yyyyyyyyyyyyyyyy
THIRD_KEY=zzzzzzzzzzzz
```

> Add `.env` and `*.json` (the responses) to `.gitignore`.

### Environment variables of the script itself

| Variable   | Default     | Purpose                       |
|------------|-------------|-------------------------------|
| `ENV_FILE` | `.env`      | Path to the secrets file.     |
| `URLS_JSON`| `urls.json` | Path to the endpoint list.    |
| `OUT_DIR`  | `.`         | Directory for output files.   |

## Usage

```bash
chmod +x fetch-api.sh
./fetch-api.sh
```

Sample run:

```
→ https://api.example.com/v1/models → ./api.example.com.json  (env: EXAMPLE_COM_TOKEN)
  ✓ ok
→ https://api.other.com/v2/users → ./api.other.com.json  (env: API_OTHER_COM_TOKEN)
  ✓ ok
→ https://api.third.com/v1/items → ./api.third.com.json  (env: THIRD_KEY)
  ✓ ok
```

Override paths:

```bash
ENV_FILE=.env.prod URLS_JSON=urls.prod.json OUT_DIR=out ./fetch-api.sh
```

## How it works

1. Validates that `.env` and `urls.json` exist, and that `urls.json` is an
   array whose every element has a `url` field.
2. Exports every variable from `.env`.
3. For each entry:
   - Extracts the host from the URL (`https://api.example.com/v1/...` →
     `api.example.com`).
   - Picks the token variable: `envName` if present, otherwise
     `HOST_UPPER_SNAKE_TOKEN`.
   - Looks the token up with `printenv`. If it is missing, logs a warning and
     skips the entry.
   - `curl -fsS` fetches the URL with the auth header. `-f` makes curl fail
     (non-zero exit) on HTTP ≥ 400, so error HTML never reaches `jq`.
   - `jq .` pretty-prints the response into `<host>.json`.
   - On failure the partial output file is removed and the script exits.

## Design notes

- **Why `printenv` instead of `${!var}`?** Indirection (`${!var}` in bash,
  `${(P)var}` in zsh) is shell-specific, and bash 3.2 (macOS default) does
  not support the `^^` uppercase form either. `printenv` and `tr` are portable.
- **Why a JSON list instead of a plain text file?** It scales to extra
  per-endpoint fields (`envName`, `header`, and anything you add later)
  without changing the parsing loop.
- **Why `while IFS=$'\t' read …`?** `jq -r … | @tsv` emits one record per
  line with tab-separated fields. Tabs cannot appear in URLs or variable
  names, so this is safer than space or comma separation.

## Extending

### Extra per-endpoint field: query parameters

```json
{ "url": "https://api.example.com/v1/models", "query": { "limit": 100 } }
```

```bash
while IFS=$'\t' read -r url envname header query; do
  ...
  if [[ -n "$query" ]]; then
    url="${url}?${query}"
  fi
done < <(jq -r '.[] | [
  .url,
  (.envName // ""),
  (.header // ""),
  ((.query // {}) | to_entries | map("\(.key)=\(.value)") | join("&"))
] | @tsv' "$URLS_JSON")
```

### POST requests

Add a `method` and `body` field to the JSON and map them onto `curl -X` /
`--data`, or keep a separate list for POST endpoints. The rest of the script
stays the same.

### Custom auth header per endpoint

Some providers do not use `Authorization: Bearer …`. For example, Anthropic
wants `x-api-key: <token>`, and some internal gateways want a raw token with
no scheme. Add a `header` field to the endpoint entry and branch on it:

```json
[
  { "url": "https://api.example.com/v1/models", "envName": "EXAMPLE_COM_TOKEN" },
  { "url": "https://api.anthropic.com/v1/models", "envName": "ANTHROPIC_KEY", "header": "x-api-key" }
]
```

```bash
while IFS=$'\t' read -r url envname header; do
  [[ -n "$url" ]] || continue

  host="${url#*://}"
  host="${host%%/*}"

  if [[ -z "$envname" ]]; then
    envname="$(printf '%s' "$host" | tr '[:lower:].' '[:upper:]_')_TOKEN"
  fi

  token="$(printenv "$envname" || true)"
  [[ -n "$token" ]] || { echo "✗ $envname не задан — пропускаю $url" >&2; continue; }

  # Build the auth header. Default = Authorization: Bearer <token>.
  if [[ -z "$header" || "$header" == "Authorization" ]]; then
    auth_hdr="Authorization: Bearer $token"
  else
    auth_hdr="$header: $token"
  fi

  outfile="$OUT_DIR/${host}.json"
  echo "→ $url → $outfile  (env: $envname, header: ${header:-Authorization})"

  if curl -fsS "$url" -H "$auth_hdr" | jq . > "$outfile"; then
    echo "  ✓ ok"
  else
    echo "  ✗ ошибка" >&2
    rm -f "$outfile"
    exit 1
  fi
done < <(jq -r '.[] | [.url, (.envName // ""), (.header // "")] | @tsv' "$URLS_JSON")
```

Two things to note:

- The three-column TSV must always have three fields, even when `header` is
  absent — that is what `(.header // "")` guarantees. Without it `@tsv`
  would collapse the row to two columns and `read` would leave `header`
  unset from the previous iteration.
- If you want to support raw tokens (`-H "x-api-key: <token>"` with no
  prefix), add a fourth field such as `authStyle: "raw"` and branch again:

  ```bash
  if [[ "$style" == "raw" ]]; then
    auth_hdr="$header: $token"
  else
    auth_hdr="$header: Bearer $token"
  fi
  ```

### Input JSON validation

The loop is happy to run on whatever `jq` manages to extract — but if
`urls.json` is malformed, or an entry is missing `url`, the failure happens
in the middle of the run, after some endpoints have already been hit. Better
to fail once, up front, with a readable message.

Add this block right after the file-existence checks:

```bash
if ! jq -e '
  type == "array"
  and length > 0
  and all(.[];
    (type == "object")
    and has("url")
    and (.url | type == "string" and startswith("http"))
    and ((.envName // "") | type == "string")
    and ((.header  // "") | type == "string")
  )
' "$URLS_JSON" >/dev/null; then
  echo "✗ $URLS_JSON: ожидался непустой массив объектов вида" >&2
  echo '  { "url": "https://…", "envName": "OPTIONAL", "header": "OPTIONAL" }' >&2
  exit 1
fi
```

What this checks:

- The top-level value is a non-empty array.
- Every element is an object with a `url` field.
- `url` is a string that starts with `http` (catches typos like `htp://` or
  a bare `api.example.com`).
- `envName` and `header`, if present, are strings (so `"envName": 42` is
  rejected early).

On failure, `jq -e` exits non-zero and prints nothing to stdout (thanks to
the `>/dev/null`), while the script prints its own diagnostic. On success,
the script proceeds to load `.env` and start fetching.

If you want the failure message to include the exact JSON path that failed,
drop the `-e` and pipe through `jq` twice, or use `jq 'paths(...)'` — but for
a personal fetch script, the message above is usually enough.

## Troubleshooting

| Symptom                                     | Fix                                                                 |
|---------------------------------------------|---------------------------------------------------------------------|
| `✗ EXAMPLE_COM_TOKEN не задан`              | Check the variable name in `.env` matches `envName` (or the derived name). |
| `jq: error: … invalid JSON`                 | The server returned non-JSON. Run `curl -s <url>` by hand to inspect. |
| `parse error: …` on `urls.json`             | Validate with `jq . urls.json`.                                     |
| Works in zsh, fails in bash (or vice versa) | Ensure `#!/usr/bin/env bash` and that `bash --version` is 3.2+.     |

## License

MIT — do whatever you want.
