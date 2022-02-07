#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 /usr/share/seclists/Fuzzing/User-Agents/user-agents-whatismybrowserdotcom-small.txt"
  exit -1
fi

if [ $(id -u) -ne 0 ]; then
  echo 'Error: Must run as root!'
  exit -2
fi

if [ ! -f $1 ]; then
  echo "Error: $1 is not a valid user-agents file"
  exit -3
fi

NMAP_NSELIB="/usr/share/nmap/nselib"

if [ ! -d $NSELIB ]; then
  echo 'Error: Nmap not installed!'
  exit -4
fi
  
UA_FILE="user-agents.txt"

cp $1 "$NMAP_NSELIB/$UA_FILE"
cd $NMAP_NSELIB

# Copy user agents to nselib
chmod ugo+r $UA_FILE

# Copy rua.lua into the nselib folder
echo -n X0VOViA9IHN0ZG5zZS5tb2R1bGUoInJ1YSIsIHN0ZG5zZS5zZWVhbGwpCgpmdW5jdGlvbiBjaG9vc2VfcmFuZG9tKCkKICBsb2NhbCB1YXMgPSBpby5vcGVuKCcvdXNyL3NoYXJlL25tYXAvbnNlbGliL3VzZXItYWdlbnRzLnR4dCcsICdyJyk6cmVhZCgnKmEnKQogIGxvY2FsIF8sIG4gPSB1YXM6Z3N1YignXG4nLCAnJykKICBsb2NhbCByID0gbWF0aC5yYW5kb20oMSwgbikKICBsb2NhbCBpID0gMQogIGZvciBhZ2VudCBpbiB1YXM6Z21hdGNoKCdbXlxuXSsnKSBkbwogICAgaWYgaSA9PSByIHRoZW4KICAgICAgcmV0dXJuIGFnZW50CiAgICBlbmQKICBlbmQKICAKICBpID0gaSArIDEKZW5kCgpyZXR1cm4gX0VOVjsK | base64 -d > rua.lua

# Remove identifying Nmap 404 checks
sed -i 's/nmaplowercheck/appindex/g' http.lua 2>/dev/null
sed -i 's/NmapUpperCheck/AppIndex/g' http.lua 2>/dev/null
sed -i 's/Nmap\/folder\/check/app\/index/g' http.lua 2>/dev/null
sed -i "s/USER_AGENT[ \t]*=[ \t]*stdnse.get_script_args.*useragent.*/local rua = require('rua')\nUSER_AGENT = rua.choose_random()\n/g" http.lua
