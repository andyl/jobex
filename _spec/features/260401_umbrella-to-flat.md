# Umbrella To Flat Conversion

## Summary

Convert Jobex from an Elixir umbrella app (with 4 child apps) to a single flat
Elixir application. The umbrella structure adds complexity without benefit since
the apps are tightly coupled and always deployed together. Drop the unused
jobex_ui app; keep jobex_core, jobex_io, and jobex_web. Preserve all existing
module names (JobexCore, JobexIo, JobexWeb).

## Motivation

- Simpler project structure, build, and deployment
- Eliminates inter-app dependency management overhead
- The child apps are not independently deployable — umbrella buys nothing
- Removes the unused jobex_ui experimental app

## Requirements

### File structure migration

- Copy all `.ex` source files from jobex_core, jobex_io, and jobex_web into a
  top-level `lib/` directory, preserving module directory paths
- Move `priv/` contents (repo migrations, CSV files, gettext) to top-level `priv/`
- Move `assets/` from jobex_web to top-level `assets/`
- Merge test files and test support modules into top-level `test/`

### Unified application module

- Create a single `Jobex.Application` supervision tree that combines all three
  child app supervision trees in correct dependency order
- Remove the three individual Application modules after merging

### Root mix.exs

- Convert from umbrella project to standard Mix project
- Merge all dependencies from child apps, removing `in_umbrella` entries
- Set `app: :jobex` with `mod: {Jobex.Application, []}`
- Include `elixirc_paths`, compilers, and aliases from child apps

### Configuration consolidation

- Change all `config :jobex_core` and `config :jobex_web` references to
  `config :jobex` across all config files (config.exs, dev.exs, test.exs, prod.exs)
- Remove all `config :jobex_ui` blocks

### OTP app references

- Update every `otp_app:` option from `:jobex_core` or `:jobex_web` to `:jobex`
- Update all `Application.get_env` calls to use `:jobex`
- Update all `:code.priv_dir` calls to use `:jobex`
- Fix hardcoded paths like `"apps/jobex_core/priv"` to `"priv"`

### Test infrastructure

- Merge test helpers into a single `test/test_helper.exs`
- Ensure DataCase and ConnCase support modules work unchanged

### Release and scripts

- Update `rel/config.exs` to reference single `:jobex` app
- Update build scripts (`script/release`, `script/install`) to use flat paths

### Cleanup

- Delete the `apps/` directory
- Update `.projections.json` for flat structure
- Update `CLAUDE.md` to reflect new structure

## Acceptance criteria

- `mix deps.get` succeeds
- `mix compile` succeeds with no warnings related to the conversion
- `mix ecto.reset` runs migrations from `priv/repo/migrations/`
- `mix test` passes all existing tests
- `mix phx.server` starts and serves the web UI on localhost:4070
- The `apps/` directory no longer exists
- No references to `:jobex_core`, `:jobex_web`, or `:jobex_ui` as OTP app names
  remain in source or config

## Out of scope

- Any functional changes to job scheduling, execution, or the web UI
- Database schema changes
- New features or refactoring beyond what is needed for the conversion
- Renaming existing module names (JobexCore, JobexIo, JobexWeb stay as-is)
