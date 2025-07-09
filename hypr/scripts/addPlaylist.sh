ifShouldShuffle() {
    if [[ ! -f "$SONG_PATH/playlistShouldShuffle" ]]; then
        sort
    else
        shuf
    fi
}


pkill wofi && exit
SONG_PATH="$HOME/Music/$(find $HOME/Music -mindepth 1 -maxdepth 1 -type d -print | sed "s|$HOME/Music/||" |  wofi --dmenu)"
if [ "$SONG_PATH" == "$HOME/Music/" ]; then
    exit
fi
echo "playlist-clear" | socat - /tmp/mpvsocket
echo "playlist-remove 0" | socat - /tmp/mpvsocket
find "$SONG_PATH" -maxdepth 1 -type f | ifShouldShuffle | while read -r file; do
    printf 'loadfile "%s" append-play\n' "$file" | socat - /tmp/mpvsocket
done

echo "" | socat - /tmp/music_socket

