# Agent Instructions

## Providers

This profile uses three custom providers:

| Provider | Type | Purpose |
|----------|------|---------|
| `openrouter` | Cloud (OpenAI Compatible) | Primary models via OpenRouter |
| `synthetic` | Cloud (OpenAI Compatible) | Open-source models via Synthetic |
| `local-llm` | Local (Ollama) | Offline models, no cost |

## Model Selection

- Use `openrouter` models for general tasks.
- Use `synthetic` models for open-source model tasks.
- Use `local-llm` models when you work offline or when cost matters.

## Environment

API keys load from a `.env` file. Do not ask the user to paste keys.
If a key is missing, tell the user to edit `.env`.

## Built-in Providers

Built-in providers are not configured. Do not use models from:
- `anthropic`
- `openai`
- `google`
- `azure`
- `bedrock`

Use only the custom providers listed above.

## Commands

- Use `mise exec` for commands that need specific tool versions.
- Do not install packages globally.
- Show command output after completion.
