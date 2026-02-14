#!/usr/bin/env bash
set -euo pipefail

source ~/scripts/notifications.sh
source ~/secret/saralab_bot.secret

LOCKFILE="/run/zfs-backup.lock"
START_TIME=$(date +%s)

PBS_HOST="pbs.l"
PBS_DATA="pbs/data_bkp"
PBS_VMS="pbs/vms_bkp"
DATASET_DIR="mmd_server/data"
CFG_DIR="/mmd_server/bkp/config"
VZDUMP_LOCK="/var/run/vzdump.lock"
LOG_FILE="/var/log/zfs-backup.log"
PBS_USER="root"
PBS_SSH="root@main.l"

PREPARE_FOR_BKP="$HOME/scripts/prepare-for-backup.sh"

WAIT_JOBS_ENABLE_SLEEP="$HOME/scripts/enable-sleep-no-jobs.sh"

PBS_WAIT_TIMEOUT=300   # seconds
PBS_WAIT_INTERVAL=5

# Redirect stdout/stderr to log file and console
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

# Locking
exec 9>"$LOCKFILE"
flock -n 9 || { echo "Another backup is running, exiting."; exit 0; }


      
trap 'echo "⚠️ Backup interrupted!"; exit 1' INT  # Handle Ctrl+C
trap 'LINE=$LINENO; send_notification "ZFS Backup" "Failed" "Backup failed ❌ at line $LINE"; exit 1' ERR


echo "=== Backup started at $(date -Is) ==="

### ==============================
### Wait for vzdump
### ==============================
wait_for_vzdump() {
    [[ -e "$VZDUMP_LOCK" ]] || return 0
    echo "Waiting for vzdump..."
    exec 8<"$VZDUMP_LOCK"
    flock 8
    exec 8>&-
}

wait_for_vzdump




### ==============================
### 1️⃣ Backup Proxmox config
### ==============================
mkdir -p "$CFG_DIR"
CFG_FILE="$CFG_DIR/pve-config-$(date +%F).tar.gz"
echo "Creating Proxmox config backup..."
tar -czf "$CFG_FILE" \
  /etc/pve \
  /etc/network \
  /etc/ssh \
  /etc/apt \
  /etc/fstab \
  /etc/hosts
echo "✅ Config backup done: $CFG_FILE"

wait_for_vzdump

SYNCOID_CMD=(
  syncoid
  --quiet
  --no-sync-snap
  --no-privilege-elevation
  --force-delete
  --recursive
)

### ==============================
### Wake PBS & prepare
### ==============================
"$PREPARE_FOR_BKP"

echo "Syncing datasets to PBS..."
trap - ERR

"${SYNCOID_CMD[@]}" "$DATASET_DIR" "$PBS_HOST:$PBS_DATA" 2>&1 | tee -a "$LOG_FILE"
status=${PIPESTATUS[0]}  # exit status of syncoid

trap 'LINE=$LINENO; send_notification "ZFS Backup" "Failed" "Backup failed ❌ at line $LINE"; exit 1' ERR

if [ $status -eq 0 ] || [ $status -eq 2 ]; then
    echo "✅ Datasets synced (or nothing new to sync)"
else
    echo "❌ Dataset sync failed"
    exit 1
fi
### ==============================
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
DURATION="$((ELAPSED / 3600))h $(((ELAPSED / 60) % 60))m $((ELAPSED % 60))s"

echo "=== Backup finished in $DURATION ==="
send_notification "ZFS Backup" "Success" "Backup completed successfully in $DURATION ✅"
"$WAIT_JOBS_ENABLE_SLEEP"