#!/bin/bash

# Function to check if the current time is past 8:30 AM
check_time() {
    current_time=$(date +%H:%M)
    if [[ "$current_time" > "$target_time" ]]; then
        echo "The time is past $target_time"
        hyprctl hyprsunset temperature 1000 
        return 1
    else
        echo "The time is not past $target_time yet."
        return 0
    fi
}

current_time=$(date +%H:%M)

target_time="21:20"
if [[ "$current_time" < "$target_time" ]]; then
    target_seconds=$(date -d "$target_time" +%s)
    current_seconds=$(date +%s)
    sleep_duration=$((target_seconds - current_seconds - 300))
else
    echo "The time is already past $target_time AM."
    exit 0
fi

if [ ! $sleep_duration -lt 0 ]; then
    echo "The time is already past $target_time AM."
    # Sleep until 5 minutes before target_time
    sleep $sleep_duration
fi

while true; do
    if check_time; then
        break
    fi
    sleep 60
done

