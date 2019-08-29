#!/usr/bin/env sh

echo LOADING PROD JOBS

echo $RELEASE_ROOT_DIR

$RELEASE_ROOT_DIR/bin/crow command CrowData.Scheduler.load_prod_jobs
