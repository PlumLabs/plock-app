# AGENTS.md

This file provides guidance to AI harnesses when working with code in this repository.

## Project Overview

Plock is a Rails 8 time tracking and project management application using SQLite, Tailwind CSS 4, Stimulus.js (Hotwire), and Propshaft. PDF reports are generated with Prawn.

**Philosophy: keep vanilla Rails with as few dependencies as possible.** Prefer built-in Rails features over adding new gems.

## Common Commands

```bash
bin/setup --skip-server      # Install deps and prepare database
bin/dev                      # Start dev server (Rails + Tailwind CSS watcher)
bin/rails test               # Run unit and integration tests
bin/rails test:system        # Run system (browser/Capybara) tests
bin/rails test test/models/user_test.rb  # Run a single test file
bin/rubocop -f github        # Lint with rubocop-rails-omakase style
bin/brakeman --no-pager      # Security vulnerability scan
```

## Architecture

### Models

- `User` — Authentication via `has_secure_password`; roles: `member` / `administrator`; soft-deleted via `disabled_at`
- `Client` — Groups projects; soft-deleted via `disabled_at`
- `Project` — Belongs to a client; users access projects through `ProjectAssignment`
- `ProjectAssignment` — Join table with roles: `member` / `manager`
- `TimeEntry` — Core entity: `date`, `duration_minutes`, `description`, optional `project_id`, `user_id`
- `Session` — Tracks IP and user agent per login
- `Report::DetailedFilter` — Report filtering and data aggregation (not an AR model)

### Controllers & Namespaces

- `Tracker::TimeEntriesController` / `Tracker::TimeDuplicatesController` — Time entry CRUD and duplication
- `Reports::DetailedController` — PDF report generation
- `TrackersController` — Main time tracking UI
- Auth is handled via concerns in `ApplicationController`: `Authentication` and `Authorization`

### Services

- `Reports::Pdf::DetailedGenerator` — Builds PDF with Prawn (styling, headers, tables, summaries)
- `Reports::Pdf::DetailedReportData` — Aggregates data for reports
- `Reports::FileNameGenerator` — Constructs report file names

### Authorization

Role checks flow from user role + project assignment role:
- `can_administrate?` — administrator role
- `can_manage_projects?` — administrator or project manager
- `can_manage_project?(id)` — scoped to a specific project

### Routing

```
/tracker           → time entry interface
/tracker/time_entries
/reports/detailed
/clients, /projects, /users
/users/:user_id/profile
/projects/:project_id/assignments
```

### Frontend

- Stimulus controllers for interactive behavior
- Tailwind CSS 4 (configured via `tailwindcss-rails`, watch via `bin/dev`)
- No separate JS build step — uses ImportMap
- UI is responsive (mobile-friendly)

### Testing

- System tests use Capybara + Selenium (Chrome); screenshots saved on failure
- Fixtures use Faker for realistic data
- `bin/rails db:test:prepare` to reset test DB before running system tests
