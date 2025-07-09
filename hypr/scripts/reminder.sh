#!/bin/bash

# Function to start the timer
start_timer() {
    duration=$1
    notify "Timer set for $duration seconds."
    sleep "$duration"
}

notify() {
    hyprctl notify -1 3000 "rgb(74c7ec)" "$1"&
}
pkill wofi && exit
input=$(echo "" | wofi --dmenu --prompt "Set Timer (e.g., 50 or 1:50):")
message=$(echo "" | wofi --dmenu --prompt "Set a message (can be blank):")

if [[ -z $input ]]; then
    exit
fi

if [[ $input =~ ^([0-9]+):([0-9]+)$ ]]; then # gpt has some pretty good code snipits
    minutes=${BASH_REMATCH[1]}
    seconds=${BASH_REMATCH[2]}
    total_seconds=$((minutes * 60 + seconds))
elif [[ $input =~ ^([0-9]+)$ ]]; then
    total_seconds=$input
else
    notify "Please enter a valid time format (e.g., 50 or 1:50)"
    exit
fi
start_timer "$total_seconds"

if [[ -z $message ]]; then
    notify "Timer has gone off"
    exit
fi

notify "$message"
