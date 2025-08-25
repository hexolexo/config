#!/bin/bash

kill_firefox() {
    pkill librewolf
    sleep 2 # yay race conditions
}

modify_ff_settings() {
    kill_firefox
    cd ~/.librewolf/*.default || { echo "FACK"; exit 1; }
    echo $1 $2
    sed -i 's/user_pref("'$1'",.*);/user_pref("'$1'", '$2');/' prefs.js # Fucking vodo regex magic I found on askubuntu
    grep -q $1 prefs.js || echo "user_pref(\"$1\",$2);" >> prefs.js # https://askubuntu.com/questions/313483/how-do-i-change-firefoxs-aboutconfig-from-a-shell-script
}

if pgrep sslocal > /dev/null; then
    pkill sslocal
    hyprctl notify -1 3000 "rgb(74c7ec)" "Proxy Disabled"&
    modify_ff_settings "network.proxy.type" 0
else
    sslocal -c ~/.secrets/ss.json &
    hyprctl notify -1 3000 "rgb(74c7ec)" "Proxy Enabled"&
    modify_ff_settings "network.proxy.type" 1
fi

