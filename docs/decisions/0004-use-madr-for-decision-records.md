---
status: "accepted"
date: "2026-10-07"
decision-makers: ["project-owner"]
---

# Use MADR 4.0.0 for decision records

## Context and Problem Statement

We need to document architectural and design decisions for this project. Which ADR format should we use?

## Decision Drivers

* The format must be standardized and well-documented.
* The format must be human-readable and machine-parseable.
* The format must support optional sections for flexibility.
* Tooling support (linting, rendering) is desirable.
* The format should be widely adopted in the community.

## Considered Options

* MADR (Markdown Architectural Decision Records) 4.0.0
* Nygard format (original ADR proposal)
* Y-Statements
* Custom format

## Decision Outcome

Chosen option: "MADR (Markdown Architectural Decision Records) 4.0.0", because it is the most standardized format with active maintenance, tool support, and a balance of structure and flexibility.

### Consequences

* Good, because the format is well-specified and versioned.
* Good, because markdownlint configuration is available.
* Good, because optional sections allow lightweight or detailed records.
* Good, because the MADR project itself uses ADRs (dogfooding).
* Good, because there is a scientific publication describing the format.
* Bad, because it is more complex than the Nygard format.
* Bad, because not all team members may be familiar with it.

### Confirmation

Verify that the MADR template is still available at [github.com/adr/madr](https://github.com/adr/madr). Check that markdownlint works with the provided configuration.

## Pros and Cons of the Options

### MADR (Markdown Architectural Decision Records) 4.0.0

Structured Markdown template with optional sections, YAML front matter, and tooling.

* Good, because it is actively maintained (2.5k GitHub stars).
* Good, because it has a formal specification (version 4.0.0).
* Good, because optional sections allow flexibility.
* Good, because markdownlint support ensures consistency.
* Good, because there is a scientific publication (CEUR-WS).
* Good, because it supports links between ADRs.
* Good, because it includes RACI fields (consulted, informed).
* Bad, because it is more verbose than simpler formats.
* Bad, because the YAML front matter adds overhead for simple decisions.

### Nygard format (original ADR proposal)

Michael Nygard's original format: Title, Context, Decision, Status, Consequences.

* Good, because it is the original and simplest format.
* Good, because it is widely recognized.
* Good, because it requires minimal structure.
* Bad, because it lacks consideration of alternatives.
* Bad, because there is no formal specification.
* Bad, because there is no tool support.
* Bad, because it does not support links between ADRs.

### Y-Statements

Compact format: "In the context of... facing... we decided... to achieve... accepting...".

* Good, because it is very concise.
* Good, because it forces clarity.
* Bad, because it is too compact for complex decisions.
* Bad, because it does not support detailed analysis.
* Bad, because it is less widely adopted.
* Bad, because it is harder to extend.

### Custom format

Define our own ADR structure.

* Good, because it can be tailored to exact needs.
* Bad, because it requires maintenance of the specification.
* Bad, because there is no community support or tooling.
* Bad, because it reinvents the wheel.
* Bad, because it may diverge from community standards.
