# Providers and Models Configuration

This guide describes how to configure multiple OpenAI-compatible providers, disable built-in providers, and manage API keys in `.env` files.

## Overview

Pi supports three mechanisms for provider configuration:

1. **`models.json`** — the built-in, native format. No extensions required.
2. **`custom-providers.json`** — an alternative format via the `@esuyo/pi-esuyo-custom-provider` extension.
3. **`pi.registerProvider()`** — a programmatic approach for TypeScript extensions.

For most use cases, `models.json` is sufficient. The extension-based approach adds convenience features like automatic model discovery.

## API Key Syntax

All provider configuration files support the same `apiKey` value resolution:

| Syntax | Behavior | Example |
|--------|----------|---------|
| `$ENV_VAR` | Read from environment variable | `"$OPENROUTER_API_KEY"` |
| `${ENV_VAR}` | Read from environment variable | `"${OPENROUTER_API_KEY}"` |
| `!command` | Execute shell command, use stdout | `"!op read 'op://vault/key'"` |
| `$$` | Literal dollar sign | `"$$literal-dollar"` |
| `$!` | Literal exclamation mark | `"$!literal-exclaim"` |
| Plain string | Use as-is | `"sk-literal-key"` |

The same syntax applies to `headers` values.

## Approach A: Native `models.json` (No Extensions)

This is the simplest approach. Pi reads provider definitions from `~/.pi/agent/models.json` (or the profile's `models.json` when using `PI_CODING_AGENT_DIR`).

### Configuration

```json
{
  "providers": {
    "my-openrouter": {
      "baseUrl": "https://openrouter.ai/api/v1",
      "api": "openai-completions",
      "apiKey": "$OPENROUTER_API_KEY",
      "models": [
        {
          "id": "anthropic/claude-sonnet-4-5",
          "name": "Claude Sonnet 4.5",
          "reasoning": true,
          "input": ["text", "image"],
          "contextWindow": 200000,
          "maxTokens": 64000,
          "cost": { "input": 3, "output": 15, "cacheRead": 0.3, "cacheWrite": 3.75 }
        }
      ]
    },
    "my-deepseek": {
      "baseUrl": "https://api.deepseek.com/v1",
      "api": "openai-completions",
      "apiKey": "$DEEPSEEK_API_KEY",
      "models": [
        {
          "id": "deepseek-chat",
          "name": "DeepSeek Chat",
          "reasoning": false,
          "input": ["text"],
          "contextWindow": 128000,
          "maxTokens": 8192,
          "cost": { "input": 0.14, "output": 0.28, "cacheRead": 0, "cacheWrite": 0 }
        }
      ]
    },
    "local-ollama": {
      "baseUrl": "http://localhost:11434/v1",
      "api": "openai-completions",
      "apiKey": "ollama",
      "models": [
        { "id": "llama3.2" },
        { "id": "qwen2.5-coder:32b" }
      ]
    }
  }
}
```

### Loading Environment Variables

Pi does not load `.env` files automatically. You have three options:

**Option 1: Export in shell profile**

Add to `~/.bashrc` or `~/.zshrc`:

```bash
export OPENROUTER_API_KEY="sk-or-v1-..."
export DEEPSEEK_API_KEY="sk-..."
```

Restart your terminal or run `source ~/.bashrc`.

**Option 2: Source before launch**

```bash
source .env && pique custom-providers
```

**Option 3: Use dotenvx**

```bash
npm install -g @dotenvx/dotenvx
dotenvx run -- pique custom-providers
```

### Advantages

- No extensions required.
- Works with pique profiles out of the box.
- Full control over provider and model definitions.
- Reloads on `/model` — no restart needed.

### Disadvantages

- No automatic `.env` loading.
- No automatic model discovery (you must list all models).
- Built-in providers still appear if their env vars are set.

## Approach B: `models.json` + `pi-dotenv` Extension

The `pi-dotenv` extension loads `~/.pi/agent/.env` into `process.env` at Pi startup.

### Installation

```bash
pi install npm:pi-dotenv
```

Or add to `settings.json`:

```json
{
  "packages": ["npm:pi-dotenv"]
}
```

**Important:** For extensions that read `process.env` during load (not in event handlers), `pi-dotenv` must load first. Put it first in the `packages` array.

### Create `.env`

```env
# ~/.pi/agent/.env (or profile .env)
OPENROUTER_API_KEY=sk-or-v1-...
DEEPSEEK_API_KEY=sk-...
OLLAMA_API_KEY=ollama
```

### How It Works

- Loads the `.env` file when Pi loads the extension.
- Never overrides environment variables already set in the shell.
- Uses `@dotenvx/dotenvx` internally.
- Reloads on each `session_start` (picks up edits across `/new`, `/resume`, `/fork`).

### Advantages

- Automatic `.env` loading.
- No manual `export` needed.
- Existing shell env vars take precedence.

### Disadvantages

- Requires one extension.
- The `.env` location is fixed (`~/.pi/agent/.env` or profile `.env`).

## Approach C: `models.json` + `@pi-lab/env` Extension

Similar to `pi-dotenv`, but also supports environment variables in `settings.json`.

### Installation

```bash
pi install npm:@pi-lab/env
```

### Configuration

**In `settings.json`:**

```json
{
  "env": {
    "HTTP_PROXY": "http://127.0.0.1:7890",
    "OPENAI_API_KEY": "...",
    "INTERNAL_TOKEN": "..."
  }
}
```

**Or in `~/.pi/agent/.env`:**

```env
HTTP_PROXY=http://127.0.0.1:7890
OPENAI_API_KEY=...
INTERNAL_TOKEN=...
```

### Advantages

- Two configuration sources (`settings.json` and `.env`).
- `settings.json` env values take precedence over `.env` values.
- Trusted projects can override in `.pi/settings.json`.

### Disadvantages

- Requires one extension.
- Same fixed `.env` location.

## Approach D: `custom-providers.json` + `@esuyo/pi-esuyo-custom-provider`

This extension provides an alternative JSON format with additional features.

### Installation

```bash
pi install npm:@esuyo/pi-esuyo-custom-provider
```

### Configuration

Create `~/.pi/agent/custom-providers.json`:

```json
{
  "providers": [
    {
      "name": "my-openrouter",
      "label": "OpenRouter",
      "baseUrl": "https://openrouter.ai/api/v1",
      "apiKey": "$OPENROUTER_API_KEY",
      "fetchModels": true
    },
    {
      "name": "my-gateway",
      "label": "Corporate Gateway",
      "baseUrl": "https://api.my-gateway.com/v1",
      "apiKey": "$GATEWAY_API_KEY",
      "models": [
        { "id": "gpt-4o", "name": "GPT-4o" },
        { "id": "claude-3-5-sonnet", "name": "Claude 3.5 Sonnet" }
      ]
    }
  ]
}
```

### Key Features

| Feature | Description |
|---------|-------------|
| `fetchModels` | Auto-discover models from `{baseUrl}/models` endpoint |
| Provider-level defaults | Set `contextWindow` and `maxTokens` once for all models |
| `sendSessionHeaders` | Send per-conversation headers |
| `compat` | Same compatibility flags as `models.json` |

### Advantages

- Automatic model discovery (`fetchModels: true`).
- Cleaner format for multiple providers (array instead of object).
- Provider-level defaults reduce repetition.

### Disadvantages

- Requires one extension.
- Additional abstraction layer over Pi's native format.
- Same `.env` limitations as Approach A.

## Hiding Built-in Providers

Pi shows built-in provider models when authentication is configured (via `/login` or environment variables). To hide them:

### Method 1: Don't Configure Authentication

If you don't run `/login` for built-in providers and don't have their API keys in your environment, their models won't appear.

**Limitation:** If you have `OPENAI_API_KEY` set for other purposes (e.g., local inference), Pi will show OpenAI models.

### Method 2: `pi-hide-providers` Extension

The `pi-hide-providers` extension provides a blocklist mechanism that completely removes providers and models from all lists.

#### Installation

```bash
pi install npm:pi-hide-providers
```

#### Configuration

Create `~/.pi/agent/hide-providers.json`:

```json
{
  "hide": [
    { "provider": "anthropic" },
    { "provider": "openai" },
    { "provider": "google" },
    { "provider": "github-copilot" }
  ]
}
```

#### Interactive Commands

| Command | Effect |
|---------|--------|
| `/hide-models` | Open interactive TUI |
| `/hide-models add ollama` | Hide entire `ollama` provider |
| `/hide-models add openrouter/cheap-model` | Hide specific model |
| `/hide-models add openrouter/*` | Hide entire provider (wildcard) |
| `/hide-models remove ollama` | Remove hide rule |
| `/hide-models reset` | Unpatch — all models return |
| `/hide-models status` | Show current rules |

#### How It Works

The extension monkey-patches Pi's internal `ModelRuntime` accessors to filter out hidden models. This is not an official SDK mechanism, but it works reliably and survives model catalog refreshes.

**Note:** Project config (`.pi/hide-providers.json`) takes priority over global config.

### Method 3: `@mcowger/pi-suppress-providers` Extension

This extension reads `enabledProviders` from `settings.json` and temporarily removes credentials for non-enabled providers before Pi loads its model registry.

#### Installation

```bash
pi install npm:@mcowger/pi-suppress-providers
```

#### Configuration

Add `enabledProviders` to `settings.json`:

```json
{
  "enabledProviders": ["my-openrouter", "my-deepseek", "local-ollama"]
}
```

Only listed providers will be available; all others will be suppressed.

#### How It Works

The extension removes API key environment variables for non-enabled providers before Pi's model registry loads. After the registry is resolved, env vars are restored so they remain accessible to bash commands and other tools.

### Comparison of Hiding Methods

| Method | Pros | Cons |
|--------|------|------|
| No auth configured | No extension needed | Doesn't work if env vars are set |
| `pi-hide-providers` | Complete removal; blocklist; glob patterns; immediate effect | Monkey-patches internals |
| `@mcowger/pi-suppress-providers` | Suppresses env vars; restores after load | Allowlist (must list wanted providers) |
| `enabledModels` in settings.json | Built-in; no extension | Allowlist; verbose for many models |

## Combined Approach

For maximum functionality, combine multiple extensions:

```bash
pi install npm:pi-dotenv
pi install npm:@esuyo/pi-esuyo-custom-provider
pi install npm:pi-hide-providers
```

Then:

1. `pi-dotenv` loads `.env` automatically.
2. `@esuyo` discovers models via `fetchModels`.
3. `pi-hide-providers` hides built-in providers.

### Load Order

Put `pi-dotenv` first in `packages`:

```json
{
  "packages": [
    "npm:pi-dotenv",
    "npm:@esuyo/pi-esuyo-custom-provider",
    "npm:pi-hide-providers"
  ]
}
```

## Recommendation

| Your Priority | Recommended Approach |
|---------------|----------------------|
| Minimal dependencies | A: Only `models.json` + shell exports |
| Automatic `.env` loading | B: `models.json` + `pi-dotenv` |
| Model auto-discovery | D: `custom-providers.json` + `@esuyo` |
| Hide built-in providers | A/B/C/D + `pi-hide-providers` |
| Everything | B + D + E combined |

For pique profiles, Approach B (`models.json` + `pi-dotenv`) offers the best balance of simplicity and convenience.
