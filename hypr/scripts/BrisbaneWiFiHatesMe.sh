#!/bin/bash

# Function to disconnect from Wi-Fi
disconnect_wifi() {
    nmcli device disconnect wlp1s0
}

# Function to reconnect to Wi-Fi
reconnect_wifi() {
    nmcli device wifi connect "$(cat ~/.secrets/friends-wifi-name)"
}

while true; do
    if ! ping -c 4 google.com &> /dev/null; then
        echo "Ping to Google failed. Disconnecting and reconnecting to Wi-Fi..."
        disconnect_wifi
        sleep 5  # Wait for a few seconds to ensure the disconnect is complete
        reconnect_wifi
        echo "Reconnected to Wi-Fi."
    fi
    sleep 60
done


