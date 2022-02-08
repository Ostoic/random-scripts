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

# Remove identifying Nmap 404 checks
sed -i 's/nmaplowercheck/appindex/g' http.lua 2>/dev/null
sed -i 's/NmapUpperCheck/AppIndex/g' http.lua 2>/dev/null
sed -i 's/Nmap\/folder\/check/app\/index/g' http.lua 2>/dev/null
sed -i "s|USER_AGENT[ \t]*=[ \t]*stdnse.get_script_args.*useragent.*|local uas = io.open('$NMAP_NSELIB/$UA_FILE', 'r'):read('*a')\nlocal _, n = uas:gsub('\\\\n', '')\nlocal r = math.random(1, n)\nlocal i = 1\n\nfor agent in uas:gmatch('[^\\\\n]+') do\n  if i == r then\n    USER_AGENT = agent; break\n  end\n  i = i + 1\nend|g" http.lua
