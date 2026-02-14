Absolutely! Based on the collection of scripts you shared, I’ve drafted a **comprehensive, professional GitHub README** for your repository. This README explains the purpose, organization, and usage of your backup/sleep management automation scripts. It’s written to be clear and approachable for other sysadmins or devops engineers.

---

# 📦 ZFS & Proxmox Backup Automation Scripts

A set of **bash scripts** to automate **Proxmox configuration backups**, **ZFS dataset syncing**, and **sleep management** on a secondary Proxmox Backup Server (PBS). These scripts handle waking the backup server, disabling sleep during active jobs, monitoring vzdump/syncoid/ZFS activity, sending notifications, and safely re-enabling sleep.

---

## ⚙️ Features

* **Proxmox config backup** – Automatically archives `/etc/pve`, `/etc/network`, `/etc/ssh`, `/etc/apt`, `/etc/fstab`, and `/etc/hosts`.
* **ZFS dataset syncing** – Uses `syncoid` to replicate datasets from the main server to the PBS.
* **PBS sleep management** – Disables sleep while backup/sync jobs are running and re-enables it when complete.
* **Job monitoring** – Waits for ongoing `vzdump`, `syncoid`, or `zfs send/receive` processes before starting new backups.
* **Telegram notifications** – Sends HTML-formatted messages about backup start, success, or failure.
* **Wake-on-LAN support** – Powers on the PBS if needed before backups.
* **Lockfile mechanism** – Prevents multiple backup instances from running simultaneously.
* **Graceful cleanup** – Ensures sleep is always re-enabled even if a script is interrupted.

---

## 🗂 Repository Structure

```
scripts/
├── disable-sleep.sh            # Masks sleep/suspend targets on PBS
├── enable-sleep.sh             # Unmasks sleep/suspend targets on PBS
├── enable-sleep-no-jobs.sh    # Waits for all jobs to finish before enabling sleep
├── mmd_wol.sh                  # Sends Wake-on-LAN packet to PBS
├── notifications.sh            # Functions for Telegram notifications
├── prepare-for-backup.sh       # Prepares PBS & environment before syncing datasets
├── wait-for-pbs.sh             # Waits for PBS to become reachable over SSH
backup.sh                        # Main script to backup Proxmox config + ZFS datasets
```

**Secrets (not committed to GitHub)**

```
secret/
└── saralab_bot.secret          # Telegram bot credentials (TG_BOT_TOKEN, TG_CHAT_ID)
```

---

## 💻 Requirements

* **Linux** (tested on Debian/Ubuntu)
* **Proxmox VE** installed on main server
* **Proxmox Backup Server (PBS)** accessible via SSH
* **ZFS datasets** on main server
* **syncoid** installed on both servers
* **curl** for Telegram notifications
* **wakeonlan** for remotely waking PBS
* Bash 4.4+ recommended

---

## ⚡ Installation

1. Clone the repository:

```bash
git clone https://github.com/mdahamshi/proxmox-scripts.git
cd proxmox-scripts
```

2. Make scripts executable:

```bash
chmod +x scripts/*.sh 
```

3. Add Telegram credentials to `secret/saralab_bot.secret`:

```bash
export TG_BOT_TOKEN="YOUR_BOT_TOKEN"
export TG_CHAT_ID="-100xxxxxxxxx"
```

4. Adjust PBS hostname, dataset paths, and directories in `backup.sh` as needed.

---

## 🏃 Usage

### Run the backup manually

```bash
./zfs_backup_snap.sh
```

The script will:

1. Wake PBS using Wake-on-LAN.
2. Wait for PBS to be reachable.
3. Disable PBS sleep.
4. Wait for any active vzdump/syncoid/ZFS jobs.
5. Backup Proxmox configuration.
6. Sync ZFS datasets using `syncoid`.
7. Send Telegram notifications.
8. Re-enable PBS sleep once all jobs are complete.

### Disable sleep temporarily

```bash
./scripts/disable-suspend.sh 3600
```

* Disables sleep for **1 hour** (3600 seconds) by default.
* Re-enables automatically on exit.

---

## 📦 Telegram Notifications

Notifications include:

* Backup started
* Backup completed successfully
* Backup failed (with error line reference)

Uses the `notifications.sh` helper script with HTML escaping for clean messages.

---

## 🔒 Concurrency & Safety

* Uses a **lockfile** (`/run/zfs-backup.lock`) to prevent multiple backups running at the same time.
* Uses **flock** and `trap` to ensure sleep is re-enabled even if the script is interrupted.
* Waits for `vzdump` and `syncoid` processes before syncing datasets to avoid conflicts.

---

## 🔧 Customization

* Adjust dataset paths:

```bash
DATASET_DIR="mmd_server/data"
PBS_DATA="pbs/data_bkp"
```

* Modify PBS host:

```bash
PBS_SSH="root@main.l"
```

* Change sleep duration or intervals in:

```bash
WAIT_JOBS_ENABLE_SLEEP="$HOME/scripts/enable-sleep-no-jobs.sh"
PBS_WAIT_TIMEOUT=300
PBS_WAIT_INTERVAL=5
```

* Enable logging to a custom file:

```bash
LOG_FILE="/var/log/zfs-backup.log"
```

---

## ✅ License

MIT License – free to use and modify.

---

## 📜 Changelog

**v1.0** – Initial release with:

* Config backup
* ZFS dataset sync
* PBS sleep management
* Wake-on-LAN support
* Telegram notifications
* Lockfile concurrency handling

