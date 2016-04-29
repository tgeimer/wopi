#!/bin/bash

FILETYPE=png
CAMFILE=/home/pi/data/cam.png
OUTFILE=/home/pi/data/current.png
WAIT_MS=1000
WIDTH=640
HEIGHT=480
QUALITY=50
POINTSIZE=16
ROTATION=90
STREAMFLAGFILE=/home/pi/wopi/conf/.stream
ARCHIVEFLAGFILE=/home/pi/wopi/conf/.archive
DAYSTR=$(date +%F)
MINSTR=$(date +%H)$(date +%M)
ARCHIVEDIR=/home/pi/data/archive
ARCHIVEIMAGE=${DAYSTR}_$MINSTR.png

# -----------------------------------------

# check if $exists; 
# if yes: exit because live video seems to be running
STREAMING_FLAG=$(cat $STREAMFLAGFILE)
if [ $STREAMING_FLAG -eq 1 ]; then
  echo "not running because live video seems to be running..."
  exit 0;
fi

# check if $ARCHIVEFLAGFILE contains 1; 
# if yes: copy current image to archive
ARCHIVEFLAG=$(cat $ARCHIVEFLAGFILE)
if [ $ARCHIVEFLAGFILE -eq 1 ]; then
  ARCHIVE=$ARCHIVEDIR/${DAYSTR}
  if [ -d $ARCHIVE ]; then
    echo \a
  else
    mkdir $ARCHIVE
  fi
  cp $OUTFILE $ARCHIVE/$ARCHIVEIMAGE
fi

/home/pi/bin/ir-led.sh on

echo "taking picture..."
sudo raspistill -t $WAIT_MS -e $FILETYPE -o $CAMFILE -w $WIDTH -h $HEIGHT -q $QUALITY

/home/pi/bin/ir-led.sh off

echo "rotating image..."
sudo convert $CAMFILE -rotate "${ROTATION}>" "${OUTFILE}"
echo "inserting date in image..."
sudo convert $OUTFILE -pointsize $POINTSIZE -fill white -undercolor '#00000050' -gravity NorthEast -annotate +$POINTSIZE+$POINTSIZE "$(date +%F\\n%H:%M)" "${OUTFILE}"


echo "done!"

exit 0
