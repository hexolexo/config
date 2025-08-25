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

if [ "$wifiname" == "$(cat ~/.secrets/home-name)" ]; then
    if [ -n "$command" ]; then
        ssh $use_pty server "$command"
    else
        ssh server
    fi
elif pgrep -x "sslocal" > /dev/null; then
    if [ -n "$command" ]; then
        proxychains4 -q ssh $use_pty server "$command"
    else
        proxychains4 -q ssh server
    fi
else
    # Fallback to home connection
    if [ -n "$command" ]; then # This doesn't work due to removed port forwarding
        ssh $use_pty home "$command"
    else
        ssh home
    fi
fi

