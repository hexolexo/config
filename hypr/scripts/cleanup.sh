#!/bin/bash
ARCHIVE_PATH="/home/hexolexo/archive"
RETENTION_DAYS=7
OLD_BACKUPS=$(find $ARCHIVE_PATH -type f -mtime +$RETENTION_DAYS -exec ls -lh {} \;)

if [ -z "$OLD_BACKUPS" ]; then
    echo "No old backups found."
else
    echo "The following backups are older than $RETENTION_DAYS days:"
    echo "$OLD_BACKUPS"

    read -p "Do you want to delete these old backups? (y/n): " response
    if [ "$response" == "y" ] || [ "$response" == "Y" ]; then
        find $ARCHIVE_PATH -type f -mtime +$RETENTION_DAYS -exec rm {} \;
        echo "Old backups have been deleted."
    else
        echo "Old backups have not been deleted."
    fi
fi

