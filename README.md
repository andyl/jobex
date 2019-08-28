# Crow

Cron-like Workflow

## About

- Runs jobs in a cron-like fashion
- Job statistics: execution time, return codes, stdout, stderr
- Simple

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

