#!/bin/bash

device_address="$(cat ~/.secrets/bluetooth_headphones)"
notification_Length=3000

connectToDevice() {
    hyprctl notify -1 "$notification_Length" "rgb(74c7ec)" "Attempting to Connect"&
    if 	bluetoothctl "connect" "$device_address"; then
        hyprctl notify -1 "$notification_Length" "rgb(74c7ec)" "Connection Successful"&
        pamixer -u
        pgrep -x mpv || mpv --loop-playlist --idle --input-ipc-server=/tmp/mpvsocket
    else
        hyprctl notify -1 "$notification_Length" "rgb(74c7ec)" "Connection Failed"&
        pamixer -m
    fi

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

if bluetoothctl info "$device_address" | grep -q "Connected: yes"; then
    disconnectFromDevice
else
    connectToDevice
fi
