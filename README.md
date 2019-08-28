# Crow

Cron-like Workflow

## About

- Runs jobs in a cron-like fashion
- Saves statistics - execution time, return codes, stdout, stderr
- Simple

## Requirements

- Ubuntu Host running 18.04
- SystemD
- Postgres (user/pass = postgres/postgres)

## Installing

- Download and untar the release file
- Run `sudo bin/crow/setup.sh` to 
- Start the process `sudo systemd start crow`
- Browse to `locahost:5070`

## Job Definitions

Job definitions are stored in a csv file, in a table like so:

| Schedule  | Queue    | Type | Command            | Notes              |
|-----------|----------|------|--------------------|--------------------|
| * * * * * | serial   | test | whoami             | just run 'whoami'  |
| * * * * * | parallel | test | echo "hello world" | echo "hello world" |

Here's what the columns contain:

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

_Notes_

A short descriptive note






