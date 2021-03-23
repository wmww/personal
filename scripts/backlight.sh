#!/bin/bash
set -euo pipefail

base="/sys/class/backlight"
vendor="intel"
path="$base/$vendor""_backlight"

if [ ! -d $path ]; then
	echo "$path does not exist, please adjust vendor"
fi

current=$(cat $path/actual_brightness)
max=$(cat $path/max_brightness)
min=0

if [ "$#" -eq 0 ]; then
	echo "$(($current*100/$max))% ($current/$max)"
	exit 0
elif [ "$#" -ne 1 ]; then
	echo "Too many arguments"
	exit 1
fi

new=$(($1*$max/100))

if (( $new > $max )); then
    new=$max
fi

if (( $new < $min )); then
    new=$min
fi

sudo tee /sys/class/backlight/intel_backlight/brightness <<< $new > /dev/null

echo "-> $(($new*100/$max))% ($new/$max)"

