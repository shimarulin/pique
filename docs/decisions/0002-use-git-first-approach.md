---
status: "accepted"
date: "2026-10-07"
decision-makers: ["project-owner"]
---

# Use Git-first approach for configuration management

## Context and Problem Statement

We need to version-control Pi configuration profiles, track their evolution over time, and compare different approaches. How should the configuration repository be structured?

## Decision Drivers

* Configuration changes must be trackable over time.
* Differences between profiles must be visible.
* The repository must be shareable across machines.
* Evolution history must be preserved.

## Considered Options

* Git-first: repository IS the source of truth
* File-based with export/import (like pi-profile's .tgz)
* Cloud sync (e.g., syncthing, dropbox)
* Database-backed configuration

## Decision Outcome

Chosen option: "Git-first: repository IS the source of truth", because Git provides versioning, diffing, branching, and distribution natively, and because no existing Pi profile tool uses Git as the primary mechanism.

### Consequences

* Good, because full history of changes is available.
* Good, because `git diff` shows differences between profiles.
* Good, because branches allow experimental configurations.
* Good, because the repository is shareable via standard Git hosting.
* Good, because this differentiates pique from all existing tools.
* Bad, because it requires Git knowledge.
* Bad, because binary files (if any) are not handled well.

### Confirmation

Verify that `git diff profiles/minimal profiles/development` produces useful output. Check that the repository can be cloned and used on a fresh machine.

## Pros and Cons of the Options

### Git-first: repository IS the source of truth

The Git repository contains all profiles, documentation, and decision records.

* Good, because Git is universally available.
* Good, because diff, log, blame work out of the box.
* Good, because branching enables experimentation.
* Good, because pull requests enable review of configuration changes.
* Good, because no additional tooling is required.
* Bad, because it requires Git proficiency.
* Bad, because it does not handle binary assets well.

### File-based with export/import

Profiles are stored locally, with .tgz export for transfer.

* Good, because it works without Git.
* Good, because export/import is simple.
* Bad, because there is no history of changes.
* Bad, because comparison requires manual diffing.
* Bad, because sharing requires manual file transfer.
* Neutral, because this is the approach used by pi-profile.

### Cloud sync

Use a file synchronization service to share profiles.

* Good, because it requires no manual export/import.
* Good, because it syncs automatically.
* Bad, because there is no version history (or it is limited).
* Bad, because it requires an external service.
* Bad, because conflicts are hard to resolve.
* Bad, because it does not work offline.

### Database-backed configuration

Store profiles in a database (SQLite, etc.).

* Good, because it supports complex queries.
* Good, because it can handle concurrent access.
* Bad, because it is not human-readable.
* Bad, because it requires additional tooling.
* Bad, because it is not easily version-controlled.
* Bad, because it is overkill for this use case.
