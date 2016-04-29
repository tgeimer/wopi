#!/bin/bash

SENSOR_ID=$1
if [ $1 = "cpu" ]; then
  SENSOR=/sys/class/thermal/thermal_zone0/temp
else
  SENSOR=/sys/bus/w1/devices/$SENSOR_ID/w1_slave
fi

RAW=/home/pi/wopi/data/sensor_${SENSOR_ID}.txt

cat $SENSOR > $RAW

if [ $1 = "cpu" ]; then
  VALID=YES
else
  VALID=$(head -n 1 $RAW | cut -d " " -f 12)
fi

TEMP=1000 # ungueltiger Wert

if [ $VALID = "YES" ]; then
  TEMP=$(tail -n 1 $RAW | cut -d\= -f 2)
  DECTEMP=$(python -c "print round(${TEMP}/1000.0, 2)")
fi
echo $DECTEMP

exit 0;
