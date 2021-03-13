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
dir=/root

timer () {
  timerloop=1
  h=0
  m=0
  s=0
  d=0
  while [ "$timerloop" = '1' ] ; do
    ((s=s+1))
    sleep 1
    if [ "$s" = '60' ] ; then
      ((m=m+1))
      s=0
    fi
    if [ "$m" = '60' ] ; then
      ((h=h+1))
      m=0
    fi
    if [ "$h" = '24' ] ; then
      ((d=d+1))
      h=0
    fi
    echo "$d/$h/$m/$s" > "$dir"/doortimer.log
  done &
}

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
      echo "Lock" | netcat "$ip" "$port"
      timer
      norun=1
    fi
    echo "Door is closed"
    send "Security System" "Door is open date: "
    new_output="1"
  else
    if [ "$norun" = "1" ]; then
      timeopen=$(cat "$dir/doortimer.log")
      rm "$dir/doortimer.log"
      timerloop=0
    fi
    send "Security System" "Door is closed time open: $timeopen date: "
    echo "Door is closed"
    new_output="2"
    norun=0
  fi
  sleep .2
  clear
done
