# pique

A curated library of Pi coding agent profiles, with evolution tracking through Git.

## What This Does

pique stores multiple Pi profiles. Each profile is a complete agent-level configuration. Use a profile to start Pi with pre-tested settings in any project directory.

## Why

- Start new projects with proven configurations.
- Compare profiles to understand what works best.
- Collect best practices for AI-assisted development.
- Evolve your agent setup over time.
- Document decisions through Architecture Decision Records.
- Maintain a knowledge base that survives machine changes.

## How It Differs

The profile switching mechanism is a solved problem — several tools do it well. The value of pique is elsewhere:

| Aspect | pique | Other tools |
|--------|-------|-------------|
| **Source of truth** | Git repository | Local files |
| **History** | Full Git history, branches, blame | None or export/import |
| **Comparison** | `git diff`, `pique --diff` | Not built in |
| **Decision documentation** | ADRs with rationale | Not available |
| **Knowledge preservation** | Why decisions were made | Just the what |
| **Reproducibility** | mise.lock pins exact versions | Varies |

See [Alternatives](docs/en/alternatives.md) for detailed comparison of existing tools and when to use each.

## Requirements

- Linux or macOS
- mise
- git

## Installation

Run the installer:

```bash
./install.sh
```

Or clone manually:

```bash
git clone <repository-url> ~/.config/pique
cd ~/.config/pique
mise trust
mise install
ln -sf ~/.config/pique/bin/pique ~/.local/bin/pique
```

## Usage

### List Profiles

```bash
pique --list
```

### Start Pi with a Profile

```bash
cd ~/my-project
pique development
```

This command:

1. Sets `PI_CODING_AGENT_DIR` to the profile directory.
2. Starts Pi in your current directory.
3. Loads project `.pi/` settings if they exist.

### Pass Arguments to Pi

```bash
pique development --version
pique research --print "Summarize this code"
```

All arguments after the profile name pass to Pi directly.

### Compare Profiles

```bash
pique --diff minimal development
```

Or from the repository root:

```bash
mise run diff -- minimal development
```

The output shows files that exist only in one profile and content differences in shared files.

## Profiles

| Name | Purpose |
|------|---------|
| `minimal` | Base setup. No extensions. Low thinking. |
| `development` | Active coding. Medium thinking. File tools. |
| `research` | Analysis. High thinking. Extended output. |

## How It Works

The `PI_CODING_AGENT_DIR` environment variable tells Pi where to find user-level configuration. By default, Pi uses `~/.pi/agent`. pique sets this variable to a profile directory before Pi starts.

Pi reads configuration from two levels:

1. **Profile directory** — settings, skills, extensions from the selected profile.
2. **Project directory** — `.pi/` in the current working directory.

Project settings override profile settings. Resources from both levels combine.

### Project Integration

To use a profile automatically in a project, add this to the project's `mise.toml`:

```toml
[env]
PI_CODING_AGENT_DIR = "~/.config/pique/profiles/development"
```

Then run `pi` from the project directory with mise activated.

### Project Overrides

Pi reads `.pi/settings.json` from the project directory. These settings override profile settings:

```json
{
  "defaultModel": "claude-opus-4-1",
  "defaultThinkingLevel": "high"
}
```

This changes the model for this project only. The profile stays unchanged.

## Management Tasks

Run from the repository root:

```bash
mise run list                    # List profiles
mise run validate                # Validate all profiles
mise run diff -- minimal development  # Compare profiles
mise run new -- my-profile development  # Create new profile
mise run sync-shared             # Copy shared skills to profiles
```

## Architecture Decision Records

Significant decisions are documented in `docs/decisions/` using MADR 4.0.0 format. Each ADR records:

- The context and problem
- Options considered
- Why the chosen option won
- Consequences (positive and negative)
- How to verify the decision is still valid

Current decisions:

| ADR | Decision |
|-----|----------|
| [0001](docs/decisions/0001-use-isolation-via-pi-coding-agent-dir.md) | Use `PI_CODING_AGENT_DIR` for profile isolation |
| [0002](docs/decisions/0002-use-git-first-approach.md) | Use Git-first approach for configuration management |
| [0003](docs/decisions/0003-use-thin-launcher-not-extension.md) | Use thin launcher, not in-process extension |
| [0004](docs/decisions/0004-use-madr-for-decision-records.md) | Use MADR 4.0.0 for decision records |
| [0005](docs/decisions/0005-use-mise-for-runtime-management.md) | Use mise for runtime management |
| [0006](docs/decisions/0006-store-profiles-in-config-directory.md) | Store profiles in `~/.config/pique/` |

See the [ADR guide](docs/en/adr-guide.md) for how to write new ones.

## Profile Comparison

The `comparison/` directory contains test cases for evaluating profiles:

| Case | What it tests |
|------|---------------|
| `code-quality` | Correctness, completeness, style of responses |
| `speed` | Response time and tool call efficiency |
| `token-usage` | Token consumption for equivalent tasks |

Run comparisons:

```bash
./comparison/scripts/run-comparison.sh minimal development
```

Results are stored in `comparison/results/` and committed for reference.

See [Comparison guide](docs/en/comparison.md) for details.

## Repository Structure

```
~/.config/pique/
├── mise.toml              # Tool versions and management tasks
├── mise.lock              # Locked versions (commit this)
├── bin/
│   └── pique              # Launcher command
├── profiles/
│   ├── minimal/           # Base configuration
│   ├── development/       # Development configuration
│   └── research/          # Research configuration
├── shared/                # Skills used across profiles
├── docs/
│   ├── en/                # English documentation
│   ├── ru/                # Russian documentation
│   └── decisions/         # Architecture Decision Records
├── comparison/            # Comparative test cases
│   ├── cases/             # Test prompts and criteria
│   ├── scripts/           # Automation scripts
│   └── results/           # Comparison outputs
└── install.sh             # Installer
```

## Documentation

### English

- [Usage guide](docs/en/usage.md)
- [Architecture](docs/en/architecture.md)
- [Adding profiles](docs/en/adding-profiles.md)
- [Profile comparison](docs/en/comparison.md)
- [ADR guide](docs/en/adr-guide.md)
- [Alternative tools](docs/en/alternatives.md)

### Русский

- [Руководство по использованию](docs/ru/usage.md)
- [Архитектура](docs/ru/architecture.md)
- [Добавление профилей](docs/ru/adding-profiles.md)
- [Сравнение профилей](docs/ru/comparison.md)
- [Руководство по ADR](docs/ru/adr-guide.md)
- [Альтернативные инструменты](docs/ru/alternatives.md)

## Combining with Other Tools

pique focuses on the curated library. For other needs, combine with existing tools:

| Need | Tool | How |
|------|------|-----|
| In-session switching | [pi-profile-switch](https://github.com/VincentFF/pi-profile-switch) | Use pique to start, `/profile use` inside session |
| Auth isolation | [pi-profiles](https://github.com/krzyzanowskim/pi-profiles) | Use for work/personal separation |
| Model routing TUI | [pi-profiles-manager](https://github.com/javinnav/pi-profiles-manager) | Install alongside |
| Persistent memory | [pi-profile](https://github.com/sovorn-c/pi-profile) | Use for memory-heavy workflows |

See [Alternatives](docs/en/alternatives.md) for details.

## License

MIT
