# Contributing to Plock

Thanks for taking the time to contribute. Bug fixes, features, docs, and tests are all welcome.

## Setup

See the [Quickstart](README.md#quickstart) in the README. Once `bin/setup --skip-server` and `bin/dev` work locally, you're ready.

## Branching

- Branch off `main`.
- Pick a descriptive branch name (e.g. `fix/pdf-totals`, `feat/project-archive`).

## Local checks before pushing

Run the same checks CI runs:

```bash
bin/ci
```

or, if you want to run the steps individually:

```bash
bin/rubocop
bin/brakeman --no-pager
bin/rails test
bin/rails test:system
```

If any of these fail locally, they will fail on CI. Please fix before opening a PR.

## Pull requests

- One topic per PR — keep them focused and reviewable.
- Write a clear title and a short description explaining the *why*.
- Link the related issue if there is one.
- Include screenshots or short clips for UI changes.
- Add or update tests for changed behavior.

A maintainer will review and either merge, request changes, or explain why it isn't a fit.

## Design system

UI changes must follow the project's design system. The canonical reference is `app/views/design_system_docs/index.html.erb`, which documents the available components, color tokens, and typography utilities. Use those instead of introducing new Tailwind classes or one-off styles.

## Project conventions

`AGENTS.md` at the repo root is the canonical conventions doc — soft delete via `disabled_at`, authorization through the `Authorization` concern, no new gems without discussion, no JS build step, etc. Please read it before making non-trivial changes.


## Code of Conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). By participating you agree to uphold it.
