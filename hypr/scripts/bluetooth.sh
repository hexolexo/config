#!/bin/bash

readarray -t devices < ~/.secrets/bluetooth_headphones

#device_address="$(cat ~/.secrets/bluetooth_headphones)"
notification_Length=3000


connectToDevice() {
    hyprctl notify -1 "$notification_Length" "rgb(74c7ec)" "Connection Successful"&
    pamixer -u
    pgrep -x mpv || mpv --loop-playlist --idle --input-ipc-server=/tmp/mpvsocket --volume=70
}

disconnectFromDevice() {
    echo '{"command": ["set_property", "pause", true]}' | socat - "/tmp/mpvsocket"
    hyprctl notify -1 "$notification_Length" "rgb(74c7ec)" "Attempting to Disconnect"&
    pamixer -m
    if bluetoothctl "disconnect" "$device_address"; then
        pkill mpv
        hyprctl notify -1 "$notification_Length" "rgb(74c7ec)" "Disconnect Successful"&
    else
        hyprctl notify -1 "$notification_Length" "rgb(74c7ec)" "Disconnect Failed"&
    fi
}



if ! systemctl is-active bluetooth; then
    sudo /sbin/systemctl start bluetooth.service
    sleep 2
fi


for device_address in "${devices[@]}"; do
    if bluetoothctl info "$device_address" 2>/dev/null | grep -q "Connected: yes"; then
        disconnectFromDevice
        exit
    fi
done

for device_address in "${devices[@]}"; do
    hyprctl notify -1 "$notification_Length" "rgb(74c7ec)" "Attempting to Connect"&
    if timeout 3 bluetoothctl connect "$device_address" &>/dev/null; then
        connectToDevice
        exit
    fi
done
