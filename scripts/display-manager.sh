#!/bin/bash
set -euo pipefail

print_disp_man() {
    SERVICE_PATH="/etc/systemd/system/display-manager.service"
    if test -e "$SERVICE_PATH"; then
        DISP_MAN=$(grep -Po '(?<=^ExecStart=).*$' "$SERVICE_PATH")
        if echo "$DISP_MAN" | grep "gdm3" &>/dev/null; then
            DISP_MAN="gdm"
        fi
    else
        DISP_MAN="off"
    fi
    echo "$DISP_MAN"
}

print_info() {
    echo "current display manager: $(print_disp_man)"
}

assert_root() {
    if test $(id -u) -ne 0; then
        echo "Command needs to be run as root"
        exit 1
    fi
}

disable() {
    assert_root
    echo "Disabling current display manager..."
    DISP_MAN="$(print_disp_man)"
    case "$DISP_MAN" in
    "gdm")
        echo "Disabling GDM..."
        sudo systemctl disable gdm
        sudo systemctl stop gdm
        ;;
    "off")
        echo "(no display manager to disable)"
        ;;
    *)
        echo "Can not disable unknown display manager $DISP_MAN"
        return 1
        ;;
    esac
}

if test $# -eq 0; then
    print_info
    exit 0
fi

if test $# -ne 1; then
    echo "Should only have 0 or 1 args (try -h)"
    exit 1
fi

case $1 in
"show")
    print_info
    ;;
"gdm")
    assert_root
    disable
    echo "Enabling GDM..."
    dpkg-reconfigure gdm3
    print_info
    ;;
"off")
    assert_root
    disable
    print_info
    ;;
"-h" | "--help" | "help")
    echo "Get and set info about the current display manager"
    echo "COMMANDS:"
    echo "  show: show the current display manager"
    echo "  gdm: enable GDM3"
    echo "  off: disable the display manager"
    echo "  help, --help, -h: show this message"
    ;;
*)
    echo "Unknown command $1"
    exit 1
    ;;
esac
