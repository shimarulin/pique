# Agent Instructions

## General

- Write code that follows the project style.
- Make small changes. Do not change many files at one time.
- Test each change before the next change.
- Use the present tense in comments.

## Code Quality

- Add tests for each new function.
- Check that tests pass before you commit.
- Remove code that is not used.
- Keep functions short. One function does one task.

## Git

- Create a feature branch from main for each task.
- Write commit messages in conventional commits format.
- Do not push to main directly.
- Make a pull request for each change.

## Commands

- Use `mise run <task>` for project tasks.
- Use `mise exec` for version-specific commands.
- Do not install packages globally.
- Check mise.toml before you add a dependency.

## Debugging

- Read the error message before you try a fix.
- Add print statements to find the cause.
- Remove debug statements after the fix.
- Write a test that reproduces the bug before the fix.
