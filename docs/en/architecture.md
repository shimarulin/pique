# Architecture

## Overview

pique is a repository of Pi agent profiles. Each profile is a directory that Pi reads as its agent-level configuration.

## Design

### Profile Isolation

The `PI_CODING_AGENT_DIR` environment variable tells Pi where to find the agent directory. By default, Pi uses `~/.pi/agent`. pique stores profiles in separate directories under `profiles/`.

The launcher script sets this variable before Pi starts. This approach:

- Does not modify `~/.pi/agent`.
- Allows multiple profiles to exist at the same time.
- Lets the user switch profiles without backup and restore.
- Keeps the system Pi configuration separate from versioned profiles.

### Session Isolation

Each profile has a separate sessions directory under `sessions/<profile>/`. The launcher sets `PI_CODING_AGENT_SESSION_DIR` when a sessions directory exists. This prevents session data from one profile from appearing in another.

### Two-Level Configuration

Pi reads configuration from two levels:

1. **Agent directory** — controlled by `PI_CODING_AGENT_DIR`. Contains user-level settings, skills, extensions.
2. **Project directory** — `.pi/` in the working directory. Contains project-level settings.

Project settings override agent settings. Resources from both levels combine. For example:

- Agent directory has `skills/mise-integration/`.
- Project directory has `skills/project-specific/`.
- Pi loads both skills.

### Shared Resources

The `shared/` directory contains skills and extensions used across multiple profiles. The `mise run sync-shared` task copies these resources into each profile that does not already have them.

This allows:

- A single source of truth for common skills.
- Profiles to override shared resources when needed.
- Easy updates to common components.

### Tool Management

mise manages versions of Pi and Node.js:

- `mise.toml` declares versions.
- `mise.lock` records exact resolved versions.
- `mise install` installs declared versions.

The launcher script uses mise to find the Pi binary. If mise is not available, the script falls back to the system PATH.

## File Structure

```
profiles/<name>/
├── settings.json      # Agent-level settings
├── AGENTS.md          # Instructions loaded at startup
├── APPEND_SYSTEM.md   # Additional system prompt (optional)
├── SYSTEM.md          # Replacement system prompt (optional)
├── mcp.json           # MCP servers (optional)
├── keybindings.json   # Keybindings (optional)
├── extensions/        # Extensions (optional)
├── skills/            # Skills (optional)
├── prompts/           # Prompt templates (optional)
└── themes/            # UI themes (optional)
```

## Security

- The repository does not contain API keys.
- Pi stores credentials in `auth.json` within the agent directory.
- Sessions may contain sensitive data. The `sessions/` directory is gitignored.
- Do not commit `auth.json` files.

## Compatibility

- Linux (all distributions)
- macOS (Intel and Apple Silicon)
- bash (available on both platforms)
