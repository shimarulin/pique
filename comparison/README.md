# Profile Comparison

This directory contains test cases for comparing Pi profiles.

## Structure

```
comparison/
├── cases/
│   ├── code-quality/       # Test response quality
│   │   ├── prompt.md       # The prompt to send
│   │   └── expected.md     # What a good response looks like
│   ├── speed/              # Test response time
│   └── token-usage/        # Test token consumption
├── scripts/
│   └── run-comparison.sh   # Automation script
└── results/                # Output directory (gitignored)
```

## Running Comparisons

### Manual

1. Start Pi with profile A: `pique minimal`
2. Send the prompt from `cases/code-quality/prompt.md`
3. Record the response.
4. Repeat with profile B: `pique development`
5. Compare responses.

### Automated

```bash
./comparison/scripts/run-comparison.sh minimal development
```

## Test Cases

### code-quality

Tests whether the profile produces correct, complete, and well-structured responses.

**Prompt**: A coding task that requires understanding of context.

**Evaluation criteria**:
- Correctness of the solution
- Completeness (no missing edge cases)
- Code style consistency
- Explanation quality

### speed

Tests how quickly the profile responds.

**Prompt**: A simple, unambiguous task.

**Evaluation criteria**:
- Time to first token
- Total time to completion
- Number of tool calls

### token-usage

Tests how many tokens the profile consumes.

**Prompt**: A task that can be solved with varying amounts of context.

**Evaluation criteria**:
- Input tokens
- Output tokens
- Total cost (if applicable)

## Recording Results

Store results in `results/` directory with naming pattern:

```
results/YYYY-MM-DD_profileA_vs_profileB_case.md
```

Include:
- The prompt used
- Responses from each profile
- Evaluation notes
- Conclusion (which profile performed better and why)
