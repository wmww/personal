#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
INSTALL="$DIR/install"
mkdir -p "$INSTALL"
MATE_PANEL_INC_DIR="$DIR/../mate-panel/install/include/mate-panel-4.0/libmate-panel-applet/"
export CFLAGS="-Wno-deprecated-declarations -I$MATE_PANEL_INC_DIR $CFLAGS"
# export CFLAGS="-Wno-deprecated-declarations -Werror -g -O0 $CFLAGS"
"$DIR/autogen.sh" --enable-x11 --enable-wayland --prefix "$INSTALL" $@
if test ! -f "$MATE_PANEL_INC_DIR/mate-panel-applet.h"; then
    echo
    echo "    WARNING: $MATE_PANEL_INC_DIR/mate-panel-applet.h does not exist, build may be broken!"
    echo
fi
