#!/bin/bash

random-mac-group() {
  head -c 1 /dev/urandom | xxd -p
}

random-hp-mac() {
  group1=$(random-mac-group)
  group2=$(random-mac-group)
  group3=$(random-mac-group)
  echo "d1:e5:60":"$group1:$group2:$group3"
}

IFACE=$1

echo macchanger -m $(random-hp-mac) $IFACE
