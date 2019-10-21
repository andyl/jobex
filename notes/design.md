# CROW

Cron-Like Workflow

## Goals

- like Airflow
- but simpler
- just for running scheduled bash jobs

## Libraries

| LIB       | DESCRIPTION           |
|-----------|-----------------------|
| quantum   | cron-style scheduling |
| porcelain | process execution     |
| oban      | async job runner      |

## Umbrella Apps

| APP        | DESCRIPTION                                |
|------------|--------------------------------------------|
| jobex_data | business logic, job execution, persistence |
| jobex_term | terminal-ui                                |
| jobex_web  | web-ui                                     |

