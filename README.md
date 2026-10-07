# pique

> [Русский](README.ru.md)

A collection of user-level configurations (profiles) for the [Pi Coding Agent](https://github.com/earendil-works/pi), with a tool to manage launching `Pi` with a selected configuration.

## What It Does

pique stores any number of [Pi Coding Agent](https://github.com/earendil-works/pi) profiles and launches Pi with a selected profile. Each profile is a complete user-level configuration.

## Why

- Transfer Pi configurations between machines.
- Ensure stability of the agent execution environment.
- Explore different configurations and compare them to find optimal solutions.
- Evolve agent configurations without risking breakage of current workflows.
- Use the most suitable configuration for each task.

## How It Differs

Profile switching is a solved problem — several Pi extensions do it well. You can also keep `~/.pi/agent` under Git version control, which solves versioning and storing multiple profiles via extensions. The value of pique is different:

- Solves exactly one problem: pique does not add agent memory or anything else — only profile selection.
- Allows running Pi with different profiles in parallel.
- Does not depend on installed extensions, keeping the configuration minimal.
- Preserves environment reproducibility through version pinning via mise.lock.

See [Alternatives](docs/en/alternatives.md) for a detailed comparison of existing tools.

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
| `minimal` | Base setup. No extensions. Low thinking level. |
| `development` | Active development. Medium thinking. File tools. |
| `research` | Analysis and research. High thinking. Extended output. |

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

This changes the model for this project only. The profile remains unchanged.

## Management Tasks

Run from the repository root:

```bash
mise run list                    # List profiles
mise run validate                # Validate all profiles
mise run diff -- minimal development  # Compare profiles
mise run new -- my-profile development  # Create new profile
mise run sync-shared             # Copy shared skills to profiles
```

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
└── install.sh             # Installer
```

## Documentation

All English documentation is in [docs/en/](docs/en/README.md).

## Combining with Other Tools

pique focuses on the configuration collection. For other needs, combine with existing tools:

| Need | Tool | How |
|------|------|-----|
| In-session switching | [pi-profile-switch](https://github.com/VincentFF/pi-profile-switch) | Start via pique, use `/profile use` inside session |
| Auth isolation | [pi-profiles](https://github.com/krzyzanowskim/pi-profiles) | For work/personal separation |
| Model routing TUI | [pi-profiles-manager](https://github.com/javinnav/pi-profiles-manager) | Install alongside |
| Persistent memory | [pi-profile](https://github.com/sovorn-c/pi-profile) | For memory-heavy workflows |

See [Alternatives](docs/en/alternatives.md) for details.

## License

MIT
