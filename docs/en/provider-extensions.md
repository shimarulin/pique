# Provider and Model Extensions

This document catalogs Pi extensions for working with providers, models, and environment variables. Each extension solves a specific problem. Use this as a reference when choosing tools for your profile.

For the core concepts (`models.json` syntax, `$VAR` interpolation, hiding built-in providers), see [Providers and Models](providers-and-models.md).

## Model Sync Extensions

These extensions automatically discover models from API endpoints and register them in Pi.

### pi-openai-api-models-sync

**Purpose**: Sync models from any OpenAI-compatible `/models` endpoint with full metadata.

**How it works**:
1. Finds all `openai-responses` and `openai-completions` providers in `models.json`
2. Requests `<baseUrl>/models` for each provider
3. Fetches pricing and capability metadata from the configured source (default: Wei-Shaw/model-price-repo)
4. Registers models with full metadata

**Metadata provided**: contextWindow, maxTokens, input modalities, pricing, reasoning levels

**Configuration**: Optional `~/.pi/agent/pi-openai-api-models-sync.json` for include/exclude patterns and defaults

**When to use**: You use an OpenAI-compatible relay/gateway that serves many models with varying capabilities.

```bash
pi install npm:pi-openai-api-models-sync
```

### agent-zero-model-sync

**Purpose**: Keep the Agent Zero Venice provider in `models.json` synced with Venice.ai's newest text models.

**Metadata**: Reasoning-effort levels, first-party-verified

**When to use**: You use Venice.ai through Agent Zero.

```bash
pi install npm:agent-zero-model-sync
```

### pi-ollama-sync / @vtstech/pi-ollama-sync

**Purpose**: Synchronize Ollama models into Pi's `models.json`.

**What they do**:
- Query Ollama's `/api/tags` for available models
- Write model entries to `models.json`
- `@vtstech` version also handles remote Ollama instances and writes the URL back

**Metadata**: None (Ollama API returns only model IDs)

**When to use**: You run local models through Ollama and want them to appear in `/model` automatically.

```bash
pi install npm:pi-ollama-sync
# or
pi install npm:@vtstech/pi-ollama-sync
```

### @vtstech/pi-openrouter-sync

**Purpose**: Sync models from OpenRouter into Pi.

**What it does**: Add models from OpenRouter URLs or IDs, with metadata from OpenRouter's catalog.

**When to use**: You use OpenRouter and want to add specific models without manually editing `models.json`.

```bash
pi install npm:@vtstech/pi-openrouter-sync
```

### homelab-model-sync

**Purpose**: Auto-register a self-hosted `llama.cpp` (or any OpenAI-compatible) server as a Pi provider.

**Configuration**: Set `HOMELAB_URL` environment variable to your server URL.

**When to use**: You run a local inference server and want it available in `/model` without manual configuration.

```bash
pi install git:github.com/aktech/pi-extensions
```

## Custom Provider Registration

These extensions register custom providers that are not built into Pi.

### @indexyz/pi-custom-provider

**Purpose**: Generic extension for OpenAI-compatible, Anthropic-compatible, OpenAI Responses, and Ollama chat endpoints.

**When to use**: You need a universal provider extension supporting multiple API types.

```bash
pi install npm:@indexyz/pi-custom-provider
```

### @mx_/pi-custom-provider

**Purpose**: Auto-register custom API providers (new-api, one-api, any OpenAI-compatible proxy) with dynamic model discovery.

**Key features**:
- Dynamic model list: fetches from API endpoint when `/model` opens
- Conditional requests: ETag/Last-Modified caching
- Multi-protocol support: OpenAI, Anthropic, Gemini, Mistral, Azure, Bedrock, Vertex
- Real metadata: contextWindow/maxTokens/cost from Pi's catalog or heuristic inference
- Model overrides: per-model metadata adjustments

**Configuration**: Standard `models.json` — providers with `baseUrl` and `apiKey` are auto-registered

**When to use**: You use an API gateway (new-api, one-api) with a changing model list.

```bash
pi install npm:@mx_/pi-custom-provider
```

### @esuyo/pi-esuyo-custom-provider

**Purpose**: Register OpenAI-compatible providers via a dedicated JSON config file.

**Key features**:
- `custom-providers.json` with `fetchModels` for auto-discovery
- Provider-level defaults for `contextWindow` and `maxTokens`
- Session headers support
- Compatibility flags

**Limitations**: No metadata enrichment — discovered models get default values.

**When to use**: You prefer a dedicated config file over `models.json` and need session headers.

```bash
pi install npm:@esuyo/pi-esuyo-custom-provider
```

### @d4rw1nz/pi-custom-provider

**Purpose**: Interactive wizard to manage custom LLM providers and models.

**Key features**:
- `/provider-setup` wizard for adding providers
- Model discovery from the endpoint
- Metadata enrichment from models.dev
- Full `compat` JSON editing
- OAuth support for GitHub Copilot and OpenRouter

**When to use**: You prefer interactive setup over hand-editing JSON.

```bash
pi install npm:@d4rw1nz/pi-custom-provider
```

### better-custom-provider

**Purpose**: Interactive wizard for managing custom providers with comprehensive metadata detection.

**Key features**:
- Add from models.dev catalog (OpenRouter, DeepSeek, Groq, xAI, ...)
- Add any custom endpoint (OpenAI, Anthropic, Gemini, Ollama)
- Automatic metadata detection from multiple sources
- Re-probe to reconcile model lists
- Developer-role probe for compatibility
- Reasoning levels mapping

**When to use**: You want the most comprehensive metadata detection and an interactive workflow.

```bash
pi install npm:better-custom-provider
```

### pi-custom-providers (angribot)

**Purpose**: Register OpenAI and Anthropic-compatible relays with official metadata and per-relay pricing.

**Key features**:
- Each relay registered as a real Pi provider
- Metadata from Pi's official catalog
- `costMultiplier` and `modelCostMultipliers` for pricing adjustments
- No `apiKey` field — credentials resolve through Pi's own mechanisms

**When to use**: You use API relays with custom pricing and want accurate cost tracking.

```bash
pi install npm:pi-custom-providers
```

### @fe-essential/pi-custom-provider-manager

**Purpose**: Manage OpenAI-compatible providers via slash commands.

**Commands**:
- `/provider add <name> <baseUrl> <apiKey> [label]`
- `/provider sync <name>`
- `/provider list` / `show` / `set` / `delete`

**Storage**: Extension-owned `providers.json` (not Pi's `models.json`)

**When to use**: You prefer slash commands and separate storage from `models.json`.

```bash
pi install npm:@fe-essential/pi-custom-provider-manager
```

### @pavlenkoia/pi-custom-provider

**Purpose**: Interactive provider management with model discovery.

**Commands**:
- `/provider` — interactive menu
- `/provider-status` — show configured providers
- `/provider-purge` — remove all runtime providers

**Storage**: `~/.pi/agent/custom-provider.json`

**Special**: For LiteLLM, reads `/model_group/info` for vision/reasoning metadata

**When to use**: You use LiteLLM or want interactive provider management.

```bash
pi install npm:@pavlenkoia/pi-custom-provider
```

### playmaker/pi-custom-openai-providers

**Purpose**: Maintain multiple OpenAI-compatible providers with `/model` switching.

**Key features**:
- `/custom-providers` with `add`/`list`/`edit`/`remove` subcommands
- Each provider registers as `custom-<name>` in `/model`
- Persistent storage in Pi's official `models.json` path
- Full models.json schema support (headers, compat, thinkingLevelMap, cost.tiers, modelOverrides)
- Environment variable seeding for CI/scripts

**When to use**: You want full models.json schema support with slash command management.

```bash
pi install npm:pi-custom-openai-providers
```

### pi-diy-provider

**Purpose**: Focused package for setting up API-key-based providers without editing JSON.

**Commands**: `/provider-add`, `/provider-model-sync`

**What it does**: Writes provider and model definitions to `models.json`, refreshes Pi's model registry.

**When to use**: You want a minimal, focused tool for adding providers.

```bash
pi install npm:pi-diy-provider
```

## Provider Hiding

### pi-hide-providers

**Purpose**: Hide providers and models from the `/model` selector via a blocklist.

**How**: Monkey-patches Pi's ModelRuntime accessors to filter out hidden models.

**Commands**: `/hide-models` with `add`/`remove`/`status`/`reset` subcommands

**Config**: `~/.pi/agent/hide-providers.json` or `.pi/hide-providers.json`

**When to use**: You have many providers configured but only use a few. See [Providers and Models](providers-and-models.md) for details.

```bash
pi install npm:pi-hide-providers
```

### pi-provider-allowlist

**Purpose**: Restrict Pi to a single allowlist or blocklist of model providers.

**Commands**: `/providers-allowlist` with a 3-page wizard

**When to use**: You prefer an allowlist approach (list what you want, hide the rest).

```bash
pi install npm:pi-provider-allowlist
```

### @mcowger/pi-suppress-providers

**Purpose**: Limit providers in the model selector based on `enabledProviders` in `settings.json`.

**How**: Removes API key environment variables for non-enabled providers before Pi's model registry loads, then restores them.

**When to use**: You want provider suppression that doesn't affect other tools using the same environment variables.

```bash
pi install npm:@mcowger/pi-suppress-providers
```

## Environment Variable Loading

### @pi-lab/env

**Purpose**: Load env vars for Pi from `settings.json` and `~/.pi/agent/.env`.

**Sources**: Both `settings.json` `env` block and `.env` file; `settings.json` takes precedence.

**When to use**: You want declarative env vars in settings plus a `.env` file.

```bash
pi install npm:@pi-lab/env
```

### pi-dotenv

**Purpose**: Load `~/.pi/agent/.env` into `process.env` at Pi startup.

**When to use**: You want a simple `.env` loader. See [Providers and Models](providers-and-models.md) for details.

```bash
pi install npm:pi-dotenv
```

## Dashboard / Manager Extensions

### @fanchaozz/provider-manager

**Purpose**: Manage custom providers and models in `models.json` via TUI dashboard and `/providers` command.

**Scope**: Only `models.json` — does not manage built-in providers, does not switch models, does not provide login UI.

**When to use**: You want a visual overview and management of your custom providers.

```bash
pi install npm:@fanchaozz/provider-manager
```

## Choosing an Extension

| Your Need | Recommended Extension |
|-----------|----------------------|
| Sync models with metadata from OpenAI-compatible API | `pi-openai-api-models-sync` |
| Sync Ollama models | `pi-ollama-sync` or `@vtstech/pi-ollama-sync` |
| Sync OpenRouter models | `@vtstech/pi-openrouter-sync` |
| Register API gateway with dynamic models | `@mx_/pi-custom-provider` |
| Universal multi-API provider | `@indexyz/pi-custom-provider` |
| Interactive setup wizard | `better-custom-provider` or `@d4rw1nz/pi-custom-provider` |
| Slash command management | `@fe-essential/pi-custom-provider-manager` or `playmaker/pi-custom-openai-providers` |
| Relay with custom pricing | `pi-custom-providers` (angribot) |
| Hide unused providers | `pi-hide-providers` |
| Allowlist providers | `pi-provider-allowlist` or `@mcowger/pi-suppress-providers` |
| Load `.env` at startup | `pi-dotenv` or `@pi-lab/env` |
| TUI dashboard for providers | `@fanchaozz/provider-manager` |

## Combining with pique

These extensions work inside Pi. pique works outside Pi (launching Pi with a profile). They are complementary:

1. pique sets `PI_CODING_AGENT_DIR` to your profile directory.
2. Pi loads extensions from the profile's `extensions/` directory or `settings.json` packages.
3. Extensions see the profile's `models.json` and `.env`.

Example profile structure with extensions:

```
profiles/custom-providers/
├── settings.json          # Contains "packages": ["npm:pi-openai-api-models-sync"]
├── models.json            # Provider definitions (or .template)
├── .env                   # API keys (gitignored)
└── extensions/            # Or put extensions here
```

## Security Notes

- All these extensions are third-party code that runs inside the Pi process.
- Review the source before installing.
- Extensions can inspect credentials, prompts, and tool definitions.
- Prefer extensions with many downloads and active maintenance.
- The pique script (`bin/pique`) provides `.env` loading without any extension — consider whether you need an extension at all.
