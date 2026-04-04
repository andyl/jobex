# CSV Management

## Summary

Add a CSV file management system to Jobex. Phase 1 adds an admin page where
users can list, select, rename, preview, and delete CSV schedule files stored in
a configurable directory. Phase 2 adds inline job editing on the schedule page,
allowing users to create, edit, and delete individual job rows within the
selected CSV file.

## Motivation

- CSV schedule files are currently managed by hand on disk — no UI for
  browsing, selecting, or modifying them
- Operators need a way to switch between schedule files without restarting the
  application or editing config
- Editing individual job rows requires opening the CSV in a text editor, which
  is error-prone and has no validation

## Requirements

### CSV root directory

- Introduce a `JOBEX_CSV_DIR` environment variable that sets the directory
  where CSV schedule files are stored
- Default to `priv/csv` (read-only) when the variable is not set

### Admin page — file listing (Phase 1)

- On the admin page, display a list of all CSV files found in `JOBEX_CSV_DIR`
- For each file show: file name, number of lines, last updated timestamp
- Action buttons per file: select, rename, preview, delete
- Highlight or badge the currently selected file
- Provide a button or form to create a new CSV file

### File preview (Phase 1)

- Preview shows the CSV data in a popup modal, sidebar, or separate page
- Disable preview on narrow/mobile screens

### File delete (Phase 1)

- Delete requires a confirmation dialog before proceeding

### File rename (Phase 1)

- Enforce filename rules: lowercase letters, numbers, and underscores only; no
  spaces allowed

### File create (Phase 1)

- New file names follow the same filename rules as rename
- Create an empty CSV file with the standard header row

### File selection and loading (Phase 1)

- When a file is selected, load its contents and start running the jobs defined
  within it
- If `JOBEX_CSV_DIR` is writable, persist the selected filename in a
  `.jobex.yml` file inside that directory
- Do not store the selected filename in the database

### Responsive UI (Phase 1)

- Every screen must work on mobile with responsive layout
- Acceptable to disable certain features (e.g., preview) on narrow screens

### Schedule page — job listing (Phase 2)

- On the schedule page, show the currently selected CSV file name
- List all jobs from the selected CSV file
- For each job show: SCHEDULE, QUEUE, TYPE, COMMAND
- Provide edit and delete buttons per job row
- Provide a create-job button or inline form

### Job editing (Phase 2)

- When a job row is edited or deleted, update the CSV file on disk
- When a new job is created, append it to the CSV file

## Acceptance criteria

- `JOBEX_CSV_DIR` environment variable is respected; defaults to `priv/csv`
- Admin page lists all CSV files with name, line count, and last-updated
- Select, rename, preview, and delete actions work correctly
- Filename validation rejects invalid characters and spaces
- Selected file is persisted in `.jobex.yml` when the directory is writable
- Selecting a file loads its jobs into the scheduler
- Preview is hidden on narrow screens
- Delete shows a confirmation dialog
- Schedule page displays jobs from the selected CSV with SCHEDULE, QUEUE, TYPE,
  COMMAND columns
- Job create, edit, and delete update the CSV file on disk
- All UI screens are responsive and usable on mobile

## Out of scope

- Database schema changes for storing CSV metadata
- Uploading CSV files through the browser
- Version history or undo for CSV edits
- Multi-user concurrent editing safeguards
