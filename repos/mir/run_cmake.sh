#!/bin/bash
set -eo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
INSTALL="$DIR/install"
mkdir -p "$INSTALL"

if test $(dirname $PWD) != $DIR; then
    echo "You are not in a subdir of $DIR, this is probably a mistake"
    exit 1
fi

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
        echo "Letting CMake choose the compiler"
    fi
else
    echo "CC is already set to $CC"
fi

# Generate compile_commands.json for Sourcetrail
export CMAKE_EXPORT_COMPILE_COMMANDS=1

cmake "$DIR" -DMIR_USE_LD=lld -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX="$INSTALL" -DCMAKE_INSTALL_RPATH="$INSTALL/lib" $@

