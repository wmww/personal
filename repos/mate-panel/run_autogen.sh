#!/bin/bash
set -e
export CFLAGS="-Wno-deprecated-declarations -Werror -g -O0 $CFLAGS"
./autogen.sh --with-in-process-applets=all --prefix ~/code/install/usr/local/ $@
