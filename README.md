# Plock

A vanilla Rails 8 time tracking and project management app.

[![CI](https://github.com/PlumLabs/plock-app/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/PlumLabs/plock-app/actions/workflows/ci.yml)
![coverage](https://raw.githubusercontent.com/PlumLabs/plock-app/main/coverage_badge.svg)

## What is Plock?

Plock is a small, self-hostable time tracker app for small companies with teams. Track hours against clients and projects, and export polished PDF reports. Built as vanilla Rails 8 with as few external dependencies as possible — easy to read, easy to deploy and easy to extend.

<p align="center">
  <video src="https://github.com/user-attachments/assets/b2351f83-6a3f-443d-9909-146eb555356a" controls muted playsinline width="80%">
    Your browser does not support embedded videos.
  </video>
</p>

## Features

- **Manual time tracking** — log time against a project, a client, or no project at all.
- **Role-based access** — three tiers:
  - *Members* track their own time.
  - *Managers* edit time for the teammates they manage.
  - *Admins* manage the whole company: team, projects, and clients.
- **Clients & projects** — create, edit, archive (soft-deleted via `disabled_at`).
- **Project assignments** — assign people to projects with per-project authorization.
- **PDF reports** — polished reports via Prawn (`app/services/reports/pdf/`).
- **Dashboard & project status views** — at-a-glance hours per person, per project, per client.

## Tech stack

- Ruby 4.x (see `.ruby-version`)
- Rails 8.1
- SQLite
- Tailwind CSS 4
- Hotwire (Turbo + Stimulus) with Propshaft, ImportMap (no JS build step)
- Solid Queue / Solid Cache / Solid Cable
- Prawn for PDF generation


## Quickstart

Prerequisites:

- Ruby `4.0.2` (use `rbenv`, `asdf`, or `mise`)
- SQLite 3.45+
- Google Chrome (for system tests)
- `libyaml` (Linux only — `apt-get install libyaml-dev`)

Install and run:

```bash
bin/setup --skip-server  # install gems, prepare the database
bin/dev                  # start Rails + Tailwind watcher
```

App is at <http://localhost:3000>.

## Testing

```bash
bin/rails test          # unit and integration tests
bin/rails test:system   # system tests (Capybara + Chrome)
bin/rubocop             # lint (rubocop-rails-omakase)
bin/brakeman --no-pager # security scan
bin/ci                  # run all of the above and more in sequence
```

CI runs the same commands on every PR.

## Deploy

Plock is a standard Rails 8 app ready to be deployed using tools like ONCE, Kamal or any other deployment service.


## Contributing

Contributions are welcome. See [`CONTRIBUTING.md`](CONTRIBUTING.md) for setup, conventions, and PR expectations. By participating you agree to abide by the [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).

## License

MIT — see [`LICENSE`](LICENSE).