#!/usr/bin/env bash
set -euo pipefail


source ~/scripts/wait-for-pbs.sh

RUN_WOL=~/scripts/mmd_wol.sh

DISABLE_SLEEP_SCRIPT="~/scripts/disable-sleep.sh"




disable_pbs_sleep() {
    echo "⛔ Disabling sleep on PBS..."
    ssh "$PBS_HOST_SSH" "$DISABLE_SLEEP_SCRIPT"
}



"$RUN_WOL"

wait_for_pbs

disable_pbs_sleep

sleep 2


