---
status: "accepted"
date: "2026-10-07"
decision-makers: ["project-owner"]
---

# Exclude profile comparison mechanism at this stage

## Context and Problem Statement

We initially planned a `comparison/` directory with test cases (code-quality, speed, token-usage) to evaluate profiles against each other. The goal was to provide a systematic way to measure which profile performs better for specific tasks.

## Decision Drivers

* The comparison must produce deterministic, reproducible results.
* LLM outputs are inherently non-deterministic — same prompt can yield different responses.
* Token usage and speed vary between runs even with identical configurations.
* Manual evaluation of "code quality" is subjective and not automatable.
* The mechanism adds complexity without providing reliable signal.
* The core value of pique is profile storage and selection, not evaluation.

## Considered Options

* Keep comparison/ with test cases and automation scripts
* Exclude comparison/ entirely, keep only `pique --diff` (file diff)
* Replace with external evaluation tools
* Defer to a future version

## Decision Outcome

Chosen option: "Exclude comparison/ entirely, keep only `pique --diff` (file diff)", because the comparison mechanism as designed was naive and non-deterministic, while `pique --diff` provides deterministic file-level comparison which is sufficient for understanding structural differences between profiles.

### Consequences

* Good, because the project remains focused on its core value (profile management).
* Good, because we avoid maintaining a mechanism that produces unreliable results.
* Good, because `pique --diff` still allows structural comparison of profiles.
* Good, because the complexity of the repository decreases.
* Bad, because there is no built-in way to evaluate which profile performs better.
* Bad, because users must rely on external tools or manual testing for evaluation.

### Confirmation

Verify that `pique --diff` and `mise run diff` work correctly for file-level comparison. Confirm that no comparison/ directory exists in the repository.

## Pros and Cons of the Options

### Keep comparison/ with test cases and automation scripts

The original plan: test cases with prompts, expected outcomes, and a script to run comparisons.

* Good, because it provides a structured approach to evaluation.
* Good, because it documents what "better" means for each use case.
* Bad, because LLM outputs are non-deterministic — results are not reproducible.
* Bad, because manual evaluation is required for quality assessment.
* Bad, because speed and token usage vary between runs.
* Bad, because it adds complexity to maintain.
* Bad, because it creates false expectations of objectivity.

### Exclude comparison/ entirely, keep only `pique --diff` (file diff)

Remove the comparison/ directory. Keep the `--diff` command for file-level comparison.

* Good, because it keeps the project simple and focused.
* Good, because `pique --diff` is deterministic (it diffs files).
* Good, because structural differences are often more important than output differences.
* Good, because it reduces maintenance burden.
* Bad, because there is no built-in performance evaluation.
* Bad, because users must evaluate profiles themselves.

### Replace with external evaluation tools

Use existing LLM evaluation frameworks instead of building our own.

* Good, because it leverages specialized tools.
* Good, because it avoids reinventing the wheel.
* Bad, because it adds external dependencies.
* Bad, because integration would be complex.
* Bad, because no standard tool fits this use case well.
* Neutral, because users can still use external tools independently.

### Defer to a future version

Keep comparison/ but mark it as experimental.

* Good, because it preserves the option.
* Good, because it signals intent without committing.
* Bad, because it ships incomplete functionality.
* Bad, because it confuses users about what works.
* Bad, because dead code accumulates.
