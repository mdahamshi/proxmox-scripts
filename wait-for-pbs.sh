#!/usr/bin/env bash
set -euo pipefail

PBS_SSH="root@main.l"

PBS_WAIT_TIMEOUT=300   # seconds
PBS_WAIT_INTERVAL=5


wait_for_pbs() {
    echo "⏳ Waiting for PBS to become reachable..."
    local waited=0

    until ssh -o ConnectTimeout=5 -o BatchMode=yes "$PBS_SSH" "true" 2>/dev/null; do
        sleep "$PBS_WAIT_INTERVAL"
        waited=$((waited + PBS_WAIT_INTERVAL))

        if (( waited >= PBS_WAIT_TIMEOUT )); then
            echo "❌ PBS not reachable after ${PBS_WAIT_TIMEOUT}s"
            return 1
        fi
    done

    echo "✅ PBS is online"
}


