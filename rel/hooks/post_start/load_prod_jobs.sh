#!/usr/bin/env sh

echo LOADING PROD JOBS
echo $RELEASE_ROOT_DIR
echo SLEEPING 10 SECONDS

sleep 10

echo LOADING NOW!!!

$RELEASE_ROOT_DIR/bin/crow rpc "CrowData.Scheduler.load_prod_jobs"
