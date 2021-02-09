#!/bin/bash

log_path="/tmp/error.txt"
n="
"

result=$($@ 2>&1)
if test $? -ne 0; then
    message="$@ failed:$n$result"
    echo "$result" > "$log_path"
    notify-send "$log_path" "$message"
fi
