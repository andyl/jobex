# Implementation Plan: Umbrella To Flat Conversion

**Spec:** `_spec/features/260401_umbrella-to-flat.md`
**Generated:** 2026-04-01

---

## Goal

Convert Jobex from an Elixir umbrella app (4 child apps) to a single flat Mix project. Drop the unused jobex_ui app, keep jobex_core/jobex_io/jobex_web, and preserve all existing module names.

## Scope

### In scope
- File structure migration (lib, priv, assets, test)
- Unified Application supervision tree
- Root mix.exs rewrite
- Config consolidation (`:jobex_core`/`:jobex_web` → `:jobex`)
- OTP app reference updates (otp_app, get_env, priv_dir)
- Test infrastructure merge
- Release config and script updates
- Cleanup (delete apps/, update .projections.json, update CLAUDE.md)

### Out of scope
- Functional changes to scheduling, execution, or web UI
- Database schema changes
- Module renaming (JobexCore, JobexIo, JobexWeb stay as-is)

## Architecture & Design Decisions

1. **Single OTP app `:jobex`** — all config keys become `config :jobex, ...`. The Application module is `Jobex.Application`.

2. **Supervision tree ordering** — PubSub first (dependency of workers), then Repo, Scheduler, Oban (all depend on Repo), then Endpoint last (depends on everything). JobexIo.PubSub and JobexWeb.PubSub can be consolidated into one, but the spec says keep existing module names, so keep both PubSub instances for now.

3. **priv_dir() simplification** — in umbrella, dev mode used `"apps/jobex_core/priv"` as a workaround. In flat app, `"priv"` works in both dev and prod, but `:code.priv_dir(:jobex)` is more correct for prod releases. Keep the conditional but update paths.

4. **Dependencies merge** — combine jobex_core and jobex_web deps, remove all `in_umbrella: true` entries, deduplicate shared deps (jason, phoenix_pubsub, timex). The `modex` path dep stays as-is.

5. **Database name unchanged** — keep `jobex_core_dev`/`jobex_core_test`/`jobex_core_prod` database names to avoid migration headaches.

## Implementation Steps

### Phase 1: File Structure Migration

1. **Copy lib source files to top-level lib/**
   - Files: create `lib/`, `lib/jobex_core/`, `lib/jobex_io/`, `lib/jobex_web/`
   - Copy `apps/jobex_io/lib/jobex_io.ex` → `lib/jobex_io.ex`
   - Copy `apps/jobex_io/lib/jobex_io/application.ex` → `lib/jobex_io/application.ex`
   - Copy `apps/jobex_core/lib/jobex_core.ex` → `lib/jobex_core.ex`
   - Copy all `apps/jobex_core/lib/jobex_core/**` → `lib/jobex_core/`
   - Copy `apps/jobex_web/lib/jobex_web.ex` → `lib/jobex_web.ex`
   - Copy all `apps/jobex_web/lib/jobex_web/**` → `lib/jobex_web/`
   - Do NOT copy anything from jobex_ui

2. **Move priv files to top-level priv/**
   - Files: create `priv/`, `priv/repo/`, `priv/gettext/`
   - Copy `apps/jobex_core/priv/repo/` → `priv/repo/` (migrations + seeds)
   - Copy `apps/jobex_core/priv/*.csv` → `priv/` (dev_schedule.csv, prod_schedule.csv, dev_backup.csv)
   - Copy `apps/jobex_web/priv/gettext/` → `priv/gettext/`
   - Copy `apps/jobex_core/priv/static/cache_manifest.json` → `priv/static/cache_manifest.json`

3. **Move assets to top-level**
   - Files: `assets/`
   - Copy `apps/jobex_web/assets/` → `assets/`

4. **Merge test files to top-level test/**
   - Files: create `test/`, `test/support/`, `test/jobex_core/`, `test/jobex_web/`
   - Copy `apps/jobex_core/test/support/data_case.ex` → `test/support/data_case.ex`
   - Copy `apps/jobex_web/test/support/conn_case.ex` → `test/support/conn_case.ex`
   - Copy `apps/jobex_web/test/support/channel_case.ex` → `test/support/channel_case.ex`
   - Copy `apps/jobex_core/test/jobex_core_test.exs` → `test/jobex_core_test.exs`
   - Copy `apps/jobex_web/test/jobex_web/` → `test/jobex_web/`

### Phase 2: Core Configuration

5. **Rewrite root mix.exs**
   - File: `mix.exs`
   - Remove `apps_path: "apps"`
   - Add `app: :jobex`
   - Add `mod: {Jobex.Application, []}` in `application/0`
   - Add `elixirc_paths/1` (["lib", "test/support"] for test, ["lib"] otherwise)
   - Add `compilers: [:phoenix, :gettext] ++ Mix.compilers()`
   - Merge deps from jobex_core, jobex_io, and jobex_web:
     - Database: ecto_sql, postgrex, jason
     - Process execution: porcelain, rambo
     - Utility: modex (path dep), nimble_csv, timex
     - Jobs: oban, quantum
     - PubSub: phoenix_pubsub
     - Phoenix: phoenix, plug_cowboy, phoenix_html, phoenix_html_simplified_helpers, phoenix_active_link, phoenix_live_view
     - I18n: gettext
     - Monitoring: observer_cli
     - Dev: phoenix_live_reload
     - Keep existing root deps: distillery, mix_test_watch, ex_projections
   - Remove all `in_umbrella: true` deps
   - Keep aliases (ecto.setup, ecto.reset, test)

6. **Create unified Jobex.Application**
   - File: `lib/jobex/application.ex` (new)
   - Module: `Jobex.Application`
   - Children in order:
     1. `{Phoenix.PubSub, name: JobexIo.PubSub}`
     2. `JobexCore.Repo`
     3. `JobexCore.Scheduler`
     4. `{Oban, Application.get_env(:jobex, Oban)}`
     5. `{Phoenix.PubSub, name: JobexWeb.PubSub, adapter: Phoenix.PubSub.PG2}`
     6. `JobexWeb.Endpoint`
   - Include `config_change/3` callback from JobexWeb.Application
   - Strategy: `:one_for_one`

7. **Delete old Application modules**
   - Delete: `lib/jobex_core/application.ex`
   - Delete: `lib/jobex_io/application.ex`
   - Delete: `lib/jobex_web/application.ex`

### Phase 3: Config Updates

8. **Update config/config.exs**
   - File: `config/config.exs`
   - Delete lines 4-9 (jobex_ui endpoint config)
   - Change `config :jobex_web, :env` → `config :jobex, :env`
   - Change `config :jobex_core, :env` → delete (already covered by above)
   - Change `config :jobex_web, generators:` → `config :jobex, generators:`
   - Change `config :jobex_web, JobexWeb.Endpoint` → `config :jobex, JobexWeb.Endpoint`
   - Change `config :jobex_core, ecto_repos:` → `config :jobex, ecto_repos:`
   - Change `config :jobex_core, Oban` → `config :jobex, Oban`
   - Change `config :jobex_core, JobexCore.Scheduler` → `config :jobex, JobexCore.Scheduler`

9. **Update config/dev.exs**
   - File: `config/dev.exs`
   - Delete lines 1-28 (all jobex_ui config)
   - Change `config :jobex_web, JobexWeb.Endpoint` → `config :jobex, JobexWeb.Endpoint`
   - Fix webpack watcher path: `"../apps/jobex_web/assets"` → `"../assets"`
   - Change `config :jobex_core, JobexCore.Repo` → `config :jobex, JobexCore.Repo`

10. **Update config/test.exs**
    - File: `config/test.exs`
    - Delete lines 5-13 (all jobex_ui config — duplicated block)
    - Change `config :jobex_web, JobexWeb.Endpoint` → `config :jobex, JobexWeb.Endpoint`
    - Change `config :jobex_core, JobexCore.Repo` → `config :jobex, JobexCore.Repo`
    - Change `config :jobex_core, Oban` → `config :jobex, Oban`

11. **Update config/prod.exs**
    - File: `config/prod.exs`
    - Delete lines 1-95 (all jobex_ui config — large duplicated SSL comment blocks)
    - Change `config :jobex_web, JobexWeb.Endpoint` → `config :jobex, JobexWeb.Endpoint`
    - Change `config :jobex_core, JobexCore.Repo` → `config :jobex, JobexCore.Repo`

### Phase 4: Source Code Updates

12. **Update otp_app references**
    - `lib/jobex_web/endpoint.ex`: `otp_app: :jobex_web` → `otp_app: :jobex`
    - `lib/jobex_web/endpoint.ex`: `from: :jobex_web` → `from: :jobex` (Plug.Static)
    - `lib/jobex_core/repo.ex`: `otp_app: :jobex_core` → `otp_app: :jobex`
    - `lib/jobex_core/scheduler.ex`: `otp_app: :jobex_core` → `otp_app: :jobex`
    - `lib/jobex_web/gettext.ex`: `otp_app: :jobex_web` → `otp_app: :jobex`

13. **Update Application.get_env and priv_dir references**
    - `lib/jobex_core/scheduler.ex`:
      - `Application.get_env(:jobex_core, :env)` → `Application.get_env(:jobex, :env)`
      - `"apps/jobex_core/priv"` → `"priv"`
      - `:code.priv_dir(:jobex_core)` → `:code.priv_dir(:jobex)`
    - `lib/jobex_core/oban_scheduler.ex`:
      - Same 3 changes as scheduler.ex
    - `lib/jobex_web/templates/layout/app.html.eex`:
      - `Application.get_env(:jobex_web, :env)` → `Application.get_env(:jobex, :env)`

### Phase 5: Test Infrastructure

14. **Create unified test/test_helper.exs**
    - File: `test/test_helper.exs` (new)
    - Content: `ExUnit.start()` + `Ecto.Adapters.SQL.Sandbox.mode(JobexCore.Repo, :manual)`

15. **Verify test support modules**
    - `test/support/data_case.ex`: check it references `JobexCore.Repo` (should be fine, no otp_app changes needed)
    - `test/support/conn_case.ex`: check it references correct endpoint/repo

### Phase 6: Release & Scripts

16. **Update rel/config.exs**
    - File: `rel/config.exs`
    - Lines 55-58: change `jobex_core: :permanent, jobex_web: :permanent` → `jobex: :permanent`

17. **Update script/release**
    - File: `script/release`
    - Change `npm run deploy --prefix apps/jobex_web/assets` → `npm run deploy --prefix assets`

18. **Update script/install**
    - File: `script/install`
    - Replace the `cd apps` / `find` / npm install logic with `cd assets && npm install && cd ..`

### Phase 7: Cleanup

19. **Update .projections.json**
    - File: `.projections.json`
    - Replace stale crow_data/crow_web entries with flat structure:
      - `lib/*.ex` ↔ `test/*_test.exs`

20. **Update CLAUDE.md**
    - File: `CLAUDE.md`
    - Update "Architecture" section to describe flat app structure
    - Update "Common Commands" to remove umbrella-specific paths
    - Remove references to `apps/` directory

21. **Delete apps/ directory**
    - Remove entire `apps/` directory

22. **Clean build artifacts**
    - Run `rm -rf _build deps`
    - Run `mix deps.get`

## Dependencies & Ordering

- **Steps 1-4 (file copy) must happen before steps 5-7** (mix.exs and Application rewrite), because the new mix.exs will try to compile files in `lib/`
- **Step 5 (mix.exs) must happen before step 6** (Application module), since `mix.exs` references `Jobex.Application`
- **Steps 8-11 (config) can happen in any order** but must all complete before verification
- **Steps 12-13 (source updates) depend on step 1** (files must be in new location)
- **Step 21 (delete apps/) must be last** — only after everything compiles and tests pass
- **Step 22 (clean build) should happen after step 21** to ensure fresh compilation

## Edge Cases & Risks

- **priv_dir in dev mode**: The umbrella used `"apps/jobex_core/priv"` as a dev workaround. In flat structure, `"priv"` should work in dev, but verify that `File.read!()` resolves relative to project root (it does in Mix projects).
- **Two PubSub instances**: JobexIo.PubSub and JobexWeb.PubSub are both started. Workers publish to JobexIo.PubSub, LiveViews subscribe to it. JobexWeb.PubSub is used by the Phoenix endpoint. Keep both to avoid breaking changes.
- **Database names**: Keeping `jobex_core_dev`/`jobex_core_test`/`jobex_core_prod` avoids needing to recreate databases. Could rename later but out of scope.
- **modex path dependency**: `{:modex, path: "~/src/modex"}` — this is a local path dep that must exist on the build machine. No change needed.
- **Webpack watcher path**: The `cd:` option in dev.exs references `"../apps/jobex_web/assets"` relative to `config/`. Must change to `"../assets"`.
- **Template .eex files**: These live in `lib/jobex_web/templates/` — they'll be copied with the rest of lib. The `render` calls use module-relative paths, so no changes needed.
- **Static assets in priv/static**: Phoenix serves from `priv/static`. The `cache_manifest.json` in `apps/jobex_core/priv/static/` should be moved to `priv/static/`. The `apps/jobex_web/assets/static/` content gets copied to `priv/static/` by webpack/phx.digest.
- **Distillery release**: The release references `jobex_core: :permanent` and `jobex_web: :permanent` as separate OTP apps. In flat structure, there's only `:jobex`.

## Testing Strategy

1. **Compilation check**: `mix compile` — no warnings related to missing modules or apps
2. **Database check**: `mix ecto.reset` — migrations run from `priv/repo/migrations/`
3. **Unit tests**: `mix test` — all existing tests pass
4. **Web server check**: `mix phx.server` — web UI loads on localhost:4070
5. **Grep audit**: verify no remaining references to `:jobex_core`, `:jobex_web`, or `:jobex_ui` as OTP app atoms in source/config (some module name references like `JobexCore` are expected and correct)

## Open Questions

- [x] Should the two PubSub instances (JobexIo.PubSub, JobexWeb.PubSub) be consolidated into one? The spec says keep existing module names, so keeping both is safer for now.  Answer: keep both for now
- [x] Should database names be renamed from `jobex_core_*` to `jobex_*`? Keeping them avoids migration hassle but is a cosmetic inconsistency.  Answer: yes rename the databases
- [ ] The `modex` path dep (`~/src/modex`) — should this be vendored or published? Not blocking for conversion but worth noting. Answer: for get about this for now.
