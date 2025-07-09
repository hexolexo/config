MPV_RESP=$(printf '{ "command": ["get_property", "%s" ] }\n' "path" | socat - "/tmp/mpvsocket" 2>/dev/null)
DATA="$(jq -r 'select(.error == "success") | .data' <<<"$MPV_RESP" | sed -E 's|(/[^/]+)+/([^/]*)\.[^/]*$|\2|')"
if [ -n "$DATA" ]; then
    echo "Now Playing: $DATA"
fi
