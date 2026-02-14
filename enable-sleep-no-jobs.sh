#!/usr/bin/env bash
set -euo pipefail

ENABLE_SLEEP_SCRIPT="$HOME/scripts/enable-sleep.sh"
CHECK_INTERVAL=60
PBS_SSH="root@main.l"

echo "⏳ Waiting for backups and ZFS sync jobs to finish..."

is_busy() {
    ps -ef | grep -q '[v]zdump' && return 0
    ps -ef | grep -q '[s]yncoid' && return 0
    ps -ef | grep -q '[z]fs send' && return 0
    ps -ef | grep -q '[z]fs receive' && return 0
    return 1
}

while is_busy; do
    echo "🔄 Backup or sync still running, waiting $CHECK_INTERVAL seconds..."
    sleep "$CHECK_INTERVAL"
done

echo "✅ No vzdump or syncoid activity detected."
echo "➡ Enabling sleep on PBS..."

ssh "$PBS_SSH" "$ENABLE_SLEEP_SCRIPT"
echo "✔ Sleep re-enabled."
