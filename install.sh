#!/bin/bash

############################################################################
# File:         install.sh
# Author:       Thomas Geimer
# Version:      0.9.1 (2016-04-30)
# Purpose:      This script will configure a newly-imaged Raspberry Pi running
#               Raspbian Wheezy (tested version 2015-02-16) with the software
#               necessary to turn it into a WOPi :-)
#
# Prerequisites:
# This script assumes, that you have executed "raspi-config" and configured the following basics:
# 1. expanded filesystem
# 2. enabled ssh
# 3. enabled camera
# 4. set locale, keyboard layout, etc
# 6. you have executed "sudo rpi-update"
# 7. you have executed "sudo apt-get update && sudo apt-get upgrade -y"
#    to have your Raspberry Pi up to date and use the current repositories
#
############################################################################

# load WOPi environment:
HOME_DIR=/home/pi
WOPI_DIR=$(dirname $(readlink -f "$0"))
WOPIRC=$WOPI_DIR/conf/.wopirc
# Variable definitions:
REBOOT_NECESSARY=0
# Colors:
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 6)
NC=$(tput sgr0) # reset color

if [ -f $WOPIRC ]; then
  . $WOPIRC
else
  printf "$REDERROR$NC: WOPi environment \"$WOPIRC\" could not be loaded.\n"
  exit 1;
fi

on_die() {
  echo "Interrupting..."
  echo "Interrupting" >> $WOPI_LOG_INSTALL
  exit 1
}
trap 'on_die' TERM
trap 'on_die' KILL
trap 'on_die' INT

# Script must be run as root (or as user pi with "sudo")
if [ $(whoami) != "root" ]; then
  printf "${RED}ERROR${NC}: This script must be run with root privileges. Try\nsudo %s\n" $0
  exit 1;
fi

# function to add directories to /etc/fstab as RAMdisks:
ramdisk_dir()
{
  printf "%s\tconfiguring ramdisk %s..." $(date +%H:%M:%S) $1
  printf "%s\tconfiguring ramdisk %s..." $(date +%H:%M:%S) $1 >> $WOPI_LOG_INSTALL
  if [ -d $1 ]; then
    if [ $(grep "$1" /etc/fstab | wc -l) -ne 1 ]; then
      printf "\nnone\t%s\ttmpfs\tsize=%s,noatime\t0\t0\n" $1 $2 >> /etc/fstab
      checkrc $? && printf "%s\n" "$RESULT" >> $WOPI_LOG_INSTALL
      printf "%s\n" "$RESULT"
      REBOOT_NECESSARY=1
    else
      printf "[already configured]\n" >> $WOPI_LOG_INSTALL
      printf "[${BLUE}already configured${NC}]\n"
    fi
  else
    printf "[not found]\n" $1 >> $WOPI_LOG_INSTALL
    printf "[${RED}not found${NC}]\n"
        FINAL_RC=$(expr $FINAL_RC + 1)
  fi
}

# convenience function to install precompiled packages:
packet_install(){
  PACKETNAME=$1
  printf "%s\tinstalling %s..." $(date +%H:%M:%S) $PACKETNAME
  printf "%s\tinstalling %s..." $(date +%H:%M:%S) $PACKETNAME >> $WOPI_LOG_INSTALL
  if [ $(dpkg -l | grep -F " $PACKETNAME " | wc -l) -gt 0 ]; then
    printf "[already installed]\n" >> $WOPI_LOG_INSTALL
    printf "[${BLUE}already configured${NC}]\n"
  else
    apt-get install -y $PACKETNAME
    checkrc $? && printf "%s\n" "$RESULT" >> $WOPI_LOG_INSTALL
    printf "%s\n" "$RESULT"
  fi
}

# ======================= INSTALLATION =========================

# make scripts in /bin directory executable:
chmod a+x $WOPI_BIN_DIR/*

# ------------ create RAM-disk for some directories:
ramdisk_dir $WOPI_LOG_DIR 20M
ramdisk_dir /var/log 20M

printf "%s\tStarting WOPi installation\n\n" $(date +%H:%M:%S) > $WOPI_LOG_INSTALL

# ============== Editing of configuration Text files ======
# -------------- Temperature Sensor prerequisites ---------
# adjust dtoverlay to use GPIO 4 for the DS1820 1Wire sensors
printf "%s\tdtoverlay for 1Wire sensors..." $(date +%H:%M:%S)
printf "%s\tdtoverlay for 1Wire sensors..." $(date +%H:%M:%S) >> $WOPI_LOG_INSTALL
if [ $(grep "^dtoverlay=w1-gpio,gpiopin" /boot/config.txt | wc -l) -ne 1 ]; then
  printf "\n#WOPi device tree config for temperature sensor connection to GPIO 4\ndtoverlay=w1-gpio,gpiopin=4\n" >> /boot/config.txt
  checkrc $? && printf "%s\n" "$RESULT" >> $WOPI_LOG_INSTALL
  printf "%s\n" "$RESULT"
  REBOOT_NECESSARY=1
else
  printf "[already configured]\n" >> $WOPI_LOG_INSTALL
  printf "[${BLUE}already configured${NC}]\n"
fi

# disable the red LED on the Pi's camera:
# TODO: check first if a value of 0 is already set
printf "%s\tdisabling red camera LED..." $(date +%H:%M:%S)
printf "%s\tdisabling red camera LED..." $(date +%H:%M:%S) >> $WOPI_LOG_INSTALL
if [ $(grep "^disable_camera_led=1" /boot/config.txt | wc -l) -ne 1 ]; then
  printf "\n#disable the red LED on the Pi's camera:\ndisable_camera_led=1" >> /boot/config.txt
  checkrc $? && printf "%s\n" "$RESULT" >> $WOPI_LOG_INSTALL
  printf "%s\n" "$RESULT"
  REBOOT_NECESSARY=1
else
  printf "[${BLUE}already configured${NC}]\n"
  printf "[already configured]\n" >> $WOPI_LOG_INSTALL
fi

# Make sure that the kernel modules are automatically loaded after next reboot:
printf "%s\tadding 1wire kernel modules ..." $(date +%H:%M:%S)
printf "%s\tadding 1wire kernel modules ..." $(date +%H:%M:%S) >> $WOPI_LOG_INSTALL
if [ $( grep -E '^w1_therm|^w1_gpio|^wire' /etc/modules | wc -l) -ne 3 ]; then
  printf "\nwire\nw1_gpio\nw1_therm\n" >> /etc/modules
  checkrc $? && printf "%s\n" "$RESULT" >> $WOPI_LOG_INSTALL
  printf "%s\n" "$RESULT"
  REBOOT_NECESSARY=1
else
  printf "[already configured]\n" >> $WOPI_LOG_INSTALL
  printf "[${BLUE}already configured${NC}]\n"
fi

# -------------- install WOPi environment ------------------
printf "%s\tinstalling WOPi environment..." $(date +%H:%M:%S)
printf "%s\tinstalling WOPi environment..." $(date +%H:%M:%S) >> $WOPI_LOG_INSTALL
if [ $(grep "WOPIRC" $HOME_DIR/.profile | wc -l) -ne 3 ]; then
  printf "\n\nWOPIRC=$WOPIRC\nif [ -f \$WOPIRC ]; then\n    . \$WOPIRC\nfi\n" >> $HOME_DIR/.profile
  checkrc $? && printf "%s\n" "$RESULT" >> $WOPI_LOG_INSTALL
  printf "%s\n" "$RESULT"
else
  printf "[already configured]\n" >> $WOPI_LOG_INSTALL
  printf "[${BLUE}already configured${NC}]\n"
fi

# -------------- run Reboot-Button script at startup -------------
# TODO: make this optional!
printf "%s\tconfiguring Reboot Button..." $(date +%H:%M:%S)
printf "%s\tconfiguring Reboot Button..." $(date +%H:%M:%S) >> $WOPI_LOG_INSTALL
if [ 0 -eq 1 ]; then
#if [ $(grep "button.py" /etc/rc.local | wc -l) -ne 1 ]; then
  printf "\nsudo $WOPI_SCRIPT_BUTTON &\n" >> /etc/rc.local
  checkrc $? && printf "%s\n" "$RESULT" >> $WOPI_LOG_INSTALL
  printf "%s\n" "$RESULT"
else
  printf "[already configured]\n" >> $WOPI_LOG_INSTALL
  printf "[${BLUE}already configured${NC}]\n"
fi

# =========== SOFTWARE INSTALLATION: =============
# ----------------- WiringPi Library -------------
# install WiringPi library by @Drogon.
# This is needed to control the GPIO pins via shell and python scripts:
printf "%s\tInstalling WiringPi..." $(date +%H:%M:%S)
printf "%s\tInstalling WiringPi..." $(date +%H:%M:%S) >> $WOPI_LOG_INSTALL
if [ $(which gpio) ]; then
  printf "[already installed]\n" >> $WOPI_LOG_INSTALL
  printf "[${BLUE}already installed${NC}]\n"
else
  cd $HOME_DIR
  git clone git://git.drogon.net/wiringPi
  cd $HOME_DIR/wiringPi
  ./build
  if [ $(which gpio) ]; then
    printf "[OK]\n" >> $WOPI_LOG_INSTALL
    printf "[${BLUE}already installed${NC}]\n"
  fi
fi


# -------------- RRDTOOL for pretty temperature graphs ------------
#packet_install rrdtool

# -------------- install imagemagick to enhance images ------------
#packet_install imagemagick

# -------------- install NCFTP to upload images -------------------
#packet_install ncftp

# -------------- install screen for letting ustream.sh run in background
packet_install screen

# --------------- install FFMPEG (takes about 5 hours on a B+ !) -------------
printf "%s\tinstalling ffmpeg..." $(date +%H:%M:%S)
printf "%s\tinstalling ffmpeg..." $(date +%H:%M:%S) >> $WOPI_LOG_INSTALL
if [ $(which ffmpeg) ]; then
  printf "[already installed]\n" >> $WOPI_LOG_INSTALL
  printf "[${BLUE}already installed${NC}]\n"
else
  FFMPEG_DIR=/usr/src/ffmpeg
  mkdir $FFMPEG_DIR
  chown pi:users $FFMPEG_DIR
  git clone git://source.ffmpeg.org/ffmpeg.git $FFMPEG_DIR
  cd $FFMPEG_DIR
  ./configure
  make && make install
  checkrc $? && printf "%s\n" "$RESULT" >> $WOPI_LOG_INSTALL
  printf "%s\n" "$RESULT"
fi

if [ $REBOOT_NECESSARY -eq 1 ]; then
  printf "\n${BLUE}Please reboot the pi for the changes to be activated.${NC}"] >> $WOPI_LOG_INSTALL
fi

printf "\n%s\tWOPi installation finished with %s errors\n\n" $(date +%H:%M:%S) $FINAL_RC >> $WOPI_LOG_INSTALL
printf "\n%s\tWOPi installation finished with %s errors\n\n" $(date +%H:%M:%S) $FINAL_RC

exit $FINAL_RC
