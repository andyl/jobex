# Plan: Convert Jobex from Umbrella to Flat Elixir App

## Context

Jobex is an Elixir umbrella app with 4 child apps (jobex_core, jobex_io,
jobex_ui, jobex_web). The umbrella structure adds complexity without much
benefit — the apps are tightly coupled and always deployed together. Converting
to a single flat app simplifies the project structure, build, and deployment.

**Decisions:** Drop jobex_ui (experimental/unused). Keep existing module names (JobexCore, JobexIo, JobexWeb).

## Step 1: Create flat `lib/` structure and copy source files

Copy all `.ex` files from the 3 kept apps into a top-level `lib/` directory, preserving module paths:

```
apps/jobex_io/lib/jobex_io.ex          → lib/jobex_io.ex
apps/jobex_io/lib/jobex_io/application.ex → lib/jobex_io/application.ex  (will be deleted in step 3)
apps/jobex_core/lib/jobex_core.ex      → lib/jobex_core.ex
apps/jobex_core/lib/jobex_core/**      → lib/jobex_core/**
apps/jobex_web/lib/jobex_web.ex        → lib/jobex_web.ex
apps/jobex_web/lib/jobex_web/**        → lib/jobex_web/**
```

Move priv, assets, and test files:
```
apps/jobex_core/priv/repo/             → priv/repo/
apps/jobex_core/priv/*.csv             → priv/
apps/jobex_web/priv/gettext/           → priv/gettext/
apps/jobex_web/assets/                 → assets/
apps/jobex_core/test/support/          → test/support/
apps/jobex_web/test/support/           → test/support/ (merge)
apps/jobex_core/test/jobex_core*       → test/jobex_core/
apps/jobex_web/test/jobex_web/         → test/jobex_web/
```

## Step 2: Rewrite root `mix.exs`

**File:** `mix.exs`

- Remove `apps_path: "apps"` (this is what makes it an umbrella)
- Add `app: :jobex`, `mod: {Jobex.Application, []}`
- Add `elixirc_paths/1` for test support, `compilers` from jobex_web
- Merge all deps from jobex_core and jobex_web (remove `in_umbrella` entries, deduplicate)
- Keep aliases (ecto.setup, ecto.reset, test)

## Step 3: Create unified `Jobex.Application`

**New file:** `lib/jobex/application.ex`

Combine all 3 supervision trees in dependency order:
1. `{Phoenix.PubSub, name: JobexIo.PubSub}` (was jobex_io)
2. `JobexCore.Repo` (was jobex_core)
3. `JobexCore.Scheduler` (was jobex_core)
4. `{Oban, Application.get_env(:jobex, Oban)}` (was jobex_core)
5. `{Phoenix.PubSub, name: JobexWeb.PubSub, adapter: Phoenix.PubSub.PG2}` (was jobex_web)
6. `JobexWeb.Endpoint` (was jobex_web)

Delete the 3 old application modules: `lib/jobex_core/application.ex`, `lib/jobex_io/application.ex`, `lib/jobex_web/application.ex`

## Step 4: Update all config files

Change every `config :jobex_core, ...` and `config :jobex_web, ...` to `config :jobex, ...`. Remove all `config :jobex_ui, ...` blocks.

**Files to edit:**
- `config/config.exs` — change app atoms, remove jobex_ui endpoint block
- `config/dev.exs` — change app atoms, remove jobex_ui section, fix webpack watcher path from `../apps/jobex_web/assets` → `../assets`
- `config/test.exs` — change app atoms, remove jobex_ui blocks
- `config/prod.exs` — change app atoms, remove jobex_ui blocks (large section lines 12-95)

## Step 5: Update `otp_app` references in source files

Every module that uses `otp_app: :jobex_core` or `otp_app: :jobex_web` must change to `otp_app: :jobex`:

| File                            | Change                                     |
|---------------------------------|--------------------------------------------|
| `lib/jobex_web/endpoint.ex:2`   | `otp_app: :jobex_web` → `otp_app: :jobex`  |
| `lib/jobex_web/endpoint.ex:23`  | `from: :jobex_web` → `from: :jobex`        |
| `lib/jobex_core/repo.ex:3`      | `otp_app: :jobex_core` → `otp_app: :jobex` |
| `lib/jobex_core/scheduler.ex:2` | `otp_app: :jobex_core` → `otp_app: :jobex` |
| `lib/jobex_web/gettext.ex:23`   | `otp_app: :jobex_web` → `otp_app: :jobex`  |

## Step 6: Update `Application.get_env` calls and priv_dir references

4 locations found via grep:

| File                                             | Change                                                                         |
|--------------------------------------------------|--------------------------------------------------------------------------------|
| `lib/jobex_core/scheduler.ex:7`                  | `Application.get_env(:jobex_core, :env)` → `Application.get_env(:jobex, :env)` |
| `lib/jobex_core/scheduler.ex:8`                  | `"apps/jobex_core/priv"` → `"priv"`                                            |
| `lib/jobex_core/scheduler.ex:10`                 | `:code.priv_dir(:jobex_core)` → `:code.priv_dir(:jobex)`                       |
| `lib/jobex_core/oban_scheduler.ex:6`             | Same 3 changes as scheduler.ex                                                 |
| `lib/jobex_core/oban_scheduler.ex:9`             | `:code.priv_dir(:jobex_core)` → `:code.priv_dir(:jobex)`                       |
| `lib/jobex_web/templates/layout/app.html.eex:55` | `Application.get_env(:jobex_web, :env)` → `Application.get_env(:jobex, :env)`  |

## Step 7: Update test infrastructure

- Merge test helpers into single `test/test_helper.exs` (ExUnit.start + Ecto sandbox setup)
- Verify `test/support/data_case.ex` and `test/support/conn_case.ex` work (module names unchanged)

## Step 8: Update release config and scripts

- `rel/config.exs:55-58` — change `jobex_core: :permanent, jobex_web: :permanent` to `jobex: :permanent`
- `script/release` — change `npm run deploy --prefix apps/jobex_web/assets` → `npm run deploy --prefix assets`
- `script/install` — update `cd apps` / npm install logic to point at `assets/`

## Step 9: Clean up

- Update `.projections.json` for flat structure
- Update `CLAUDE.md`
- Delete `apps/` directory
- Clean `_build/` and `deps/`

## Verification

```bash
rm -rf _build deps
mix deps.get
mix compile
mix ecto.reset          # verify migrations run from priv/repo/migrations/
mix test                # verify all tests pass
mix phx.server          # verify web UI on localhost:4070
```
