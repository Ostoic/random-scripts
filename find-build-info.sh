#!/bin/bash

if [ $# = 0 ]; then
  #strings | grep -F "/home/$USER/"
  if strings | grep -F "/$USER/"; then
    exit 1
  elif strings | grep -F ".cargo/"; then
    exit 1
  fi

  exit 0
else
  cat $1 | $0
fi
