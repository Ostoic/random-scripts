#!/bin/bash

# Exit on first error
set -e

if [ $# -lt 1 ]; then
        echo "Usage: $0 https://$ARTIST_SITE/"
        exit -1
fi

ARTIST_SITE=$1

extract-album-link() {
        grep -oE '<a href="/album/([a-zA-Z0-9-]+)">' | cut -d'"' -f2 | cut -d '/' -f3
}

make-album-url() {
        echo "$ARTIST_SITE/album/$1"
}

extract-album-title() {
        tr '\n' ' ' | grep -oE '"@type":"MusicAlbum","name":"([^"]+)"' | cut -d ':' -f3 | tr -d '"'
}

for album in $(curl $ARTIST_SITE | extract-album-link); do
        album_url=$(curl $(make-album-url))
        album_name=$(curl $album_url | extract-album-title)
        mkdir $album_name
        pushd $album
        echo mp3-dl --proxy=socks5://localhost:4050 $album_url
        popd
done
