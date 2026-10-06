# Architecture Decision Records Guide

## Overview

This project uses MADR (Markdown Architectural Decision Records) version 4.0.0 to document significant decisions. ADRs capture the context, options considered, and rationale behind each choice.

## Why ADRs

- Future contributors understand why decisions were made.
- Decisions can be revisited with full context.
- The evolution of the project becomes transparent.
- Alternatives are preserved, not lost.

## Format

Each ADR is a Markdown file in `docs/decisions/` with the naming pattern:

```
NNNN-title-with-dashes.md
```

Where `NNNN` is a sequential number starting from `0001`.

## Template

```markdown
---
status: "accepted"
date: "YYYY-MM-DD"
decision-makers: ["your-name"]
---

# Short title of the decision

## Context and Problem Statement

Describe the context and the problem. Use two to three sentences.
State the problem as a question when possible.

## Decision Drivers

* {force or concern that drives this decision}
* {another driver}

## Considered Options

* {title of option 1}
* {title of option 2}
* {title of option 3}

## Decision Outcome

Chosen option: "{title of option 1}", because {justification}.

### Consequences

* Good, because {positive consequence}
* Bad, because {negative consequence}

### Confirmation

{How to verify this decision is still valid.}

## Pros and Cons of the Options

### {title of option 1}

* Good, because {argument a}
* Good, because {argument b}
* Bad, because {argument c}

### {title of option 2}

* Good, because {argument a}
* Bad, because {argument b}
```

## Writing Guidelines

### Do

- Write one ADR per decision.
- Keep the title short and descriptive.
- Use the active voice.
- State the problem before the solution.
- List all serious options, not just the winner.
- Include negative consequences.
- Link to related ADRs when relevant.

### Do Not

- Do not write implementation details.
- Do not duplicate information from README or docs.
- Do not write ADRs for trivial choices.
- Do not modify accepted ADRs — write a new one that supersedes.

## Status Values

| Status | Meaning |
|--------|---------|
| `proposed` | Under discussion, not yet final |
| `accepted` | Decision is active |
| `deprecated` | No longer relevant, but not replaced |
| `superseded by ADR-NNNN` | Replaced by a later decision |

## Workflow

1. Copy the template to `docs/decisions/NNNN-title.md`.
2. Fill in all sections.
3. Set `status: proposed`.
4. Commit with message: `docs(adr): propose NNNN-title`.
5. After review, change to `status: accepted`.
6. Commit with message: `docs(adr): accept NNNN-title`.

## Superseding a Decision

When a decision changes:

1. Write a new ADR with the new decision.
2. In the old ADR, change status to `superseded by ADR-NNNN`.
3. Link from the new ADR to the old one.
4. Do not delete or rewrite the old ADR.

## External Resources

- [MADR specification](https://adr.github.io/madr/)
- [MADR GitHub repository](https://github.com/adr/madr)
- [Original ADR concept by Michael Nygard](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
