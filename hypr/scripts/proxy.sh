#!/usr/bin/env bash

# Host server
#     ProxyCommand /path/to/this/script %h %p

TARGET_HOST="$1"
TARGET_PORT="$2"

# Validate arguments
if [ -z "$TARGET_HOST" ] || [ -z "$TARGET_PORT" ]; then
    echo "Usage: $0 <host> <port>" >&2
    exit 1
fi

networkName=$(nmcli connection show --active | awk 'NR>1 {print $1}' | head -n 1)
homeNetworkName=$(cat ~/.secrets/home-network)
if [ "$networkName" == "$homeNetworkName" ]; then
    exec nc "$TARGET_HOST" "$TARGET_PORT"
fi

if ping -c 1 -W 3 10.0.0.1 >/dev/null 2>&1; then
    exec nc "10.0.0.1" "$TARGET_PORT"
fi
if pgrep -x "sslocal" >/dev/null 2>&1; then
    exec nc -X 4 -x 127.0.0.1:1080 "$TARGET_HOST" "$TARGET_PORT"
fi
exit 1 # fack
