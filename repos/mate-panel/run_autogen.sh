#!/bin/bash

# Set the script to abort on error
set -e

# Create an "install" directory next to where the script is that the panel will be installed into
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
INSTALL="$DIR/install"
mkdir -p "$INSTALL"

# Run autogen.sh with the following options:
# - -Wno-deprecated-declarations: this supresses a bunch of useless warnings
# - -g -O0: make debugging easy
# - --with-in-process-applets=all: out-of-process applets don't work on Wayland
# - --prefix "$INSTALL": `make install` should install to the directory we made above
# - $@: forward any additional arguments passed to this script
export CFLAGS="-Wno-deprecated-declarations -g -O0 $CFLAGS"
"$DIR/autogen.sh" --with-in-process-applets=all --prefix "$INSTALL" $@
