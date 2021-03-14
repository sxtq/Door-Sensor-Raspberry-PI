#!/bin/bash

dir=/home/user/lock.sh
port=35432

while test "$#" -gt 0; do
  case "$1" in
    -s|--socat)
      shift
        export socatr="1"
      shift
      ;;
    *)
      break
      ;;
  esac
done

if [ "$socatr" = "1" ]; then
  clear
  echo "Starting socat"
  socatr=0
  socat -u tcp-l:"$port",fork system:"$dir"
else
  echo "Locking the screen"
  xdg-screensaver lock
fi
