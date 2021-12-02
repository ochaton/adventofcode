#!/bin/bash
set -euo pipefail

function part1() {
	local file
	file="$1"

	local c=0
	local p
	while read -r d; do
		if [[ "$p" < "$d" ]]; then
			((c++))
		fi
		p="$d"
	done <"$file"
	echo "$c"
}

function part2() {
	local file=$1
	local len
	len=$(wc -l "$file" | awk '{print $1}')

	for i in $(seq 3 "$len"); do
		sum=$(head -n "$i" "$file" | tail -3 | paste -sd+ - | bc)
		echo "$sum"
	done
}

script="$(
	cd -- "$(dirname "$0")" >/dev/null 2>&1
	pwd -P
)"

part1 "${script}/input.txt"
part2 "${script}/input.txt" | part1 "/dev/stdin"
