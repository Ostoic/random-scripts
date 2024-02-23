#!/bin/bash

set -e

if [ ! $2 ]; then
  echo "No output specified!"
  exit -1
fi 

INPUT="$1"
OUTPUT="$2"

check_input_exists(){
  if [ ! -d $1 ]; then
    echo "Directory $1 does not exist!"
    exit -1
  fi
  INPUT="$(realpath $INPUT)"
}

check_output_already_exists() {
  if [[ $1 = "" ]]; then
    exit -3 "No output specified!"
  fi

  if [ -f $1 ]; then
    echo "$1 already exists!"
    exit -2
  fi
  OUTPUT="$(realpath $OUTPUT)"
}

check_input_exists $INPUT
check_output_already_exists $OUTPUT

touch $OUTPUT

find "$INPUT" -type f -exec md5sum {} \; | tee $OUTPUT
