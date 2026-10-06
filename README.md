# pique

A collection of curated profiles for the Pi coding agent.

## What This Does

pique stores multiple Pi profiles. Each profile is a complete agent-level configuration. Use a profile to start Pi with pre-tested settings in any project directory.

## Why

- Start new projects with proven configurations.
- Compare profiles to understand what works best.
- Collect best practices for AI-assisted development.
- Evolve your agent setup over time.

## Requirements

- Linux or macOS
- mise
- git

## Installation

```bash
git clone <repository-url> ~/.config/pique
cd ~/.config/pique
mise trust
mise install
ln -sf ~/.config/pique/bin/pique ~/.local/bin/pique
```

Or run the installer:

```bash
./install.sh
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

### Compare Profiles

```bash
pique --diff minimal development
```

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

## Management Tasks

Run from the repository root:

```bash
mise run list                    # List profiles
mise run validate                # Validate all profiles
mise run diff -- minimal development  # Compare profiles
mise run new -- my-profile development    # Create new profile
mise run sync-shared             # Copy shared skills to profiles
```

## Repository Structure

```
~/.config/pique/
├── mise.toml          # Tools and tasks
├── bin/
│   └── pique          # Launcher
├── profiles/
│   ├── minimal/
│   ├── development/
│   └── research/
├── shared/            # Skills used across profiles
├── sessions/          # Pi sessions (gitignored)
└── docs/
    ├── en/
    └── ru/
```

## Documentation

- [English](docs/en/)
- [Русский](docs/ru/)

## License

MIT
