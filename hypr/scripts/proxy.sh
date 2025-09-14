#!/usr/bin/env bash

# SSH network-aware proxy script
# Usage: This script should be used as ProxyCommand in SSH config
# Example SSH config entry:
# Host myserver
#     ProxyCommand /path/to/this/script %h %p

TARGET_HOST="$1"
TARGET_PORT="$2"

# Validate arguments
if [ -z "$TARGET_HOST" ] || [ -z "$TARGET_PORT" ]; then
    echo "Usage: $0 <host> <port>" >&2
    exit 1
fi

# Get network name using nmcli (NetworkManager)
get_current_network() {
    # Try multiple methods to get network name
    local network=""

    # Method 1: nmcli for WiFi
    network=$(nmcli -t -f NAME connection show --active 2>/dev/null | head -n 1)

    # Method 2: If no active connection, try getting WiFi SSID
    if [ -z "$network" ]; then
        network=$(nmcli -t -f active,ssid dev wifi | grep '^yes:' | cut -d: -f2)
    fi

    echo "$network"
}

CURRENT_NETWORK=$(get_current_network)
HOME_NETWORK=$(cat ~/.secrets/home-network 2>/dev/null || echo "")


# Function to test connectivity with better error handling
test_connection() {
    local host="$1"
    local port="$2"
    local timeout="${3:-3}"

    # Use nc with proper timeout and error suppression
    timeout "$timeout" nc -z "$host" "$port" >/dev/null 2>&1
    return $?
}

# Function to check if WireGuard is properly connected
check_wireguard() {
    # Check if interface exists and is up
    if ! ip link show wg0 >/dev/null 2>&1; then
        return 1
    fi

    # Check if interface has the UP flag
    #if ! ip link show wg0 2>/dev/null | grep -q 'state UP'; then
        #return 1
    #fi

    if [ -n "$HOME_NETWORK" ] && [ "$CURRENT_NETWORK" = "DETNSW" ]; then
        return 1
    fi

    return 0
}

# 1. If on home network, try direct connection first
echo "$HOME_NETWORK"
echo "$CURRENT_NETWORK"
if [ -n "$HOME_NETWORK" ] && [ "$CURRENT_NETWORK" = "$HOME_NETWORK" ]; then
    if test_connection "$TARGET_HOST" "$TARGET_PORT" 5; then
        exec nc "$TARGET_HOST" "$TARGET_PORT"
    fi
fi

# 2. Try WireGuard if available and connected
if check_wireguard; then
    # Connect to server's WireGuard IP (10.0.0.1)
    if test_connection "10.0.0.1" "$TARGET_PORT" 3; then
        exec nc "10.0.0.1" "$TARGET_PORT"
    fi
fi

# 3. Try Shadowsocks/SOCKS5 proxy if available
if pgrep -x "sslocal" >/dev/null 2>&1; then
    # Test if SOCKS proxy is actually listening
    if test_connection "127.0.0.1" "1080" 2; then
        exec nc -X 4 -x 127.0.0.1:1080 "$TARGET_HOST" "$TARGET_PORT"
    fi
fi

# 4. Try other common SOCKS proxies (customize as needed)
# Uncomment and modify if you have other proxies
# if test_connection "127.0.0.1" "9050" 2; then  # Tor
#     exec nc -X 5 -x 127.0.0.1:9050 "$TARGET_HOST" "$TARGET_PORT"
# fi

# 5. Final fallback - direct connection attempt
exec nc "$TARGET_HOST" "$TARGET_PORT"
