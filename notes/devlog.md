# Crow

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

## TBD

- [ ] Fix failing sync tasks
- [ ] Capture error code as discarded

- [ ] Enable back-button for live-links

- [ ] Setup Script: SystemD Service Initiation

- [ ] Setup Script: DB create
- [ ] Setup Script: DB migrate

- [ ] Email Notification
- [ ] LiveView Schedule Editing
