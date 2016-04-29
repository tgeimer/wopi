#!/bin/bash

WOPI_CONFIG=/home/pi/wopi/wopi.conf
if [ -f $WOPI_CONFIG ]; then
  . $WOPI_CONFIG
else
  printf "$(tput setaf 1)ERROR$(tput sgr0): WOPi config \"$WOPI_CONFIG\" was not found!\n"
  exit 1
fi

$WOPI_SCRIPT_LED on
while :
do
    raspivid -n -t 0 \
        -w $USTREAM_WIDTH \
        -h $USTREAM_HEIGHT \
        -fps $USTREAM_FPS \
        -b 500000 -o - \
        | ffmpeg -i - -vcodec copy -an \
        -metadata title="$USTREAM_TITLE" \
        -f flv $USTREAM_URL/$USTREAM_KEY
    sleep 2
done

exit 0
