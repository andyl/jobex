# Per-Type Serial Queues

## Problem

All serial jobs share one Oban queue (`serial`, concurrency 1). A long-running
`backup` job blocks an unrelated `sync` job. Serial should mean "one at a time
per type" — different types run in parallel with each other.

## Design

Dynamic Oban queues named `serial_<type>` (concurrency 1 each). The CSV format
is unchanged — QUEUE column still says `serial` or `parallel`. The system
derives the actual Oban queue at job insertion time.

## Changes

### 1. `lib/jobex_core/job.ex` — Route serial jobs to per-type queues
- `serial/2` passes `queue: "serial_<type>"` to `Worker.Serial.new/2`
- Lazily calls `Oban.start_queue/1` (idempotent) to ensure the queue exists
- Add `serial_queue_name/1` helper to sanitize type names

### 2. `lib/jobex_core/scheduler.ex` — Pre-start serial queues on CSV load
- Add `ensure_serial_queues/1` that extracts distinct serial types from CSV rows
  and calls `Oban.start_queue/1` for each
- Call it from `load_all/1` before scheduling jobs

### 3. `config/config.exs` — Remove static serial queue
- Remove `serial: 1` from Oban queue config (now dynamic)

### 4. `lib/jobex_core/query.ex` — Group serial_* queues under "serial"
- `queue_count/0`: aggregate all `serial_*` counts under `"serial"`
- `jdata_queue/1`: match `LIKE 'serial_%'` when filtering by "serial"

### 5. `lib/jobex_web/live/home/body.ex` — Normalize queue display
- Add `display_queue/1` helper: `serial_*` -> `serial`
- Use in template queue column

### 6. `lib/jobex_web/controllers/home_html/help.html.heex` — Update docs
- Explain per-type serialization behavior

### 7. Tests — Verify new behavior
- Existing scheduler tests should still pass
- Add test for per-type queue routing in Job

## Edge Cases

- **New types on CSV reload**: `Oban.start_queue/1` handles dynamically
- **Removed types**: idle queues are harmless
- **Existing jobs in old `serial` queue**: will need manual cleanup or keep
  `serial: 1` temporarily during transition
- **Type name sanitization**: replace non-alphanumeric chars with underscores
- **Atom safety**: types are admin-controlled (CSV), not arbitrary input
