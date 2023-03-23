# Jobex

## Roadmap 

Phase 3 - PENDING
- [x] Copy joba to jobex 
- [x] Rename joba to jobex_core 
- [x] Rename joba_web to jobex_web

- [ ] Copy to dale 
- [ ] Show supervision Tree 
- [ ] Upgrade dbeaver 
- [ ] Explore tables with dbeaver 

- [ ] Display jobs in UI 

- [ ] Quantum: Load test jobs from priv CSV
- [ ] Quantum: Load dev jobs from priv CSV 
- [ ] Quantum: Load production jobs from priv CSV

- [ ] Oban Test 
- [ ] Quantum Test 

- [ ] Run jobs 
- [ ] Display job status on home page 

- [ ] Tie jobs to user accounts 
- [ ] Create an admin account 

Phase 4 - PENDING
- [ ] Let jobex jobs run on remote machines via ssh

Jobs 
- [ ] Weather 
- [ ] Stocks 
- [ ] Backups 
- [ ] Grafana integration
- [ ] Uptime
- [ ] Free memory, etc.

Future 

- [ ] Get rid of compile warnings

- [ ] Study HugInn (Ruby app on Github)

- [ ] V1 - Schedule: Edit the Schedule
- [ ] V1 - Schedule: Multiple Schedules (on/off) (exportable/sharable)
- [ ] V1 - Schedule: Run now button
- [ ] V1 - Schedule: syntax checking of csv file
- [ ] V1 - Schedule: live editing using LiveView
- [ ] V1 - Schedule: add 'install' button
- [ ] V1 - Oban: Add telemetry

- [ ] Package: package as docker container

- [ ] LiveView: Upgrade 
- [ ] LiveView: Add tests

- [ ] Job: job navigation (next/prev, sparklines)

- [ ] Admin: Edit the Title and Logo
- [ ] Admin: Host Limits (disk/memory)
- [ ] Admin: Email Notification
- [ ] Admin: documentation links
- [ ] Admin: editable visualization link
- [ ] Admin: editable notification email
- [ ] Admin: editable time-threshold

- [ ] ObanScheduler - get current list of jobs
- [ ] ObanScheduler - run jobs at top of minute
- [ ] ObanScheduler - display job list on schedule page
- [ ] ObanScheduler - retrieve job list with original scheduler expressions
- [ ] ObanScheduler - update schedule on a single node
- [ ] ObanScheduler - update schedule across all Oban nodes

## 2019 Aug 17 Sat

- [x] Initial Setup
- [x] WebUI
- [x] Running Jobs
- [x] Saving Job Status to Postgres Database

## 2019 Aug 26 Mon

- [x] Refresh UI on command exit
- [x] Show state, type, queue, id, time, duration, last stdout
- [x] Fix states for sleep queues

## 2019 Aug 27 Tue

- [x] Create a release
- [x] Docker Container
- [x] Docker Compose File
- [x] Create production runtime configuration

## 2019 Aug 28 Wed

- [x] Setup serial and parallel queues
- [x] Load jobs from CSV-like lists
- [x] Only prod in releases
- [x] Working distillery release
- [x] Fix favicon bookmark
- [x] Load schedule from yml files (dev_schedule.csv, prod_schedule.csv)
- [x] Add /jobs/:id
- [x] Grafana / Influx Integration
- [x] Migrate from Airflow
- [x] Cleanup Jobs Page
- [x] Add row coloring
- [x] Test deletion of job records and associated results records
- [x] Limit size of job database to 5000 items
- [x] Documentation: Install Systemd Service file
- [x] Autoload CSV Service File on Startup using post-boot-hook

## 2019 Aug 29 Thu

- [x] Add colors for discarded and retryable states
- [x] Add table-links for State/Queue/Type columns
- [x] Fix failing sync tasks
- [x] Capture error code for failed tasks
- [x] Change Admin to Schedule
- [x] Change order of Schedule columns
- [x] Create command query
- [x] Create command link helper
- [x] Add time query (elapsed time > 100 seconds)
- [x] Add threshold links: 100 seconds

## 2019 Aug 31 Sat

- [x] Home: add alerts section
- [x] Home: reduce sidebar-link paddingr
- [x] Layout: Add graph link
- [x] Admin: Clear all records
- [x] Home: move to a live-link route
- [x] Home: Back-button for live-links
- [x] Home: handle params(field, value)

## 2019 Sep 01 Sun

- [x] Home: change to live_link
- [x] Home: move from /home to /
- [x] Finish alert queries
- [x] Convert time-links to emit alert links
- [x] Home: Add pagination HTML
- [x] Home: Add pagination state (home, body)
- [x] Home: Generate pagination html (body)

## 2019 Sep 02 Mon

- [x] Home: Add pagination left-right keys
- [x] Home: Add pagination queries
- [x] Get PushState working with Pagination
- [x] Fix intermittent clock timeout 
- [x] Build the up/down nav bar

## 2019 Sep 02 Tue

- [x] Build sidebar list generator
- [x] Build sidebar up/dn/top/btm function
- [x] Build path generators
- [x] Build link generators
- [x] Working UpArrow/DownArrow to navigate sidebar
- [x] Add line chart icon

## 2019 Sep 06 Fri

- [x] Upgraded phoenix and phoenix_live_view
- [x] Added Ctrl-up/dn and Ctrl-left/right 

## 2019 Sep 09 Mon

- [x] Upgrade to Oban 0.8.0 (fixes Postgres log issue)
- [x] Fix bug with empty database

## 2019 Sep 13 Fri

- [x] Test: Unit Tests
- [x] Test: Hound Tests
- [x] Test: LiveView Tests

## 2020 Jan 09 Thu

- [x] Updated all deps to latest

## 2020 Jan 15 Wed

- [x] Upgrade Elixir to 1.9.2
- [x] Upgrade LiveView to 0.4.1
- [x] Runner: Change from Porcelain to Rambo

## 2020 Jan 16 Thu

- [x] Test LiveView Components

## 2020 Jan 19 Sun

- [x] V0 - WS: read RealTime Phoenix book
- [x] V0 - WS: build CoinBase sockets demo
- [x] V0 - Runner: design runner

## 2021 Mar 28 Sun

- [x] Move JobexCore to JobexCore
- [x] Upgrade to latest LiveView
- [x] Upgrade to latest Phoenix
- [x] Upgrade to latest Oban
- [x] Upgrade LiveEditable to latest LiveView

## 2021 Mar 31 Wed

- [x] Add new WebUi

## 2021 Apr 02 Fri

- [x] Get UI working
- [x] Get Oban working
- [x] Create separate pubsub app (JobexIo)
- [x] Fix icons
- [x] Fix timex issue
- [x] Merge to dev

## 2023 Mar 15 Wed

Prep 
- [x] Read code 
- [x] Study Oban 

Compile 
- [x] Get app to compile 
- [x] Get app to run (Javascript is broken...) 
- [x] Run tests 

## 2023 Mar 21 Tue

Phase 1 - DONE
- [x] Build a demo site with Bootstrap configuration - outside the repo 

FAIL: 
- everything is hard coded to tailwind
- no instructions for converting to bootstrap

Notes: 
- https://fullstackphoenix.com/tutorials/bootstrap-5-and-phoenix-liveview 
- https://pragmaticstudio.com/tutorials/using-tailwind-css-in-phoenix

Try: 
- [x] pragstudio on nested CSS & dartsass 

## 2023 Mar 22 Wed

Phase 2 ACTIVE
- [x] Move code under archive directory 
- [x] Create a new jobex_core application (`mix phx.new jobex_core`), configure tailwind with custom styles 
- [x] Forget nested custom styles for now 
- [x] Use tailwind and custom styles to replicate the JobEx look - HEEX and dead-view 
- [x] No auth, get everything working perfectly 

Phase 2 Tailwind 
- [x] Watch freeCodeCamp.org course 
- [x] Watch Tailwind course 
- [x] Learn layouts (grid, flex) 
- [x] Learn popups (menus, modals) 

Phase 2 UI
- [x] Create live_session in router, setup to use jobs layout
- [x] Create /jobs layout with menu 
- [x] Identify hero icons for menu 
- [x] Use flex to layout home page 

Icons
- clock    | hero-clock
- home     | hero-home
- chart    | hero-presentation-chart-line
- calendar | hero-calendar
- setup    | hero-cog-6-tooth
- help     | hero-question-mark-circle

## 2023 Mar 23 Thu

Phase 2 Backend 
- [x] Add auth to jobex application 
- [x] Copy migrations 
- [x] Setup Oban 
- [x] Setup job scheduling / Quantum
- [x] Copy workers from archive 
- [x] Copy runners from archive 
- [x] Oban interactive in IEX
- [x] Quantum Supervision Tree 
- [x] Quantum Scheduler 
- [x] Copy CSV files 
- [x] Scheduler / get CSV functions working 
- [x] Quantum interactive in IEX

