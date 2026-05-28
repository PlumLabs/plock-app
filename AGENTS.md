# AGENTS.md

Context & Instructions for AI Agents

## Project Overview

Plock is a vanilla Rails 8 time tracking and project management application.
- **Stack:** Ruby 4.x, Rails 8.x, SQLite, Tailwind CSS 4.x, Stimulus.js (Hotwire), Propshaft, Prawn (for PDFs).
- **Philosophy:** Keep it vanilla Rails with as few external dependencies as possible. Favor built-in Rails 8 features over pulling in new gems.
- **Authentication:** Uses Rails 8 native authentication structures via `Authentication` and `Authorization` concerns in `ApplicationController`.

## Commands

```bash
bin/setup --skip-server                  # Install deps and prepare database
bin/dev                                  # Start dev server + Tailwind watcher
bin/rails test                           # Unit and integration tests
bin/rails test test/models/user_test.rb  # Single test file
bin/rails test:system                    # System tests (Capybara + Selenium/Chrome)
bin/rubocop                              # Lint with styling (rubocop-rails-omakase)
bin/brakeman --no-pager                  # Security scan
```

## Layout

- `app/models/` — ActiveRecord models. `User`, `Client`, and `Project` are soft-deleted via `disabled_at`.
- `app/controllers/` — Namespaced by feature (e.g. `Tracker::`, `Reports::`). Auth concerns live on `ApplicationController`.
- `app/services/reports/pdf/` — Prawn report generation. Pattern: one `*Generator` per report type, paired with a `*ReportData` aggregator (see `DetailedGenerator`).
- `app/javascript/controllers/` — Stimulus controllers. No build step; ImportMap only.
- `test/` — Minitest. Fixtures use Faker.

## Conventions

- **New code follows existing patterns.** New PDF reports go in `app/services/reports/pdf/` mirroring `DetailedGenerator`. New authorization rules extend the `Authorization` concern, following the `can_*?` naming.
- **Authorization:** check via `can_administrate?`, `can_manage_projects?`, `can_manage_project?(id)`. Add new checks to the concern, not inline in controllers.
- **Soft delete:** set `disabled_at` instead of destroying. Respect existing scopes.
- **Migrations:** generate with `bin/rails g migration`. Never edit existing migrations. Commit the updated `schema.rb`.
- **Tests:** new models and services require unit tests.

## Boundaries

**Always:**
- Ensure all linting and tests pass before committing or declaring a task complete.
- Add or update tests for changed behavior.

**Ask first:**
- Adding a new gem (see philosophy above).
- Running `db:migrate`, `db:rollback`, or anything that mutates the dev DB schema.
- Changing authentication or authorization logic.
- Modifying `bin/setup`, `Procfile`, or deployment config.

**Never:**
- Edit existing migrations or `db/schema.rb` by hand.
- Hard-delete `User`, `Client`, or `Project` records.
- Commit secrets, `.env` files, or anything under `storage/`.
- Disable or skip failing tests to make the suite green.
- Create, or modify `tailwind.config.js`. All theme configurations, custom utilities, and plugins must be handled via CSS `@theme` variables in `app/assets/stylesheets/application.css`.
- Introduce Node.js, npm/bun, or any JS bundling build steps.
