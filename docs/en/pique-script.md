# The pique Launcher Script

This document describes how `bin/pique` works, why it makes certain decisions, and how to use its features.

## Overview

The `pique` command is a thin bash script. It:

1. Finds the repository root (following symlinks).
2. Loads environment variables from `.env` files.
3. Renders template files (`.template` suffix).
4. Sets `PI_CODING_AGENT_DIR` to the profile directory.
5. Executes Pi with all arguments passed through.

The script has no npm dependencies. It requires only bash and standard Unix tools.

## Why These Features Exist

### Environment Loading

Pi does not load `.env` files. If you store API keys in `.env`, they must be exported to the environment before Pi starts.

The script loads `.env` files in this order:

1. `profiles/<name>/.env` — profile-specific keys (highest priority).
2. `$PIQUE_ROOT/.env` — repository-wide keys (fallback).

Existing shell variables are **never overwritten**. This lets you override `.env` values from the command line:

```bash
PROVIDER_PRIMARY_API_KEY=temp-key pique private-providers
```

### Template Rendering

Pi's `models.json` supports `$VAR` interpolation only in `apiKey` and `headers` values. It does **not** support interpolation in:

- `baseUrl`
- Provider keys (the names in the `providers` object)
- `defaultModel` in `settings.json`

This means you cannot hide a corporate endpoint URL behind an environment variable using Pi's native syntax.

Template rendering solves this. The script generates real `models.json` and `settings.json` files from `.template` files before Pi starts. The generated files contain actual values, not variable references.

**Use this when:**

- You need to hide endpoint URLs from the public repository.
- You need to change provider names dynamically (primary/fallback switching).
- You need to inject numeric values (context window, cost) from variables.

**Do not use this when:**

- Your configuration is not sensitive. Use plain `models.json` and `$VAR` in `apiKey` only.
- You do not need dynamic provider switching.

## Template Syntax

Templates use shell-style variable references. Both forms work:

```
${VARIABLE_NAME}
$VARIABLE_NAME
```

In JSON templates, prefer `${VARIABLE_NAME}` (with braces). It is unambiguous when followed by text.

Example `models.json.template`:

```json
{
  "providers": {
    "primary": {
      "baseUrl": "${PROVIDER_PRIMARY_BASE_URL}",
      "api": "openai-completions",
      "apiKey": "${PROVIDER_PRIMARY_API_KEY}",
      "models": [
        {
          "id": "${MODEL_PRIMARY_ID}",
          "contextWindow": ${MODEL_PRIMARY_CONTEXT_WINDOW},
          "maxTokens": ${MODEL_PRIMARY_MAX_TOKENS}
        }
      ]
    }
  }
}
```

Note: numeric values (like `contextWindow`) do not need quotes. The template engine replaces `${VAR}` with the variable's value directly.

## Tool Selection for Rendering

The script uses the first available tool from this list:

| Priority | Tool | Availability | Notes |
|----------|------|-------------|-------|
| 1 | `envsubst` | gettext package | Simplest, handles both `$VAR` and `${VAR}` |
| 2 | `perl` | Pre-installed on macOS, common on Linux | Full regex support, handles edge cases |
| — | `sed` | Always available | **Not used** — cannot substitute environment variable values |

### Why not sed?

`sed` performs text substitution but cannot look up environment variables. A sed command like:

```bash
sed 's/${VAR}/value/g' template
```

requires you to know `value` in advance. It cannot read from `$VAR` at runtime.

We tested this approach and removed it. It produced files with variable names instead of values.

### What happens without perl or envsubst?

The script prints an error and exits:

```
Error: Cannot render template profiles/private-providers/models.json.template
Neither perl nor envsubst is available.
Install one of them, or create profiles/private-providers/models.json manually.
```

Pi does not start with a broken configuration. This is intentional — silent failure is worse than loud failure.

**To fix:**

```bash
# macOS (perl is pre-installed, this should not happen)
# Linux: install one of:
sudo apt-get install gettext     # provides envsubst
sudo dnf install perl            # provides perl
```

## Template Files vs Generated Files

| File type | Commited to Git? | Why |
|-----------|------------------|-----|
| `*.template` | ✅ Yes | Contains structure, no secrets |
| Generated (`models.json`, `settings.json`) | ❌ No (in `.gitignore`) | Contains real values, may contain secrets |

The `.gitignore` in each profile directory excludes:

```
.env
models.json
settings.json
sessions/
auth.json
```

## Switching Providers

### Primary/Fallback Pattern

Define both providers in the template with the same models:

```json
{
  "providers": {
    "primary": {
      "baseUrl": "${PROVIDER_PRIMARY_BASE_URL}",
      "apiKey": "${PROVIDER_PRIMARY_API_KEY}",
      "models": [
        { "id": "${MODEL_ID}", "contextWindow": 200000 }
      ]
    },
    "fallback": {
      "baseUrl": "${PROVIDER_FALLBACK_BASE_URL}",
      "apiKey": "${PROVIDER_FALLBACK_API_KEY}",
      "models": [
        { "id": "${MODEL_ID}", "contextWindow": 200000 }
      ]
    }
  }
}
```

In `.env`:

```env
PROVIDER_PRIMARY_BASE_URL=https://gateway-a.corp.com/v1
PROVIDER_PRIMARY_API_KEY=sk-key-a
PROVIDER_FALLBACK_BASE_URL=https://gateway-b.corp.com/v1
PROVIDER_FALLBACK_API_KEY=sk-key-b
```

To switch which is primary:

1. Edit `.env` — swap the URLs and keys.
2. Run `pique private-providers` again.

The generated `models.json` updates with new values.

### Models for Specific Providers

Add more providers to the template with their own models:

```json
{
  "providers": {
    "primary": {
      "baseUrl": "${PROVIDER_PRIMARY_BASE_URL}",
      "apiKey": "${PROVIDER_PRIMARY_API_KEY}",
      "models": [
        { "id": "claude-sonnet-4-5", "contextWindow": 200000 }
      ]
    },
    "image-provider": {
      "baseUrl": "${PROVIDER_IMAGE_BASE_URL}",
      "apiKey": "${PROVIDER_IMAGE_API_KEY}",
      "models": [
        { "id": "flux-pro", "input": ["text", "image"] }
      ]
    }
  }
}
```

Each provider has its own models. Switch between them with `/model` inside Pi.

## Order of Operations

When you run `pique <profile>`:

```
1. Resolve repository root
   ├─ Follow symlinks to find the real script location
   ├─ Check PIQUE_ROOT environment variable
   └─ Expand tilde (~) if present

2. Validate directories
   ├─ Check PIQUE_ROOT exists
   └─ Check profiles/ subdirectory exists

3. Parse arguments
   ├─ --help, --list, --diff, --version → execute and exit
   └─ <profile> → continue

4. Validate profile
   └─ Check profiles/<name>/ directory exists

5. Load environment
   ├─ Load profiles/<name>/.env (if exists)
   └─ Load $PIQUE_ROOT/.env (if profile has none)

6. Render templates
   ├─ Find all *.template files in profile directory
   ├─ For each: render to same name without .template
   └─ Write only if content changed

7. Set Pi environment
   ├─ export PI_CODING_AGENT_DIR=<profile-dir>
   └─ export PI_CODING_AGENT_SESSION_DIR (if sessions/ exists)

8. Resolve Pi binary
   ├─ Try: mise which pi (from PIQUE_ROOT)
   └─ Fallback: command -v pi (system PATH)

9. Execute
   └─ exec $PI_BIN "$@"
```

## Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| `PIQUE_ROOT does not exist` | Environment variable points to wrong path | Check the variable, or unset it |
| `profiles directory not found` | Repository structure is broken | Re-clone, or check PIQUE_ROOT |
| `profile 'X' not found` | Typo, or profile missing | Run `pique --list` |
| `Cannot render template` | No perl or envsubst available | Install gettext (envsubst) or perl |
| `'pi' binary not found` | Pi not installed, or mise not configured | Run `cd $PIQUE_ROOT && mise install` |

## Test Cases

Run these to verify the script works:

```bash
# Test 1: Basic launch
pique minimal
# Expected: Pi starts, no .env loaded, no templates rendered

# Test 2: Environment loading
echo "TEST_VAR=hello" > profiles/minimal/.env
pique minimal
# Inside Pi, run: ! echo $TEST_VAR
# Expected: hello

# Test 3: Template rendering
cat > profiles/minimal/settings.json.template << 'EOF'
{
  "description": "Test: ${TEST_VAR}"
}
EOF
pique minimal
# Expected: settings.json contains "Test: hello"
# Clean up: rm profiles/minimal/settings.json.template profiles/minimal/settings.json

# Test 4: Unset variable
unset TEST_VAR
pique minimal
# Expected: settings.json contains "Test: " (empty value)

# Test 5: Quoted values in .env
echo 'QUOTED="with quotes"' > profiles/minimal/.env
pique minimal
# Inside Pi, run: ! echo $QUOTED
# Expected: with quotes (quotes stripped)

# Test 6: Shell variable precedence
export TEST_VAR="from-shell"
echo "TEST_VAR=from-env-file" > profiles/minimal/.env
pique minimal
# Inside Pi, run: ! echo $TEST_VAR
# Expected: from-shell (shell wins)
# Clean up: unset TEST_VAR; rm profiles/minimal/.env

# Test 7: Symlink resolution
ln -sf /real/path/to/pique ~/.local/bin/pique
pique --list
# Expected: works, PIQUE_ROOT is /real/path/to/pique

# Test 8: Missing rendering tool
# (simulate by hiding perl and envsubst)
PATH=/usr/bin:/bin pique private-providers
# Expected: clear error message, exit code 1

# Test 9: Diff excludes generated files
pique --diff minimal development
# Expected: shows .template files, not generated .json

# Test 10: Version
pique --version
# Expected: prints pique location and Pi version
```

## Relationship to Pi Documentation

This script adds functionality on top of Pi. Pi's own behavior is documented at:

- [Models configuration](https://pi.dev/docs/latest/models) — `models.json` syntax, `$VAR` interpolation limits
- [Environment variables](https://pi.dev/docs/latest/environment-variables) — what Pi sets and reads
- [Providers](https://pi.dev/docs/latest/providers) — authentication methods

For Pi-specific questions (model IDs, API compatibility flags, session management), refer to Pi's documentation. This document covers only what `bin/pique` adds.

## Security Notes

- `.env` files are gitignored. Never commit them.
- Generated `models.json` and `settings.json` are gitignored in profiles that use templates.
- The script does not log or echo environment variable values.
- `render_template` writes to the profile directory only. It does not touch files outside `PIQUE_ROOT`.
- If a template references an undefined variable, it becomes an empty string. This may produce invalid JSON. Check your `.env` before running.
