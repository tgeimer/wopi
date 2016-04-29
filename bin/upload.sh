#!/bin/bash


FTP_USER=<put_username_here>
FTP_PASS="<put_password_here>"
FTP_SERVER=<put_servername_here>
REMOTE_FILE="/"
VIDEOFLAGFILE=/home/pi/.video


#---------- only change below if you know what you do

# check if $VIDEOFLAGFILE exists;
# if yes: exit because live video seems to be running
if [ -f $VIDEOFLAGFILE ]; then
  echo "not uploading because live video seems to be running..."
  exit 0;
fi

if [ $# -ne 1 ]; then
  echo "Usage: $0 <full-path-to-file>"
  exit 1;
fi

LOCAL_FILE=$1
if [ -f $LOCAL_FILE ]; then
  ncftpput -V -S .tmp -u $FTP_USER -p $FTP_PASS $FTP_SERVER $REMOTE_FILE $LOCAL_FILE
  RC=$?
  if [ $RC -eq 0 ]; then
    echo Upload OK
  else
    echo "Upload not OK ($RC)"
  fi
else 
  echo "File not found"
  exit 2;
fi


exit 0;
