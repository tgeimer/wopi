#!/bin/bash

if [ -f $WOPIRC ]; then
  . $WOPIRC
else
  printf "${RED}$ERROR${NC}: WOPi environment \"$WOPIRC\" could not be loaded.\n"
  exit 1;
fi

SCREEN_PROCESS=$(ps auxww | grep $USTREAM_PROCESS | grep ustream | awk '{print $2}')

if [ $SCREEN_PROCESS ]; then
  printf "WOPi Stream is already running.\n"
else
  screen -S $USTREAM_PROCESS -dms $USTREAM_PROCESS /home/pi/wopi/bin/ustream.sh
fi

exit 0
