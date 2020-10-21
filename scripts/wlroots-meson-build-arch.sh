#!/bin/bash
set -euo pipefail

# Prefix should be /usr/local/ on Ubuntu and /usr/ on Arch
# Don't ask me why it's not my job to know these things
# ...
# Ok, so it is literally my job to know these things, but...
# EDIT: now it looks like /usr/ is correct for Ubuntu as well?? idk. Leaving the logic here in case I need it again
DISTRO=$(lsb_release -a | grep -Po '(?<=Distributor ID:\t).*$')
if [ $DISTRO == 'Arch' ]; then
    PREFIX=/usr/
elif [ $DISTRO == 'Ubuntu' ]; then
    PREFIX=/usr/
else
    echo "Unknown distro $DISTRO" 1>&2
    exit 1
fi

meson build \
    --prefix $PREFIX \
    --buildtype release \
    --warnlevel 0 \
    -Dlibcap=enabled \
    -Dlogind=enabled \
    -Dlogind-provider=systemd \
    -Dxwayland=enabled \
    -Dx11-backend=enabled \
    -Dexamples=true
    #-Dxcb-errors=enabled

