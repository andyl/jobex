# Crow

Crow is cron-like workflow - Cron meets Airflow.

- Runs jobs periodically using cron-like scheduling
- Captures job statistics: run time, status codes, stdout, stderr
- Super Simple

Because we need to access local scripts, `Crow` is packaged as an Elixir
release managed by SystemD, rather than a Docker container.

## Requirements

- Ubuntu Host running 18.04
- SystemD
- Postgres (user/pass = postgres/postgres)

## Installing

- Clone the repo
- `MIX_ENV=prod mix do deps.get, ecto.create, ecto.migrate, distillery.release`
- Start the release
- Browse to `locahost:5070`

## Job Schedules

Job schedules are stored in csv files:

- apps/crow_data/priv/dev_schedule.csv
- apps/crow_data/priv/prod_schedule.csv

CSV files can be edited to run your own commands:

| Schedule  | Queue    | Type | Command            |
|-----------|----------|------|--------------------|
| * * * * * | serial   | test | whoami             |
| * * * * * | parallel | test | echo "hello world" |

_Schedule_

- a cron-like time schedule
- any cron-compatible syntax is OK

_Queue_

- there are two queues: `serial` and `parallel`
- `serial` runs one job at a time
- `parallel` runs multiple jobs concurrently

_Type_

- just a user-defined label
- no spaces allowed

_Command_

- any command you like
- commands are run with 'user' permission
- pipes and redirects not allowed

## Using SystemD

Create the database and run the migrations.  Then:

- edit the SystemD service file in `rel/crow.service`
- `sudo cp rel/crow.service /etc/systemd/system`
- `sudo chmod 644 /etc/systemd/system/crow.service`

Start the service with SystemD

- `sudo systemctl start crow`
- `sudo systemctl status crow`
- `sudo systemctl restart crow`
- `sudo systemctl stop crow`
- `sudo journalctl -u crow -f`

Make sure your service starts when the system reboots

- `sudo systemctl enable crow`

Reboot and test!
