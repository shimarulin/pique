# Agent Instructions

## Providers

This profile uses two custom providers. The provider names are generic:
`primary` and `fallback`. Both serve the same models.

| Provider | Purpose |
|----------|---------|
| `primary` | Main provider for most requests |
| `fallback` | Backup when primary is unavailable |

Switch to the fallback provider manually with `/model`.

## Environment

The provider endpoints and API keys come from environment variables.
They are not stored in the configuration files.

If a key is missing, tell the user to check the `.env` file.

## Built-in Providers

Built-in providers are not configured. Do not use models from:
`anthropic`, `openai`, `google`, `azure`, `bedrock`.

Use only the `primary` and `fallback` providers.

## Commands

- Use `mise exec` for commands that need specific tool versions.
- Do not install packages globally.
- Show command output after completion.
