#!/bin/bash

RRD_DIR=/home/pi/wopi/data/rrd
HEIGHT=200
WIDTH=559
BGCOLOR="000000"
CANVASCOLOR="000000"


function usage {
  echo "Usage: $0 -[d|m|y] -[nest|cpu|haus]"
  echo "Examples:"
  echo "$0 -d -nest"
  echo "        creates graph of daily nest temperature"
  echo "$0 -m -cpu"
  echo "        creates graph of monthly cpu temperature"
  echo "$0 -y -haus"
  echo "        creates graph of yearly haus temperature"
}


if [ $# -ne 2 ]; then
	usage
	exit 1;
fi

case "$1" in
  "-d")
	DATE_PART=$(date +%F)
	FILENAME=temp_d.png
	STARTSEC=$(date -d "$(date +%F\ 00:00:00)" +%s)
	ENDSEC=$(date -d "$(date +%F\ 23:59:59)" +%s)
        ;;
  "-m")
	DATE_PART=$(date +%Y)-$(date +%m)
	FILENAME=temp_m.png
	STARTSEC=$(date -d "$(date +%Y-%m-01\ 00:00:00)" +%s)
	ENDSEC=$(date -d "$(date +%Y-%m-31\ 23:59:59)" +%s)
        ;;
  "-y")
	DATE_PART=$(date +%Y)
	FILENAME=temp_y.png
	STARTSEC=$(date -d "$(date +%Y-01-01\ 00:00:00)" +%s)
	ENDSEC=$(date -d "$(date +%Y-12-31\ 23:59:59)" +%s)
        ;;
  *)
        usage
        exit 1;
        ;;
esac

case "$2" in
  "-cpu")
	FILENAME=cpu_$FILENAME
	DATA_PATH=$RRD_DIR/cpu
	UPPER_LIMIT=85
	LOWER_LIMIT=0
	GRAPHNAME="CPU-Temperatur"
        ;;
  "-nest")
	FILENAME=nest_$FILENAME
	DATA_PATH=$RRD_DIR/nest
	UPPER_LIMIT=30
	LOWER_LIMIT=-10
	GRAPHNAME="Nest-Temperatur"
        ;;
  "-haus")
	FILENAME=haus_$FILENAME
	DATA_PATH=$RRD_DIR/haus
	UPPER_LIMIT=60
	LOWER_LIMIT=-10
	GRAPHNAME="Gartenhaus-Temperatur"
        ;;
  *)
        usage
        exit 1;
        ;;
esac

RRDFILE=$DATA_PATH/${DATE_PART}.rrd

rrdtool graph $DATA_PATH/$FILENAME \
	-w $WIDTH -h $HEIGHT \
	--start $STARTSEC \
	--end $ENDSEC \
	--lower-limit=$LOWER_LIMIT \
	--upper-limit=$UPPER_LIMIT \
	--slope-mode \
	--rigid \
	--watermark "(c) Thomas Geimer $(date +%Y)" \
	DEF:timespan=$RRDFILE:temp:AVERAGE \
	VDEF:min=timespan,MINIMUM \
	VDEF:max=timespan,MAXIMUM \
	AREA:timespan#77777770:$GRAPHNAME \
	LINE1:timespan#444 \
	LINE1:0#00000070 \
	'GPRINT:timespan:LAST:aktuell\: %3.2lf°C \n' \
	'VRULE:max#FF000070:Maximum' \
	'GPRINT:max:%3.2lf°C '\
	'GPRINT:max:erreicht um %H\:%M Uhr\n:strftime' \
	'VRULE:min#0000FF70:Minimum' \
	'GPRINT:min:%3.2lf°C ' \
	'GPRINT:min:erreicht um %H\:%M Uhr\n:strftime'

