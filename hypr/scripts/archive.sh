#!/bin/bash
#This file must be placed in the remote server under ~/scripts/archive.sh
USER=$(whoami)
LOG_FILE="/home/$USER/logs/archive.log"
DIR_PATH="/home/$USER/backups"
ARCHIVE_NAME="/home/$USER/archive/$(date '+%Y-%m-%d %H:%M:%S').tar.gz"

log_message() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> $LOG_FILE
}

# Check if the provided path is a directory
if [ ! -d "$DIR_PATH" ]; then
    log_message "Error: $DIR_PATH is not a directory."
    exit 1
fi
log_message "Begun archiving"
# Create the archive
tar -cf - --exclude="*.mp3" "$DIR_PATH" \
    | pigz -9 > "$ARCHIVE_NAME"

# Check if the archive creation was successful
if [ $? -eq 0 ]; then
  log_message "Archive created successfully: $ARCHIVE_NAME"
else
  log_message "Error: Failed to create archive."
  exit 1
fi

