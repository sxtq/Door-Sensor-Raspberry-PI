# Door sensor computer locking script with notifcations
script to send notifcation using pushover api when door is opened running on pi also locks a local computer

So the computer thats going to be locked will lisen on the port we are using for a one time password generated
with oathtool if the door sensors otp matches the computers otp password then the computer is locked. this is done so that someone cant just lock your
computer by sending tcp data over the port.

Computer to be locked will run lock.sh
door sensor server (Pi) will run door.sh
you should install tmux on both computers and setup a crontab to run the scripts on boot in tmux

to start lising on the port for the lock otp run

```
$ ./lock -s
```

make sure the keys match in both door.sh and lock.sh
make sure the ip and port in door.sh is correct
make sure the port inside lock.sh matches the one in door.sh
make sure you set the right paths also

this is just a test i was doing messing around with gpio pins i dont know how reliable this is its more for messing around with a pi
