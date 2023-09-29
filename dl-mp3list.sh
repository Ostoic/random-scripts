#!/bin/bash
#
#
playlist-title() {
  yt-dlp --no-warnings --dump-single-json $1 | jq -r '.title'
}

PLAYLIST="$(playlist-title $1)"

if ! [ -f "./$PLAYLIST" ]; then
  mkdir "$PLAYLIST"
fi

# exit
if [ ! "$PLAYLIST" = $(basename $PWD) ]; then
  cd "$PLAYLIST"
fi

yt-dlp -x --audio-format mp3 --audio-quality 0 --download-archive "$PLAYLIST" $1
