#!/bin/bash

echo "Sleepting for 2 minutes before starting socat"
sleep 2m
echo "Starting socat"
socat -u tcp-l:35432,fork system:/home/user/working/resp.sh
