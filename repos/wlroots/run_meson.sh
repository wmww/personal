#!/bin/bash
set -eo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
INSTALL="$DIR/install"
mkdir -p "$INSTALL"

if test $PWD != $DIR; then
    echo "You need to be in the wlroots directory $DIR"
    exit 1
fi

meson --prefix "$INSTALL" build

