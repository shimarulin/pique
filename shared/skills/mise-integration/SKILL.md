---
name: mise-integration
description: Use mise commands for tool version management and task execution
version: 1.0.0
---

# mise Integration

## When to Use

Use this skill when a project has a `mise.toml` file.

## What to Do

1. Check that `mise.toml` exists in the project root.
2. Read the `[tools]` section for required versions.
3. Run `mise install` to install missing tools.
4. Use `mise exec <command>` for version-specific commands.
5. Use `mise run <task>` for project tasks.

## What Not to Do

- Do not install tools globally with npm, pip, or cargo.
- Do not use system tool versions when mise.toml specifies versions.
- Do not create a new mise.toml when one exists.

## Commands

| Command | Purpose |
|---------|---------|
| `mise install` | Install tools from mise.toml |
| `mise exec -- <cmd>` | Run command with mise tools |
| `mise run <task>` | Execute a defined task |
| `mise ls` | List installed versions |
| `mise use <tool>@<ver>` | Add or update a tool |
