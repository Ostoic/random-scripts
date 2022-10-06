#!/bin/bash

if [ $# -lt 2 ]; then
  while read spell_ids; do
		echo "$spell_ids"
	done < "${1:-/dev/stdin}"
else
	spell_ids="$@"
fi

cant-dispell() {
  spell_id=$1
	proxychains -q curl -s -L -A '' https://www.wowhead.com/wotlk/spell\=$spell_id | tr '\n' ' ' | grep -Eo '.*th>Dispel type</th>[\t ]*<td><span class="q0">n/a' >/dev/null	
	return $?
}

filter-nondispell() {
  if cant-dispell $1; then
		echo "$1"
	fi
}

export -f cant-dispell
export -f filter-nondispell
echo $spell_ids | tr ' ' '\n' | xargs -P6 -I% bash -c 'filter-nondispell %'
