# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is Jobex

Jobex is a cron-like job scheduler with a web UI — "Cron meets Airflow." It reads job definitions from CSV files, executes them on cron schedules, captures stdout/stderr/status, and displays results in a real-time Phoenix LiveView dashboard. Packaged as an Elixir release managed by SystemD (not Docker) since it needs access to local scripts.

## Common Commands

```bash
# Setup
mix deps.get
cd apps/jobex_web/assets && npm install && cd ../../..
mix ecto.setup          # creates DB + runs migrations

# Development
mix phx.server          # starts all endpoints (web on :4070)
mix test                # runs all tests (auto-creates/migrates test DB)
mix test apps/jobex_core # test a single umbrella app
mix test path/to/test.exs:42  # run a single test by line

# Production release
cd apps/jobex_web/assets && npm run deploy && cd ../../..
mix phx.digest
MIX_ENV=prod mix distillery.release
```

## Architecture

Elixir umbrella app with 4 child applications:

### jobex_core — Business Logic
- **Quantum scheduler** reads CSV files (`priv/dev_schedule.csv`, `priv/prod_schedule.csv`) at startup and creates cron jobs dynamically
- **Oban** processes jobs in two queues: `serial` (max 1 concurrent) and `parallel` (max 10 concurrent). Workers retry up to 3 times on failure.
- **Execution flow**: Quantum cron trigger → `JobexCore.Job.serial/2` or `.parallel/2` → Oban enqueue → `Worker.Base.perform/1` → `Runner.Rambo.exec/1` → result saved to DB → PubSub broadcast
- **Key modules**: `Scheduler` (CSV→cron), `Worker.Base` (execution), `Query` (filtering/pagination for UI), `Runner.Rambo` (command execution)

### jobex_io — PubSub Bridge
- Thin wrapper around Phoenix.PubSub (named `:jobex_io`)
- Events: `"shell-worker-start"`, `"shell-worker-finish"` from workers; `"job-event"`, `"job-refresh"` for UI updates

### jobex_web — Main Web UI (port 4070 dev, 5070 prod)
- Phoenix LiveView app at `/home` route
- Two nested LiveViews: `Sidebar` (filter counts, refreshes every 5s) and `Body` (paginated job table, 24 rows/page)
- Filtering on: state, queue, type, command (substring), alert type
- Keyboard navigation: arrow keys for pagination and filter selection

### jobex_ui — Experimental/Prototype UI (port 4075)
- Alternative LiveView UI, not actively used

## Database

PostgreSQL (user/pass: postgres/postgres). Two main tables:
- `oban_jobs` — Oban's job queue table (state, queue, worker, args JSON, errors, attempts)
- `results` — Execution results (stdout, stderr, status, attempt) with FK to oban_jobs

## Configuration

- Oban queues and Quantum timezone configured in `config/config.exs`
- Quantum timezone: `America/Los_Angeles`
- Job schedules defined in CSV, not code — columns: SCHEDULE, QUEUE, TYPE, COMMAND
