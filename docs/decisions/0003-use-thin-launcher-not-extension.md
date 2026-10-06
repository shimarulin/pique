---
status: "accepted"
date: "2026-10-07"
decision-makers: ["project-owner"]
---

# Use thin launcher, not in-process extension

## Context and Problem Statement

We need a mechanism to select a profile and start Pi with that profile. Should this be a shell script (launcher) or a Pi extension (TypeScript)?

## Decision Drivers

* The mechanism must work outside of Pi.
* The mechanism must be simple to maintain.
* The mechanism must not depend on Pi's extension API.
* The launcher is not the main value proposition.

## Considered Options

* Thin shell script launcher (bin/pique)
* Pi extension (TypeScript)
* Both: launcher for startup, extension for in-session management

## Decision Outcome

Chosen option: "Thin shell script launcher (bin/pique)", because it is simple, has no dependencies beyond bash, and keeps the project focused on its core value (curated configurations) rather than on launcher complexity.

### Consequences

* Good, because the launcher is under 100 lines of bash.
* Good, because it has no npm dependencies.
* Good, because it works on Linux and macOS without modification.
* Good, because it does not break when Pi's extension API changes.
* Bad, because it cannot switch profiles within a running session.
* Bad, because it offers no interactive UI.

### Confirmation

Verify that `bin/pique` works on Linux and macOS. Check that it handles all documented use cases (list profiles, run with profile, diff profiles).

## Pros and Cons of the Options

### Thin shell script launcher (bin/pique)

A bash script that sets `PI_CODING_AGENT_DIR` and executes `pi`.

* Good, because it is simple (under 100 lines).
* Good, because it has no dependencies.
* Good, because it works on all Unix-like systems.
* Good, because it is easy to understand and modify.
* Good, because it does not depend on Pi's internals.
* Bad, because no in-session switching.
* Bad, because no interactive UI.
* Neutral, because users who need in-session switching can use pi-profile-switch alongside pique.

### Pi extension (TypeScript)

A Pi extension that manages profiles from within the agent.

* Good, because it can switch profiles in-session.
* Good, because it can offer a TUI.
* Good, because it integrates with Pi's slash commands.
* Bad, because it requires maintaining TypeScript code.
* Bad, because it depends on Pi's extension API (which may change).
* Bad, because it loads after Pi's core configuration.
* Bad, because it is more complex than needed for the core use case.

### Both: launcher for startup, extension for in-session management

Provide both mechanisms.

* Good, because it covers all use cases.
* Bad, because it doubles the maintenance burden.
* Bad, because it duplicates functionality available in other tools.
* Bad, because it dilutes focus from the core value proposition.
* Neutral, because users can combine pique with pi-profile-switch themselves.
