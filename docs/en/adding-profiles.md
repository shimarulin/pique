# Adding Profiles

## Create from Existing

```bash
mise run new -- my-profile development
```

This copies `profiles/development/` to `profiles/my-profile/`.

## Edit Settings

Open `profiles/my-profile/settings.json`. Change:

- `description` — short text that explains the purpose.
- `defaultModel` — the model to use.
- `defaultThinkingLevel` — thinking depth.
- `enabledTools` — tools available to the agent.

## Edit Instructions

Open `profiles/my-profile/AGENTS.md`. Write instructions. Rules:

- One instruction per sentence.
- Use the active voice.
- Use the present tense.
- Keep sentences short.

## Add Resources

Add directories as needed:

| Directory | Contents |
|-----------|----------|
| `extensions/` | Pi extensions |
| `skills/` | Agent skills |
| `prompts/` | Prompt templates |
| `themes/` | UI themes |

## Add MCP Servers

Create `profiles/my-profile/mcp.json`:

```json
{
  "mcpServers": {
    "example": {
      "command": "npx",
      "args": ["-y", "@example/mcp-server"]
    }
  }
}
```

## Test

```bash
cd ~/test-project
pique my-profile
```

Check that Pi starts with correct settings.

## Validate

```bash
mise run validate
```

This checks JSON syntax in all profiles.

## Create Sessions Directory

```bash
mkdir -p sessions/my-profile
```

The launcher uses this directory for Pi sessions.

## Commit

```bash
git add profiles/my-profile sessions/
git commit -m "Add my-profile"
```
