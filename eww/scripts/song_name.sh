#!/bin/bash
SOCKET_PATH="/tmp/music_socket"
rm $SOCKET_PATH && touch $SOCKET_PATH
get_name() {
    MPV_RESP=$(printf '{ "command": ["get_property", "%s" ] }\n' "path" | socat - "/tmp/mpvsocket" 2>/dev/null)

    DATA="$(jq -r 'select(.error == "success") | .data' <<<"$MPV_RESP" | sed -E 's|(/[^/]+)+/([^/]*)\.[^/]*$|\2|')"
    if [ -n "$DATA" ]; then
        echo ""$DATA" | " # what?
    fi
}
polling() {
    while true; do
        get_name
        sleep 10
    done
}
polling&
socat - UNIX-LISTEN:$SOCKET_PATH,fork | while read -r line; do
    get_name
done

