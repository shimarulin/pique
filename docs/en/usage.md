# Usage

## Start Pi with a Profile

```bash
cd ~/my-project
pique development
```

The command sets `PI_CODING_AGENT_DIR` and starts Pi in the current directory.

## Pass Arguments

```bash
pique development --version
pique research --print "Summarize this code"
pique minimal
```

All arguments after the profile name pass to Pi directly.

## List Profiles

```bash
pique --list
```

## Compare Profiles

```bash
pique --diff minimal development
```

The output shows files that exist only in one profile and content differences in shared files.

## Use in a Project

### Ad-Hoc

Start Pi from any directory with a profile:

```bash
cd ~/any-project
pique development
```

### Automatic

Add to the project's `mise.toml`:

```toml
[env]
PI_CODING_AGENT_DIR = "~/.config/pique/profiles/development"
```

Run `pi` from the project directory with mise activated. Pi uses the development profile automatically.

### Project Overrides

Pi reads `.pi/settings.json` from the project directory. These settings override profile settings.

Example `.pi/settings.json`:

```json
{
  "defaultModel": "claude-opus-4-1",
  "defaultThinkingLevel": "high"
}
```

This changes the model for this project only. The profile stays unchanged.

## Management Tasks

Run from the pique repository root:

```bash
mise run list                 # List profiles
mise run validate             # Validate all profiles
mise run diff -- a b          # Compare profiles
mise run new -- name [base]   # Create new profile
mise run sync-shared          # Copy shared skills to profiles
```

## Workflow

### Develop a Profile

1. Edit files in `profiles/<name>/`.
2. Test: `pique <name>` from any directory.
3. Commit changes.

### Create a New Profile

```bash
mise run new -- my-profile development
```

Edit `profiles/my-profile/`. Test with `pique my-profile`.

### Compare Profiles

```bash
mise run diff -- minimal development
```

Review differences. Copy useful changes between profiles.

### Update Shared Skills

1. Edit files in `shared/skills/`.
2. Run `mise run sync-shared`.
3. Commit changes to profiles.
