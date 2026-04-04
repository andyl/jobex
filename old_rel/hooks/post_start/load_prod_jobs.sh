#!/usr/bin/env sh

echo ">>> LOADING PROD JOBS"
echo $RELEASE_ROOT_DIR
echo ">>> SLEEP 10 SECONDS"

sleep 10

echo ">>> LOADING START"
echo "vvvvvvvvvvvvvvvvvv"
echo
$RELEASE_ROOT_DIR/bin/jobex rpc "JobexCore.Scheduler.load_prod_jobs"
echo
echo "^^^^^^^^^^^^^^^^^^"
echo ">>> LOADING DONE"
