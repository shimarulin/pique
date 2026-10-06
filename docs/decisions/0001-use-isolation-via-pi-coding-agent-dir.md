---
status: "accepted"
date: "2026-10-07"
decision-makers: ["project-owner"]
---

# Use PI_CODING_AGENT_DIR for profile isolation

## Context and Problem Statement

Pi stores user-level configuration in a single directory (`~/.pi/agent` by default). We need to maintain multiple configuration profiles that can be switched without affecting each other. How do we isolate profiles from each other and from the system Pi configuration?

## Decision Drivers

* Profiles must not modify `~/.pi/agent`.
* Multiple profiles must coexist simultaneously.
* Switching profiles must not require backup/restore operations.
* Project-level configuration (`.pi/` in working directory) must continue to work.

## Considered Options

* Use `PI_CODING_AGENT_DIR` environment variable
* Symlink swapping in `~/.pi/agent`
* Copy profiles to `~/.pi/agent` on demand
* In-process extension that manages profiles

## Decision Outcome

Chosen option: "Use `PI_CODING_AGENT_DIR` environment variable", because it is Pi's documented mechanism for redirecting the agent directory, requires no file manipulation, and allows multiple profiles to exist simultaneously without interference.

### Consequences

* Good, because profiles are completely isolated from each other.
* Good, because no backup/restore is needed when switching.
* Good, because the system Pi configuration remains untouched.
* Bad, because profiles cannot be switched within a running Pi process.
* Bad, because each profile requires its own authentication (auth.json).

### Confirmation

Verify that `PI_CODING_AGENT_DIR` is still documented as the supported mechanism in [Pi documentation](https://pi.dev/docs/latest/configuration). Check that project-level `.pi/` settings continue to override agent-level settings.

## Pros and Cons of the Options

### Use `PI_CODING_AGENT_DIR` environment variable

Pi's built-in environment variable that redirects the agent directory.

* Good, because it is the documented, supported mechanism.
* Good, because it requires no file system manipulation.
* Good, because profiles coexist without interference.
* Good, because project-level settings still work.
* Bad, because switching requires a new process.
* Bad, because auth is per-profile (must log in separately).

### Symlink swapping in `~/.pi/agent`

Replace `~/.pi/agent` with a symlink to the active profile.

* Good, because all Pi features work without modification.
* Bad, because it modifies the system Pi configuration.
* Bad, because it is fragile (broken symlinks, race conditions).
* Bad, because it breaks if multiple Pi processes run simultaneously.

### Copy profiles to `~/.pi/agent` on demand

Copy the selected profile's files to `~/.pi/agent` before each launch.

* Good, because it uses the default Pi configuration path.
* Bad, because it destroys the previous configuration.
* Bad, because it requires backup/restore logic.
* Bad, because it is slow for large profiles.
* Bad, because concurrent Pi instances would conflict.

### In-process extension that manages profiles

A Pi extension that loads and switches profiles at runtime.

* Good, because it allows in-session switching.
* Good, because it can offer a TUI.
* Bad, because it requires maintaining a TypeScript extension.
* Bad, because it couples profile management to Pi's extension API.
* Bad, because extensions load after Pi's core configuration.
* Neutral, because this approach is used by pi-profile-switch and pi-profiles-manager.
