---
status: "accepted"
date: "2026-10-07"
decision-makers: ["project-owner"]
---

# Store profiles in ~/.config/pique, not ~/.pi/

## Context and Problem Statement

The repository needs a standard installation path. Where should it live on the user's system?

## Decision Drivers

* The path must follow platform conventions (XDG on Linux).
* The path must not conflict with Pi's own directories.
* The path must be distinct from other Pi profile tools.
* The path should be intuitive for users.

## Considered Options

* `~/.config/pique/`
* `~/.local/share/pique/`
* `~/.pi/profiles/` (same as pi-profile)
* `~/.pique/`

## Decision Outcome

Chosen option: "`~/.config/pique/`", because it follows the XDG Base Directory Specification for user configuration files, avoids conflict with Pi's own directories and other profile tools, and clearly identifies this as a configuration repository.

### Consequences

* Good, because it follows XDG conventions on Linux.
* Good, because it does not conflict with `~/.pi/` or other tools.
* Good, because it is distinct from pi-profile's `~/.pi/profiles/`.
* Good, because the path clearly indicates "configuration".
* Bad, because it is non-standard on macOS (though still works).
* Bad, because users must set `PI_CONFIGS_ROOT` if they choose a different path.

### Confirmation

Verify that the path works on Linux (XDG-compliant) and macOS. Check that it does not conflict with any existing Pi tools.

## Pros and Cons of the Options

### `~/.config/pique/`

Follows XDG Base Directory Specification for configuration files.

* Good, because it is the XDG-standard location for user config.
* Good, because it separates from Pi's own data.
* Good, because it avoids conflicts with other profile tools.
* Good, because the name clearly indicates the project.
* Bad, because macOS does not strictly follow XDG.
* Neutral, because it still works on macOS (just not the native convention).

### `~/.local/share/pique/`

Follows XDG for user data files.

* Good, because it is XDG-compliant.
* Good, because it separates config from data.
* Bad, because profiles ARE configuration, not data.
* Bad, because it is semantically incorrect.
* Bad, because it may be cleaned by some tools.

### `~/.pi/profiles/` (same as pi-profile)

Use the same path as the pi-profile tool.

* Good, because it is consistent with an existing tool.
* Good, because users of pi-profile find it familiar.
* Bad, because it conflicts with pi-profile if both are installed.
* Bad, because it puts non-Pi data inside Pi's directory.
* Bad, because it couples our tool to Pi's directory structure.

### `~/.pique/`

A dedicated dotfile directory.

* Good, because it is simple and short.
* Good, because it is unambiguous.
* Bad, because it does not follow XDG.
* Bad, because it adds to dotfile clutter in $HOME.
* Bad, because it is non-standard.
