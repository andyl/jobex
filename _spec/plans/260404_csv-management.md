# Implementation Plan: CSV Management

**Spec:** `_spec/features/260404_csv-management.md`
**Generated:** 2026-04-04

---

## Goal

Add a two-phase CSV file management system: Phase 1 provides an admin UI to
list, select, rename, preview, create, and delete CSV schedule files from a
configurable directory. Phase 2 adds inline job-row editing on the schedule
page.

## Scope

### In scope
- `JOBEX_CSV_DIR` environment variable with `priv/csv` default
- Admin page file listing with metadata (name, line count, last updated)
- File actions: select, rename, preview, delete, create
- Filename validation (lowercase, numbers, underscores only)
- Selected-file persistence in `.jobex.yml`
- Scheduler reload on file selection
- Schedule page job listing from selected file
- Inline job create, edit, delete with CSV file updates
- Responsive/mobile-friendly UI throughout

### Out of scope
- Database schema changes for CSV metadata
- Browser-based CSV upload
- Version history or undo
- Multi-user concurrent editing safeguards

## Architecture & Design Decisions

### 1. New `JobexCore.CsvManager` module

Create a dedicated context module for all CSV file operations (list, read,
create, rename, delete, parse, write). This keeps file I/O logic out of the
Scheduler and LiveViews. The Scheduler's `load_csv/1` already handles parsing;
CsvManager will wrap it with directory awareness and file metadata.

### 2. `JOBEX_CSV_DIR` resolution

Add a `csv_dir/0` function in CsvManager that reads
`System.get_env("JOBEX_CSV_DIR")` at runtime, falling back to
`JobexCore.Scheduler.priv_dir() |> Path.join("csv")`. This single function is
the source of truth for the CSV directory path.

### 3. Selected file tracking via `.jobex.yml`

Use a simple YAML file (`:yamerl` or hand-written key-value since it's just one
field) inside `JOBEX_CSV_DIR`. On startup, CsvManager reads `.jobex.yml` to
restore the selection. On selection change, write the file if the directory is
writable. No database involved.

**Decision:** Use a simple `selected: filename.csv` text format rather than
adding a YAML library dependency. Parse/write it manually — it's a single
key-value pair.

### 4. LiveView for the admin page CSV section

Convert the admin page's CSV section from a static controller-rendered template
to a LiveView (`JobexWeb.Live.Admin.CsvManager`). This enables interactive file
operations (rename, delete confirmation, preview modal) without full page
reloads. Embed it via `live_render/3` in the admin template, matching the
pattern used by `Home` with `Sidebar` and `Body`.

### 5. Schedule page job editing as LiveView

Enhance `JobexWeb.Live.Schedule.Body` to support inline editing. Add
edit/delete event handlers that modify the CSV through CsvManager and refresh
the assigns.

### 6. Responsive strategy

Use DaisyUI's responsive utilities (already in use). Hide preview button on
small screens with `hidden sm:inline-flex`. Use DaisyUI modal component for
preview and delete confirmation.

### 7. Scheduler integration on file select

When a file is selected, call `JobexCore.Scheduler.load_file/1` (new function)
which clears existing jobs and loads from the given filename. This replaces the
current `load_dev_jobs/load_prod_jobs` split with a single generic loader.

## Implementation Steps

### Phase 1: CSV File Management

**1. Add `JobexCore.CsvManager` module**
- Files: `lib/jobex_core/csv_manager.ex`
- Functions:
  - `csv_dir/0` — resolve directory from env var or default
  - `list_files/0` — return list of `%{name, line_count, updated_at}` maps for all `.csv` files in the directory
  - `read_file/1` — return parsed CSV rows for a given filename
  - `create_file/1` — validate name, write file with header row `SCHEDULE,QUEUE,TYPE,COMMAND`
  - `rename_file/2` — validate new name, rename on disk
  - `delete_file/1` — delete file from disk
  - `valid_filename?/1` — check `~r/^[a-z0-9_]+$/` and ensure `.csv` extension
  - `selected_file/0` — read `.jobex.yml` and return selected filename (or nil)
  - `select_file/1` — write selected filename to `.jobex.yml` if directory is writable
  - `writable?/0` — check if `csv_dir()` is writable

**2. Refactor `JobexCore.Scheduler` to support generic file loading**
- Files: `lib/jobex_core/scheduler.ex`
- Add `load_file/1` that takes a filename (not a path), resolves it via `CsvManager.csv_dir/0`, and loads jobs
- Keep `load_dev_jobs/0` and `load_prod_jobs/0` as thin wrappers calling `load_file/1` for backwards compatibility
- Remove the hardcoded `"csv/dev_schedule.csv"` and `"csv/prod_schedule.csv"` paths from private functions; derive them from filename + csv_dir

**3. Add admin CSV management LiveView**
- Files: `lib/jobex_web/live/admin/csv_manager.ex`
- Mount: load file list from `CsvManager.list_files/0`, selected file from `CsvManager.selected_file/0`
- Render: table of files with action buttons, selected file badge, create-file form
- Events:
  - `"select"` — call `CsvManager.select_file/1`, then `Scheduler.load_file/1`, refresh assigns
  - `"delete"` — set a `confirm_delete` assign to show confirmation modal
  - `"confirm_delete"` — call `CsvManager.delete_file/1`, refresh
  - `"cancel_delete"` — clear `confirm_delete` assign
  - `"rename"` — toggle inline rename form for a file row
  - `"save_rename"` — validate and call `CsvManager.rename_file/2`
  - `"preview"` — set `preview_file` assign, load CSV data for modal display
  - `"close_preview"` — clear preview assign
  - `"create"` — validate name and call `CsvManager.create_file/1`

**4. Update admin template to embed new LiveView**
- Files: `lib/jobex_web/controllers/home_html/admin.html.heex`
- Replace the static CSV section with `<%= live_render(@conn, JobexWeb.Live.Admin.CsvManager, id: "csv-manager") %>`
- Keep the existing `Admin.Base` LiveView for DB clear functionality

**5. Update admin controller to pass session data**
- Files: `lib/jobex_web/controllers/home_controller.ex`
- The `admin/2` action may need to pass session data for the LiveView mount (or the LiveView can fetch it directly from CsvManager — preferred approach to avoid session coupling)

**6. Add delete confirmation modal component**
- Files: `lib/jobex_web/live/admin/csv_manager.ex` (inline private component)
- DaisyUI modal with "Are you sure?" text and confirm/cancel buttons
- Triggered by setting `@confirm_delete` assign to the filename

**7. Add preview modal component**
- Files: `lib/jobex_web/live/admin/csv_manager.ex` (inline private component)
- DaisyUI modal showing CSV data in a table
- Hidden on narrow screens via `hidden sm:block` on the preview button
- Triggered by setting `@preview_file` assign

**8. Add filename validation with user feedback**
- Files: `lib/jobex_web/live/admin/csv_manager.ex`
- On create/rename, validate with `CsvManager.valid_filename?/1`
- Show flash error if invalid, explaining the rules

**9. Handle `.jobex.yml` persistence**
- Files: `lib/jobex_core/csv_manager.ex` (already covered in step 1)
- On application startup, if `.jobex.yml` exists and references a valid file, auto-select it
- Format: single line `selected: <filename>.csv`

**10. Auto-load selected file on startup**
- Files: `lib/jobex/application.ex`
- After Scheduler starts, check `CsvManager.selected_file/0` and call `Scheduler.load_file/1` if a file is selected
- Add this as a post-init step or a simple `Task` in the supervision tree after Scheduler

### Phase 2: Job Row Editing

**11. Enhance `Schedule.Body` LiveView with selected file display**
- Files: `lib/jobex_web/live/schedule/body.ex`
- Show the currently selected CSV filename at the top
- Load job rows from `CsvManager.read_file/1` instead of from Quantum's in-memory jobs
- Display SCHEDULE, QUEUE, TYPE, COMMAND columns (already present)

**12. Add job create form to schedule page**
- Files: `lib/jobex_web/live/schedule/body.ex`
- Add a "Create Job" button that reveals an inline form
- Form fields: schedule (cron expression), queue (select: serial/parallel), type (text), command (text)
- On submit: validate cron expression, append row to CSV via `CsvManager.add_job/2`, reload scheduler

**13. Add `CsvManager` job-row CRUD functions**
- Files: `lib/jobex_core/csv_manager.ex`
- `add_job/2` — append a row to the given CSV file
- `update_job/3` — update a row by index in the CSV file
- `delete_job/2` — remove a row by index from the CSV file
- All three: read file, modify rows, write back, reload scheduler

**14. Add inline edit for each job row**
- Files: `lib/jobex_web/live/schedule/body.ex`
- Edit button per row toggles that row into an editable form
- Save calls `CsvManager.update_job/3` and refreshes

**15. Add delete for each job row**
- Files: `lib/jobex_web/live/schedule/body.ex`
- Delete button with inline confirmation (or small confirm prompt)
- Calls `CsvManager.delete_job/2` and refreshes

**16. Reload scheduler after job edits**
- Files: `lib/jobex_web/live/schedule/body.ex`
- After any job CRUD operation, call `Scheduler.load_file/1` with the current file to sync Quantum's in-memory state

### Testing & Polish

**17. Add tests for `CsvManager`**
- Files: `test/jobex_core/csv_manager_test.exs`
- Test file listing, creation, deletion, rename, validation
- Test `.jobex.yml` read/write
- Use a temp directory to avoid polluting `priv/csv`

**18. Add tests for admin CSV LiveView**
- Files: `test/jobex_web/live/admin/csv_manager_test.exs`
- Test mount renders file list
- Test select, create, rename, delete flows via LiveView testing

**19. Add tests for schedule page job editing**
- Files: `test/jobex_web/live/schedule/body_test.exs`
- Test job create, edit, delete flows

**20. Update `HomeController` and schedule page for backwards compatibility**
- Files: `lib/jobex_web/controllers/home_controller.ex`, `lib/jobex_web/controllers/home_html/schedule.html.heex`
- The schedule controller action should pass the selected file info to the template
- The existing devload/prodload buttons in Schedule.Body can remain as shortcuts or be replaced by the file-select flow

## Dependencies & Ordering

1. **Step 1 (CsvManager) must come first** — all other steps depend on this module for file operations
2. **Step 2 (Scheduler refactor) before steps 3, 10, 16** — the admin LiveView and startup auto-load need `load_file/1`
3. **Steps 3-9 (Phase 1 UI) can proceed in parallel** once steps 1-2 are done, but step 4 (template update) depends on step 3 (LiveView exists)
4. **Step 10 (startup auto-load) after steps 1-2** — needs both CsvManager and Scheduler refactor
5. **Steps 11-16 (Phase 2) depend on Phase 1 being complete** — they build on the selected-file concept and CsvManager
6. **Step 13 (job CRUD functions) before steps 12, 14, 15** — UI needs the backend functions
7. **Steps 17-19 (tests) can be written alongside each phase** but are listed last for clarity

## Edge Cases & Risks

- **Read-only `priv/csv` in release**: The default directory in a production release is read-only. CsvManager must handle this gracefully — file create/rename/delete/edit should return clear errors when the directory isn't writable. The `writable?/0` function should gate destructive UI actions.
- **Selected file deleted**: If the selected file is deleted, the scheduler should be cleared and `.jobex.yml` updated. The UI should show "no file selected."
- **Concurrent file access**: Out of scope per spec, but file writes should be atomic where possible (write to temp file, then rename) to avoid partial writes on crash.
- **CSV format edge cases**: Commas in commands would break CSV parsing. The current CSV format uses NimbleCSV which handles quoted fields — ensure the write path also quotes fields containing commas.
- **Empty CSV files**: A newly created file has only the header row. `list_files/0` should show 0 lines (not counting the header). `read_file/1` should return an empty list.
- **Invalid cron expressions in job create/edit**: Validate with `Crontab.CronExpression.Parser.parse/1` before writing to CSV. Show user-friendly error on invalid input.
- **Filename collisions**: `create_file/1` and `rename_file/2` must check if the target filename already exists and return an error.
- **`.jobex.yml` referencing a non-existent file**: On startup, if the referenced file doesn't exist, treat as no selection.

## Testing Strategy

- **Unit tests for `CsvManager`**: Use `System.tmp_dir!/0` to create isolated test directories. Test all CRUD operations, validation, and edge cases (missing files, read-only dirs, invalid names).
- **LiveView tests for admin CSV manager**: Use `Phoenix.LiveViewTest` to simulate user interactions — selecting files, creating, renaming, deleting with confirmation, previewing.
- **LiveView tests for schedule job editing**: Test create, edit, delete flows with LiveView test helpers.
- **Manual testing**: Verify responsive behavior on narrow screens (preview hidden), modal interactions, and scheduler reload after file selection.
- **Integration**: Run `mix test` to ensure no regressions. Start `mix phx.server` and manually verify the admin and schedule pages.

## Open Questions

- [x] Should the "Reload CSV" button on the admin page be removed now that file selection handles loading, or kept as a quick-reload shortcut? Answer: keep the reload button, because it's possible that the CSV could be edited offline with a text editor
- [x] Should Phase 2 job editing validate cron expressions in real-time (as the user types) or only on submit?  Answer: real time is best
- [x] When a file is selected and jobs are loaded, should the old Quantum jobs from a previously selected file be cleared first? (Current `load_dev_jobs` calls `delete_all_jobs` — presumably yes.)  Answer: yes clear out old jobs
- [x] Should the schedule page show Quantum's in-memory jobs (current behavior) or re-read from the CSV file? The spec says "all jobs in the CSV file" which suggests reading from disk. Answer: in-memory, as is done now
- [x] Is there a preferred YAML library to use for `.jobex.yml`, or is the simple hand-parsed format acceptable?  Answer: hand parsing is OK - but wrapper all YAML operations in a standalone module, to make it simpler to migrate to a 3rd party library if it becomes desirable in the future.
