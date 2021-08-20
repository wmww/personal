#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
INSTALL="$DIR/install"
mkdir -p "$INSTALL"
export CFLAGS="-Wno-deprecated-declarations -g -O0 $CFLAGS"
"$DIR/autogen.sh" --with-in-process-applets=all --prefix "$INSTALL" $@
