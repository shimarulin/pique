# The pique Launcher Script

This document describes how `bin/pique` works and how to use its features.

## Overview

The `pique` command is a thin bash script. It:

1. Finds the repository root (following symlinks).
2. Loads environment variables from `.env` files.
3. Sets `PI_CODING_AGENT_DIR` to the profile directory.
4. Executes Pi with all arguments passed through.

The script has no npm dependencies. It requires only bash and standard Unix tools.

## Why Environment Loading

Pi does not load `.env` files. If you store API keys in `.env`, they must be exported to the environment before Pi starts.

The script loads `.env` files in this order:

1. `profiles/<name>/.env` — profile-specific keys (highest priority).
2. `$PIQUE_ROOT/.env` — repository-wide keys (fallback).

Existing shell variables are **never overwritten**. This lets you override `.env` values from the command line:

```bash
PROVIDER_PRIMARY_API_KEY=temp-key pique private-providers
```

## Managing Providers and Models

The script does not manage providers or models. Use one of these approaches:

### Option 1: Edit `models.json` manually

Write provider definitions directly in the profile's `models.json`. Use `$VAR` syntax for `apiKey` values (Pi natively supports this).

See [Providers and Models](providers-and-models.md) for the `models.json` syntax.

### Option 2: Use a Pi extension

Install an extension that manages providers interactively or syncs models automatically.

See [Provider Extensions](provider-extensions.md) for the catalog of available extensions.

### Option 3: Use an external tool

Use a separate tool (like `better-custom-provider`) or write your own that generates `models.json` for multiple harnesses.

The pique script does not generate or transform configuration files. It launches Pi with whatever configuration is in the profile directory.

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

6. Set Pi environment
   ├─ export PI_CODING_AGENT_DIR=<profile-dir>
   └─ export PI_CODING_AGENT_SESSION_DIR (if sessions/ exists)

7. Resolve Pi binary
   ├─ Try: mise which pi (from PIQUE_ROOT)
   └─ Fallback: command -v pi (system PATH)

8. Execute
   └─ exec $PI_BIN "$@"
```

## Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| `PIQUE_ROOT does not exist` | Environment variable points to wrong path | Check the variable, or unset it |
| `profiles directory not found` | Repository structure is broken | Re-clone, or check PIQUE_ROOT |
| `profile 'X' not found` | Typo, or profile missing | Run `pique --list` |
| `'pi' binary not found` | Pi not installed, or mise not configured | Run `cd $PIQUE_ROOT && mise install` |

## Test Cases

Run these to verify the script works:

```bash
# Test 1: Basic launch
pique minimal
# Expected: Pi starts, no .env loaded

# Test 2: Environment loading
echo "TEST_VAR=hello" > profiles/minimal/.env
pique minimal
# Inside Pi, run: ! echo $TEST_VAR
# Expected: hello

# Test 3: Quoted values in .env
echo 'QUOTED="with quotes"' > profiles/minimal/.env
pique minimal
# Inside Pi, run: ! echo $QUOTED
# Expected: with quotes (quotes stripped)

# Test 4: Shell variable precedence
export TEST_VAR="from-shell"
echo "TEST_VAR=from-env-file" > profiles/minimal/.env
pique minimal
# Inside Pi, run: ! echo $TEST_VAR
# Expected: from-shell (shell wins)
# Clean up: unset TEST_VAR; rm profiles/minimal/.env

# Test 5: Symlink resolution
ln -sf /real/path/to/pique ~/.local/bin/pique
pique --list
# Expected: works, PIQUE_ROOT is /real/path/to/pique

# Test 6: Diff excludes secrets
pique --diff minimal development
# Expected: does not show .env contents

# Test 7: Version
pique --version
# Expected: prints pique location and Pi version
```

## Relationship to Pi Documentation

This script adds functionality on top of Pi. Pi's own behavior is documented at:

- [Models configuration](https://pi.dev/docs/latest/models) — `models.json` syntax, `$VAR` interpolation
- [Environment variables](https://pi.dev/docs/latest/environment-variables) — what Pi sets and reads
- [Providers](https://pi.dev/docs/latest/providers) — authentication methods

For Pi-specific questions, refer to Pi's documentation. This document covers only what `bin/pique` adds.

## Security Notes

- `.env` files are gitignored. Never commit them.
- The script does not log or echo environment variable values.
- The script writes only to the sessions directory (`mkdir -p`). It does not modify profile configuration files.
