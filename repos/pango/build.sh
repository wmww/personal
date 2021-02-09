#!/bin/bash
set -eo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$DIR/env.sh"

if test ! -d "$DIR/build"; then
    (
        cd $DIR
        meson build --prefix "$PANGO_INSTALL/usr/local"
    )
fi
ninja -C "$DIR/build"
ninja -C "$DIR/build" install
