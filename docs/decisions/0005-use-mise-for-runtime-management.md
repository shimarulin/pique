---
status: "accepted"
date: "2026-10-07"
decision-makers: ["project-owner"]
---

# Use mise for runtime management

## Context and Problem Statement

The project needs to manage versions of Pi and Node.js (required for Pi extensions) to ensure reproducibility across machines. Which tool should we use?

## Decision Drivers

* Versions must be pinned for reproducibility.
* Installation must be simple on Linux and macOS.
* The tool must support lockfiles for exact version resolution.
* The tool should be widely adopted and actively maintained.

## Considered Options

* mise (mise-en-place)
* asdf
* Manual version management (document versions in README)
* Docker/containerization

## Decision Outcome

Chosen option: "mise (mise-en-place)", because it has built-in support for Pi in its registry, supports lockfiles for reproducibility, works on Linux and macOS, and provides a task runner for profile management commands.

### Consequences

* Good, because Pi is available in mise's tool registry (aqua backend).
* Good, because mise.lock ensures exact version reproduction.
* Good, because mise tasks provide a CLI for profile management.
* Good, because mise is actively maintained and widely adopted.
* Good, because mise handles Node.js (needed for Pi extensions).
* Bad, because it requires installing mise as a dependency.
* Bad, because it adds a layer of indirection.

### Confirmation

Verify that `pi` is still available in mise's registry. Check that `mise install` works on a fresh Linux and macOS machine. Verify that `mise.lock` correctly pins versions.

## Pros and Cons of the Options

### mise (mise-en-place)

A polyglot tool version manager with task runner capabilities.

* Good, because Pi is in the registry (aqua:earendil-works/pi).
* Good, because lockfile support ensures reproducibility.
* Good, because task runner provides CLI commands.
* Good, because it manages Node.js alongside Pi.
* Good, because it is actively maintained (34.6k GitHub stars).
* Good, because it works on Linux and macOS.
* Bad, because it is an additional dependency.
* Bad, because it may conflict with other version managers.

### asdf

The original multi-language version manager.

* Good, because it is widely adopted.
* Good, because it has many plugins.
* Bad, because Pi is not in the default plugin registry.
* Bad, because it does not have built-in lockfile support.
* Bad, because it does not have a task runner.
* Bad, because mise is its successor.

### Manual version management

Document required versions in README; users install manually.

* Good, because it has no dependencies.
* Good, because it is transparent.
* Bad, because it is error-prone.
* Bad, because it does not ensure reproducibility.
* Bad, because it requires manual effort on each machine.

### Docker/containerization

Run Pi inside a container with pinned versions.

* Good, because it ensures complete isolation.
* Good, because it is reproducible.
* Bad, because it is heavyweight for this use case.
* Bad, because it complicates file access.
* Bad, because it requires Docker installation.
* Bad, because it adds overhead to every Pi launch.
