# Jobex

Jobex is cron-like workflow - Cron meets Airflow.

- Runs jobs periodically using cron-like scheduling
- Captures job statistics: execution time, status, stdout, stderr
- Super Simple

Because we need to access local scripts, `Jobex` is packaged as an Elixir
release managed by SystemD, rather than a Docker container.

## Jobex simply runs jobs

- you define a job schedule in a CSV file
- you can setup two CSV files: DEV for testing and PROD for production
- jobs can be any executable or BASH/PYTHON/RUBY script on your system
- failing jobs will be retried three times before giving up
- the job history is capped at 5000 items 

## System requirements

- Ubuntu Host running 18.04
- SystemD
- Postgres (user/pass = postgres/postgres)

## Installing

- Clone the repo
- `MIX_ENV=prod mix do deps.get, ecto.create, ecto.migrate, distillery.release`
- Start the release
- Browse to `locahost:5070`

## Job schedules

Job schedules are stored in csv files:

- apps/jobex_data/priv/dev_schedule.csv
- apps/jobex_data/priv/prod_schedule.csv

CSV files can be edited to run your own commands.  The CSV columns include:

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

- edit the SystemD service file in `rel/jobex.service`
- `sudo cp rel/jobex.service /etc/systemd/system`
- `sudo chmod 644 /etc/systemd/system/jobex.service`

Start the service with SystemD

- `sudo systemctl start jobex`
- `sudo systemctl status jobex`
- `sudo systemctl restart jobex`
- `sudo systemctl stop jobex`
- `sudo journalctl -u jobex -f`

Make sure your service starts when the system reboots

- `sudo systemctl enable jobex`

Reboot and test!
