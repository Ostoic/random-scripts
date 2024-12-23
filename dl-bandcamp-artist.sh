﻿#!/bin/bash

# Exit on first error
set -e

if [ $# -lt 1 ]; then
        echo "Usage: $0" 'https://$ARTIST_SITE/'
        exit -1
fi

ARTIST_SITE="$1"


extract-album-link() {
        grep -oE '<a href="/album/([a-zA-Z0-9-]+)">' | cut -d'"' -f2 | cut -d '/' -f3
}

make-album-url() {
        echo "$ARTIST_SITE/album/$1"
}

extract-album-title() {
        tr '\n' ' ' | grep -oE '"@type":"MusicAlbum","name":"([^"]+)"' | cut -d ':' -f3 | tr -d '"'
}

for album in $(curl -sL $ARTIST_SITE | extract-album-link); do
        echo "Download target: $album"
        album_url=$(make-album-url $album)
        echo "Found album url: $album_url"

        album_name=$(curl -sL $album_url | extract-album-title)
        echo "Found album name: $album_name"
        if [ -d "$album_name" ]; then
                echo "Album already exists locally, moving onto next"
                continue
        fi

        mkdir "$album_name"
        pushd "$album_name"
        tmux new-session -d "yt-dlp --audio-quality 0 --audio-format mp3 $album_url" &
        popd
        echo
done

