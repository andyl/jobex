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

| APP       | DESCRIPTION                                |
|-----------|--------------------------------------------|
| crow_data | business logic, job execution, persistence |
| crow_term | terminal-ui                                |
| crow_web  | web-ui                                     |

