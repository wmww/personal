#!/bin/bash
set -euo pipefail

DISTRO=$(lsb_release -a | grep -Po '(?<=Distributor ID:\t).*$')
if [ -z $DISTRO ]; then
    echo "Could not detect distro"
    exit 1
fi
case "$DISTRO" in
"Arch")
    # Can be done manually with ln -sf /usr/share/zoneinfo/Zone/SubZone /etc/localtime
    sudo tzselect
    ;;
"Ubuntu")
    sudo dpkg-reconfigure tzdata
    ;;
*)
    echo "Script does not yet support $DISTRO"
    exit 1
    ;;
esac
