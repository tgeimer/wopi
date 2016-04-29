#!/bin/bash

DATA_PATH=/home/pi/wopi/data/rrd
SENSOR_HAUS=10-000802c32746
SENSOR_NEST=10-000802b5d2a7
TEMPSCRIPT=/home/pi/wopi/bin/temp.sh

function usage {
  echo "Usage: $0 -[d|m|y] -[nest|cpu|haus]"
  echo "Examples:"
  echo "$0 -d -nest"
  echo "	updates daily nest temperature RRD file"
  echo "$0 -m -cpu"
  echo "	updates monthly cpu temperature RRD file"
  echo "$0 -y -haus"
  echo "	updates yearly haus temperature RRD file"
}

if [ $# -ne 2 ]; then
  usage
  exit 1;
fi


case "$1" in
  "-d")
	DATE_PART=$(date +%F)
	RRD_STEPS=300
	STARTSEC=$(date -d "$(date +%F) 00:00:00" +%s)
	MIN_INTERVAL=600
	CF_STEPS=5
	RRD_ROWS=288
	;;
  "-m")
	DATE_PART=$(date +%Y)-$(date +%m)
	RRD_STEPS=3600
	STARTSEC=$(date -d "$(date +%Y)-$(date +%m)-01 00:00:00" +%s)
	MIN_INTERVAL=1440
	CF_STEPS=6
	RRD_ROWS=720
	;;
  "-y")
	DATE_PART=$(date +%Y)
	RRD_STEPS=21600
	STARTSEC=$(date -d "$(date +%Y)-01-01 00:00:00" +%s)
	MIN_INTERVAL=21600
	CF_STEPS=3
	RRD_ROWS=1424
	;;
  *)
	usage
	exit 1;
	;;
esac

case "$2" in
  "-cpu")
	SENSOR_PART="cpu"
	CURVALUE=$($TEMSCRIPT cpu)
	;;
  "-nest")
	SENSOR_PART="nest"
	CURVALUE=$($TEMSCRIPT $SENSOR_NEST)
	;;
  "-haus")
	SENSOR_PART="haus"
	CURVALUE=$($TEMSCRIPT $SENSOR_HAUS)
	;;
  *)
	usage
	exit 1;
	;;
esac

RRDFILE=$DATA_PATH/${SENSOR_PART}/${DATE_PART}.rrd

if [ ! -f $RRDFILE ]; then
  echo $RRDFILE does not exist, creating it...
  /usr/bin/rrdtool create $RRDFILE \
	--step=$RRD_STEPS \
	--start=$STARTSEC \
	DS:temp:GAUGE:$MIN_INTERVAL:-50:100 \
	RRA:AVERAGE:0.5:$CF_STEPS:$RRD_ROWS \
	RRA:MIN:0.5:$CF_STEPS:$RRD_ROWS \
	RRA:MAX:0.5:$CF_STEPS:$RRD_ROWS

  chown pi:pi $RRDFILE
fi

/usr/bin/rrdtool update $RRDFILE $(date +%s):$CURVALUE

exit 0;
