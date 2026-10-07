# Alternative Tools

## Overview

pique is not the only way to manage Pi profiles. Several tools exist, and even a plain Git repository over `~/.pi/agent` can solve part of the problem. This document describes the alternatives and helps you choose.

## Comparison

| Tool | Mechanism | Storage | Best For |
|------|-----------|---------|----------|
| **pique** (this project) | Thin launcher + `PI_CODING_AGENT_DIR` | Git repository, separate profiles | Single-purpose profile selection; parallel execution; extension independence |
| **Git over `~/.pi/agent`** | Version control of the agent directory | Git repository, one active state | Simple versioning; single-profile workflows |
| **pi-profile** (sovorn-c) | Launcher + `PI_CODING_AGENT_DIR` | `~/.pi/profiles/<name>/` | Isolated profiles with persistent memory |
| **pi-profiles** (krzyzanowskim) | Launcher + `PI_CODING_AGENT_DIR` | `~/.pi/agent-profiles/<name>/` | Auth separation (personal/work) |
| **pi-profiles-manager** (javinnav) | In-process extension, TUI | `~/.pi/agent/pi-profiles/` | Model route management within a session |
| **pi-profile-switch** (VincentFF) | In-process extension + launcher | JSON descriptors | In-session switching with resource selection |

## When to Use pique

Use pique when you want:

- To run Pi with different profiles in parallel.
- Profile switching that does not depend on installed extensions.
- Reproducible runtime environment through version pinning (mise.lock).
- A minimal tool that solves exactly one problem.

## When to Use Alternatives

### Git over `~/.pi/agent`

Keep the Pi agent directory itself under version control.

This works well when:

- You use one configuration at a time.
- You want simple versioning without additional tools.
- You don't need to run multiple profiles simultaneously.
- You are comfortable switching configurations via Git operations (checkout, branches).

Limitations:

- Only one profile is active at a time.
- Switching requires Git operations, not a single command.
- Runtime versions (Node.js, Pi itself) are not pinned.
- Sessions and auth are mixed between configurations unless carefully managed.

Setup:

```bash
cd ~/.pi/agent
git init
git add -A
git commit -m "Initial Pi configuration"
```

To experiment, create a branch, make changes, and merge back when satisfied.

### pi-profile (sovorn-c)

Use when you need:

- Persistent memory per profile (USER.md, HINDSIGHT.md, FAILURES.md).
- Templates for new profiles (coding, research, personal).
- Export/import as `.tgz` bundles.
- Profile creation from existing Pi state.

Install: `npm install -g @sovorn/pi-profile`

Limitations:

- Profiles stored outside version control (unless you add Git yourself).
- No parallel execution of different profiles from the same installation.
- Runtime versions not pinned.

### pi-profiles (krzyzanowskim)

Use when you need:

- Strict auth separation between profiles.
- Automatic settings sync between profiles.
- Shared sessions across profiles.
- Per-profile environment variables.

Install: `mise use -g npm:@krzyzanowskim/pi-profiles@latest`

Limitations:

- Focused on auth separation; other configuration aspects secondary.
- No version control of profiles.
- Runtime versions not pinned.

### pi-profiles-manager (javinnav)

Use when you need:

- Interactive TUI for profile management.
- Model routing (orchestrator + subagents).
- Profile cycling with keyboard shortcuts.
- In-session profile switching.

Install: `pi install npm:pi-profiles-manager`

Limitations:

- Works only inside a running Pi session.
- Requires the extension to be installed and loaded.
- No version control of profiles.
- Cannot launch Pi; manages configuration only after startup.

### pi-profile-switch (VincentFF)

Use when you need:

- In-session profile switching without restart.
- Declarative JSON profiles with schema.
- Resource selection via glob patterns.
- MCP server and tool filtering per profile.
- Runtime overlays for temporary changes.

Install: `npm install -g pi-profile-switch`

Limitations:

- More complex setup (JSON profile descriptors).
- Requires understanding of Pi's resource model.
- No version control of profiles (unless you add Git yourself).
- Runtime versions not pinned.

## Combining Tools

You can use pique alongside other tools:

### pique + pi-profile-switch

Use pique for profile storage and launch. Use pi-profile-switch for in-session flexibility.

1. Store profiles in the pique repository.
2. Use `pique <profile>` to start Pi.
3. Inside the session, use `/profile use <name>` from pi-profile-switch for temporary switches.

### pique + pi-profile

Use pique for versioned configurations. Use pi-profile for isolated working profiles with memory.

1. Maintain configurations in pique.
2. Use pi-profile to create working copies with persistent memory.
3. Import useful changes back to pique via Git.

### pique + Git over ~/.pi/agent

Use Git for direct `~/.pi/agent` management alongside pique profiles.

1. Keep your default Pi configuration under Git in `~/.pi/agent`.
2. Use pique profiles for specialized configurations.
3. Merge useful changes between them.

## Decision Guide

| Your Priority | Recommendation |
|---------------|----------------|
| Minimal, single-purpose tool | pique |
| Parallel profile execution | pique |
| No extension dependencies | pique |
| Reproducible runtime | pique |
| Simple versioning, no new tools | Git over `~/.pi/agent` |
| Persistent memory | pi-profile |
| Auth isolation | pi-profiles |
| In-session switching | pi-profile-switch |
| Model routing TUI | pi-profiles-manager |
