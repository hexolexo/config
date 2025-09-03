#!/bin/bash
#if [ -t 1 ]; then
    #use_pty="-t"
#else
    #use_pty=""
#fi

if [ -p /dev/stdin ] || [ -p /dev/stdout ]; then
    use_pty=""
else
    use_pty="-t"
fi

# Get all args to parse into the shell
command="$*"

wifiname=$(nmcli connection show --active | awk 'NR>1 {print $1}' | head -n 1)

if [ "$wifiname" == "$(cat ~/.secrets/home-name)" ]; then # If local network
    if [ -n "$command" ]; then
        ssh $use_pty server "$command"
    else
        ssh server
    fi
elif pgrep -x "sslocal" > /dev/null; then # If remote AND shadowsocks
    if [ -n "$command" ]; then
        proxychains4 -q ssh $use_pty server "$command"
    else
        proxychains4 -q ssh server
    fi
elif ip link show wg0 2>/dev/null | grep -q '<.*UP.*LOWER_UP.*>'; then
    if [ -n "$command" ]; then
        ssh $use_pty 10.0.0.1 -p 6000 "$command"
    else
        ssh 10.0.0.1 -p 6000 "$command"

    fi
else
    # Fallback to home connection
    if [ -n "$command" ]; then # This doesn't work due to removed port forwarding
        ssh $use_pty home "$command"
    else
        ssh home
    fi
fi

