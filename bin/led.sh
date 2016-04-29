#/bin/bash

# read WOPi config file:
if [ -f $WOPI_CONFIG ]; then
  . $WOPI_CONFIG
else
  printf "$(tput setaf 1)ERROR$(tput sgr0): WOPi config \"$WOPI_CONFIG\" was not found!\n"
  exit 1
fi
RC=0

gpio mode $GPIO_LED out

case "$1" in
  on)
    printf "Turning LEDs on..."
    gpio write $GPIO_LED 1
    checkrc $? && printf "%s\n" "$RESULT"
    ;;
  off)
    printf "Turning LEDs off..."
    gpio write $GPIO_LED 0
    checkrc $? && printf "%s\n" "$RESULT"
    ;;
  *)
    echo "Usage: $0 {on|off}"
    RC=1
    ;;

esac

exit $RC
