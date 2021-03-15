#!/bin/bash

lock=1
APP_TOKEN="null"
USER_TOKEN="null"
URL="https://api.pushover.net/1/messages.json"
GPIO=15
first_run=1
log_file=/root/door.log
ip=
port=

key="your otp key here"

send () {
  if [ "$new_output" = "$old_output" ]; then
    echo "Already sent nothing to do"
  else
    if [ "$first_run" = "0" ]; then
      date=$(date)
      wget "$URL" --post-data="token=$APP_TOKEN&user=$USER_TOKEN&message=$2$date&title=$1&sound=pushover" -qO- > /dev/null 2>&1 &
      echo "$2$date" >> "$log_file"
      echo "Notifcation has been sent"
    else
      echo "First run not sending"
      first_run=0
      sleep 2
    fi
  fi
  old_output="$new_output"
}

if [ ! -d /sys/class/gpio/gpio${GPIO} ]; then
  echo "${GPIO}" > /sys/class/gpio/export
fi
echo "in" > /sys/class/gpio/gpio"${GPIO}"/direction

while true; do
  if [ "1" = "$(</sys/class/gpio/gpio"${GPIO}"/value)" ]; then
    if [ "$lock" = "1" ] && [ "$norun" = "0" ]; then
      otp=$(oathtool --base32 --totp "$key")
      echo "$otp" | netcat "$ip" "$port"
      norun=1
      SECONDS=0
      rerun=1
    fi
    echo "Door is closed"
    send "Security System" "Door is open date: "
    new_output="1"
    if [ "$rerun" = "1" ]; then #Second lock just incase first one failed
      sleep 2
      otp=$(oathtool --base32 --totp "$key")
      echo "$otp" | netcat "$ip" "$port"
      rerun=0
    fi
  else
    if [ "$norun" = "1" ]; then
      duration=$SECONDS
      time="$(($duration / 3600))/$(($duration / 60))/$(($duration % 60))"
    fi
    send "Security System" "Door is closed time open was: $time date: "
    echo "Door is closed"
    new_output="2"
    norun=0
  fi
  sleep .2
  clear
done
