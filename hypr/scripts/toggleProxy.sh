#!/bin/bash

# Function to kill all Firefox instances
kill_firefox() {
    echo "Killing all Firefox instances..."
    pkill firefox
    sleep 2
}

# Function to start sslocal
start_sslocal() {
    echo "Starting sslocal..."
    sslocal -c ~/.secrets/ss.json &
}

modify_ff_settings() {
    cd ~/.mozilla/firefox/*.default || { echo "FACK"; exit 1; }
    echo $1 $2
    sed -i 's/user_pref("'$1'",.*);/user_pref("'$1'", '$2');/' prefs.js # Fucking vodo regex magic I found on askubuntu
    grep -q $1 prefs.js || echo "user_pref(\"$1\",$2);" >> prefs.js # https://askubuntu.com/questions/313483/how-do-i-change-firefoxs-aboutconfig-from-a-shell-script
}

# Function to kill sslocal
kill_sslocal() {
    echo "Killing sslocal..."
    pkill sslocal
}

hyprctl notify -1 3000 "rgb(74c7ec)" "Killing firefox"&
kill_firefox 
# Check if sslocal is running
if pgrep sslocal > /dev/null; then
    # If sslocal is running, kill it
    kill_sslocal
    modify_ff_settings "network.proxy.type" 0
    hyprctl notify -1 3000 "rgb(74c7ec)" "Proxy Disabled"&
    firefox&
else
    # If sslocal is not running, start it
    start_sslocal
    modify_ff_settings "network.proxy.type" 1
    hyprctl notify -1 3000 "rgb(74c7ec)" "Proxy Enabled"&
    firefox&
fi

