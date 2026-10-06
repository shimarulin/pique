# Alternative Tools

## Overview

pique is not the only solution for managing Pi profiles. Several established tools exist. This document describes them and explains when to use each.

## Comparison

| Tool | Mechanism | Storage | Best For |
|------|-----------|---------|----------|
| **pique** (this project) | Thin launcher + `PI_CODING_AGENT_DIR` | Git repository | Curated library with evolution tracking |
| **pi-profile** (sovorn-c) | Launcher + `PI_CODING_AGENT_DIR` | `~/.pi/profiles/<name>/` | Isolated profiles with persistent memory |
| **pi-profiles** (krzyzanowskim) | Launcher + `PI_CODING_AGENT_DIR` | `~/.pi/agent-profiles/<name>/` | Auth separation (personal/work) |
| **pi-profiles-manager** (javinnav) | In-process extension, TUI | `~/.pi/agent/pi-profiles/` | Model route management within a session |
| **pi-profile-switch** (VincentFF) | In-process extension + launcher | JSON descriptors | In-session switching with resource selection |

## When to Use pique

Use pique when:

- You want your configurations in Git.
- You compare profiles to evolve your setup.
- You document decisions (ADRs).
- You maintain a curated library over time.
- You need reproducibility across machines.

## When to Use Alternatives

### pi-profile (sovorn-c)

Use when you need:

- Persistent memory per profile (USER.md, HINDSIGHT.md, FAILURES.md).
- Templates for new profiles (coding, research, personal).
- Export/import as `.tgz` bundles.
- Profile creation from existing Pi state.

Install: `npm install -g @sovorn/pi-profile`

### pi-profiles (krzyzanowskim)

Use when you need:

- Strict auth separation between profiles.
- Automatic settings sync between profiles.
- Shared sessions across profiles.
- Per-profile environment variables.

Install: `mise use -g npm:@krzyzanowskim/pi-profiles@latest`

### pi-profiles-manager (javinnav)

Use when you need:

- Interactive TUI for profile management.
- Model routing (orchestrator + subagents).
- Profile cycling with keyboard shortcuts.
- In-session profile switching.

Install: `pi install npm:pi-profiles-manager`

### pi-profile-switch (VincentFF)

Use when you need:

- In-session profile switching without restart.
- Declarative JSON profiles with schema.
- Resource selection via glob patterns.
- MCP server and tool filtering per profile.
- Runtime overlays for temporary changes.

Install: `npm install -g pi-profile-switch`

## Combining Tools

You can use pique alongside other tools:

### pique + pi-profile-switch

Use pique for the Git-versioned library. Use pi-profile-switch for in-session flexibility.

1. Store profiles in pique repository.
2. Use `pique <profile>` to start Pi.
3. Inside the session, use `/profile use <name>` from pi-profile-switch for temporary switches.

### pique + pi-profile

Use pique for curated configurations. Use pi-profile for isolated working profiles with memory.

1. Maintain curated profiles in pique.
2. Use pi-profile to create working copies.
3. Import useful changes back to pique.

## Decision

The choice depends on your primary need:

| Primary Need | Recommendation |
|--------------|----------------|
| Evolution and comparison | pique |
| Auth isolation | pi-profiles |
| In-session switching | pi-profile-switch |
| Model routing | pi-profiles-manager |
| Persistent memory | pi-profile |
