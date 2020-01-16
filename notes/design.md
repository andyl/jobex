# Jobex

Cron-Like Work Execution

## Goals

- like Airflow
- but simpler
- just for running scheduled bash jobs

## Libraries

| LIB       | DESCRIPTION           |
|-----------|-----------------------|
| quantum   | cron-style scheduling |
| rambo     | process execution     |
| oban      | async job runner      |

## Umbrella Apps

| APP        | DESCRIPTION                                |
|------------|--------------------------------------------|
| jobex_data | business logic, job execution, persistence |
| jobex_term | terminal-ui                                |
| jobex_web  | web-ui                                     |

## Versions

V0: Internal
- internal use
- schedule editing
- telemetry
- systemd deployment

V1: Internal / Websocket
- separate runner and scheduler services
- scheduler has a websocket server
- runner as an elixir module using Rambo
- runner connect via websockets

V2: External / Community
- use for CHAOSS community
- docker deployment for scheduler (application and database)
- Runner as NPM, Python or Rust Client

V3: SAAS
- User Accounts
- Group Accounts
