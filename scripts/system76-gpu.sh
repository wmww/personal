#!/bin/bash
set -euo pipefail

function print_state {
    # system76-power graphics also does the job
    if [ $(lspci | grep -i vga | grep -i nvidia) ]; then
        echo "NVIDIA on"
    else
        echo "NVIDIA off"
    fi
}

if ! system76-power graphics >/dev/null; then
    echo "system76-power graphics failed, perhaps system76-power.service isn't running?"
    exit 1
fi

if [ $# -eq 0 ]; then
    print_state
    exit
fi

case $1 in
"on")
    print_state
    echo "Turning on..."
    sudo system76-power graphics power on
    sudo modprobe nvidia-drm nvidia-modeset nvidia
    print_state
    ;;
"off")
    print_state
    echo "Turning off..."
    sudo rmmod nvidia-drm nvidia-modeset nvidia
    sudo system76-power graphics power off
    print_state
    ;;
"-h" | "--help" | "help")
    echo "Query or change state of NVIDIA GPU on a System76 machine"
    echo "Use commands 'on', 'off', or no command to query"
    echo "Adapted from https://ebobby.org/2018/07/15/archlinux-on-oryp4/"
    ;;
*)
    echo "Unknown command $1"
    ;;
esac
