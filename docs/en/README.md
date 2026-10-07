# pique Documentation

> [Русская документация](../ru/README.md)

## Contents

- [Usage guide](usage.md) — how to launch Pi with profiles
- [Architecture](architecture.md) — how the project works and why
- [Adding profiles](adding-profiles.md) — how to create a new profile
- [ADR guide](adr-guide.md) — how to document decisions
- [Alternative tools](alternatives.md) — comparison with existing solutions

## Overview

pique is a collection of user-level configurations for the Pi Coding Agent and a tool to manage launching Pi with a selected configuration.

### Who It Is For

- Pi users who need different configurations for different tasks.
- Those who want to transfer settings between machines.
- Those researching optimal agent configurations.

### Getting Started

1. Install pique — see [README](../../README.md).
2. List available profiles: `pique --list`.
3. Start Pi with a profile: `pique development`.
4. Read the [usage guide](usage.md) for details.

### How to Read the Documentation

| Document | When to read |
|----------|-------------|
| [Usage guide](usage.md) | Right after installation |
| [Architecture](architecture.md) | When interested in internals |
| [Adding profiles](adding-profiles.md) | When you want to create your own profile |
| [ADR guide](adr-guide.md) | When you want to document decisions |
| [Alternatives](alternatives.md) | When choosing a tool |
