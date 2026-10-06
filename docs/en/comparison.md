# Profile Comparison

## Compare Two Profiles

```bash
pique --diff minimal development
```

Or from the repository root:

```bash
mise run diff -- minimal development
```

## Output

The comparison shows:

1. Files only in the first profile.
2. Files only in the second profile.
3. Content differences in shared files.

## When to Compare

- Before you create a new profile from an existing one.
- After changes to shared components.
- When profiles behave differently.
- Before you merge profiles.

## Understanding Differences

| Type | Meaning |
|------|---------|
| File in A only | First profile has a resource the second lacks. |
| File in B only | Second profile has a resource the first lacks. |
| Changed content | Both have the file, but content differs. |

## Workflow

1. Identify the base profile.
2. Compare with specialized profiles.
3. Find useful changes in specialized profiles.
4. Copy useful changes to the base profile.
5. Test the base profile.
6. Sync shared resources: `mise run sync-shared`.

## Tips

- Compare the minimal profile with each specialized profile.
- Check that shared resources are identical across profiles.
- Look for unintended differences.
- Document why each difference exists.
