#!/bin/bash

dir=/home/user/lock.sh
port=35432
key="your otp key here"

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
  read otp
  otplocal=$(oathtool --base32 --totp "$key")
  if [ "$otp" = "$otplocal" ]; then
    date=$(date)
    echo "OTP match locking the screen date: $date"
    xdg-screensaver lock
    echo "local otp: $otplocal sent otp: $otp"
  else
    date=$(date)
    echo "OTP does not match not locking date: $date"
    echo "local otp: $otplocal sent otp: $otp"
  fi
fi
