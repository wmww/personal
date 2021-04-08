#!/bin/bash
set -eo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
INSTALL="$DIR/install"
mkdir -p "$INSTALL"

if test -z "$CC"; then
    # If the build directory has "clang" in the name default to Clang, if "gcc" then default to GCC
    BUILD_DIR=$(basename $(readlink -f $(pwd)))
    if echo "$BUILD_DIR" | grep -i clang >/dev/null; then
        export CC=clang
        echo "In $BUILD_DIR so using Clang"
    elif echo "$BUILD_DIR" | grep -i gcc >/dev/null; then
        export CC=gcc
        echo "In $BUILD_DIR so using GCC"
    else
        export "Letting CMake choose the compiler"
    fi
else
    echo "CC is already set to $CC"
fi

cmake "$DIR" -DMIR_USE_LD=lld -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX="$INSTALL" $@
