#!/bin/bash
set -euo pipefail

script="$(
	cd -- "$(dirname "$0")" >/dev/null 2>&1
	pwd -P
)"

function part1() {
	local input
	input="$1"

	local x
	local y

	x=0
	y=0

	while read -r cmd n; do
		case "${cmd}" in
		up)
			((y -= n))
			;;
		down)
			((y += n))
			;;
		forward)
			((x += n))
			;;
		esac
	done <"$input"

	echo "x:$x y:$y mul:$((x * y))"
}

function part2() {
	local input
	input="$1"

	local x
	local y
	local aim

	h=0
	d=0
	aim=0

	while read -r cmd n; do
		case "${cmd}" in
		up)
			((aim -= n))
			;;
		down)
			((aim += n))
			;;
		forward)
			((h += n))
			((d += aim * n))
			;;
		esac

		# echo "{$h;$d;$aim}"
	done <"$input"

	echo "h:$h d:$d mul:$((h * d))"

}

part1 "${script}/test.txt"
part1 "${script}/input.txt"
part2 "${script}/test.txt"
part2 "${script}/input.txt"
