#!/bin/bash

WOPI_DIR=/home/pi/wopi
WOPI_STREAM=$WOPI_DIR/conf/.stream
IR_LED=$WOPI_DIR/bin/ir-led.sh
MJPEG_STREAM_DIR=/usr/src/mjpg-streamer/mjpg-streamer-experimental
MJPEG_STREAM=$MJPEG_STREAM_DIR/mjpg_streamer
WIDTH=800
HEIGHT=600
FPS=20
RC=0
FINAL_RC=0
RESULT="[OK]"

# function to check the return code of a command:
checkrc()
{
  if [ $# -eq 1 ]; then
    RC=$1
    if [ $RC -eq 0 ]; then
      RESULT="[OK]";
    else
      RESULT="[ERROR]"; 
      FINAL_RC=$(expr $FINAL_RC + 1)
    fi
  fi
}

start()
{
  printf "Configuring WOPi..."
  echo 1 > $WOPI_STREAM
  checkrc $? && printf "%s\n" "$RESULT"
  $IR_LED on
  checkrc
  printf "Starting mjpg-streamer..."
  $MJPEG_STREAM -o "$MJPEG_STREAM_DIR/output_http.so -w $MJPEG_STREAM_DIR/www" -i "$MJPEG_STREAM_DIR/input_raspicam.so -x $WIDTH -y $HEIGHT -fps $FPS" >/dev/null 2>&1 &
  checkrc $? && printf "%s\n" "$RESULT"
}

stop()
{
  printf "Configuring WOPi..."
  echo 0 > $WOPI_STREAM
  checkrc $? && printf "%s\n" "$RESULT"
  $IR_LED off
  checkrc
  printf "Stopping mjpg-streamer..."
  kill -9 $(pidof mjpg_streamer) >/dev/null 2>&1
  checkrc $? && printf "%s\n" "$RESULT"
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    start
    ;;
  *)
    echo "Usage: $0 {start|stop|restart}"
    FINAL_RC=1
    ;;
esac

exit $FINAL_RC
