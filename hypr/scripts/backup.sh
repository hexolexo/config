#!/bin/bash
USER=$(whoami)
HOST="$USER@server"
REMOTE_PATH="/home/$USER/backups"
LOCALHOME="/home/$USER"
COMMAND="nohup bash /home/$USER/scripts/archive.sh > /dev/null 2>&1 & disown" # Disowns the program allowing the user to disconnect without disrupting archival
SCRIPT="/home/$USER/.config/hypr/scripts/archive.sh"
LOG_FILE="/home/$USER/logs/rsync.log"
#if ! ping server -c 1 &> /dev/null; then
#    echo "Server Unreachable"
#    exit 1
#fi
ssh $HOST "mkdir -p ~/scripts ~/logs ~/backups"
log_message() {
    local message="$1"
    ssh $HOST "echo \"$(date '+%Y-%m-%d-|-%H:%M:%S') - $message\" >> $LOG_FILE" &
}
log_message "Sending archive.sh"

if scp "$SCRIPT" "$HOST:~/scripts/archive.sh"; then
  log_message "Archive.sh updated"
else
  echo "Error: Cannot access server"
  exit 1
fi
log_message "RSYNC STARTED"
SOURCE_DIRS=(
    ".config"
    "Documents"
    "Programming"
    #".ssh" # moved
    #".gnupg"
    ".password-store"
    "Music"
)

for dir in "${SOURCE_DIRS[@]}"; do
    rsync -avz --exclude='.git/' --exclude='*.pdf' --delete "$LOCALHOME/$dir" "$HOST":"$REMOTE_PATH" &
done
log_message "Encrypting keys"
BACKUP_DIR="/tmp/secure_backup_$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"
cp -r ~/.ssh "$BACKUP_DIR/"
cp -r ~/.gnupg "$BACKUP_DIR/"
tar czf - -C /tmp "$(basename "$BACKUP_DIR")" | gpg -c > "$BACKUP_DIR.tar.gz.gpg"
rsync -avz --delete "$BACKUP_DIR.tar.gz.gpg" "$HOST":"$REMOTE_PATH"
rm -rf "$BACKUP_DIR" "$BACKUP_DIR.tar.gz.gpg"


wait # Wait for all to finish before continuing
log_message "RSYNC FINISHED"
ssh $HOST "$COMMAND"

