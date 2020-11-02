#!/bin/bash
set -eo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$DIR/env.sh"

if test -f "$DIR/meson.build"; then
    if test ! -d "$DIR/build-meson"; then
        (
            cd $DIR
            meson build-meson
        )
    fi
    ninja -C "$DIR/build-meson"
    ninja -C "$DIR/build-meson" install
else
    cd $DIR
    if test ! -f "Makefile"; then
        ./autogen.sh --prefix "$DESTDIR/usr/local"
    fi
    make
    make install
fi
