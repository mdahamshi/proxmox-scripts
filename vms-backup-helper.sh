#!/usr/bin/env bash
set -euo pipefail


source ~/scripts/wait-for-pbs.sh

RUN_WOL=~/scripts/mmd_wol.sh

PREPARE_FOR_BKP="$HOME/scripts/prepare-for-backup.sh"
WAIT_JOBS_ENABLE_SLEEP="$HOME/scripts/enable-sleep-no-jobs.sh"


"$PREPARE_FOR_BKP"
sleep 300
"$WAIT_JOBS_ENABLE_SLEEP"