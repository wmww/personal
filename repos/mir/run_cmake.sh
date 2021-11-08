#!/bin/bash
set -eox pipefail

DIR="$(realpath "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )")"
INSTALL="$DIR/install"
mkdir -p "$INSTALL"

if test $(dirname "$(realpath "$PWD")") != "$DIR"; then
    echo "You are not in a subdir of $DIR, this is probably a mistake"
    exit 1
fi

BUILD_DIR=$(basename $(readlink -f $(pwd)))

# If the build directory has "clang" in the name default to Clang, if "gcc" then default to GCC
if test -z "$CC"; then
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

# If the build directory contains "release" we want to build in release mode
if echo "$BUILD_DIR" | grep -i debug >/dev/null; then
    BUILD_TYPE=Debug
    echo "In $BUILD_DIR so making Debug build"
elif echo "$BUILD_DIR" | grep -i release >/dev/null; then
    BUILD_TYPE=Release
    echo "In $BUILD_DIR so making Release build"
else
    BUILD_TYPE=Debug
    echo "Making Debug build by default"
fi

# CMake does not expand symlinks, and if the path it's run in changes it deletes
# all generated files. KDevelop is configured with a specific directory. We
# could try to make sure this script uses the same directory as KDevelop, but
# for robustness instead we detect if CMake has already run, and if it has
# we use the previously configured directory.
if test -f CMakeCache.txt; then
    BUILD_PATH="$(
        grep '# For build in directory: .*' CMakeCache.txt | sed 's/.*: //' ||
        echo "could not detect build path"
    )"
    if test "$(realpath "$BUILD_PATH")" != "$(realpath "$PWD")"; then
        echo "Detected build path <$BUILD_PATH> does not match the current directory"
        exit 1
    fi
    cd "$BUILD_PATH"
fi

# lld is much faster than default linker
# Generate compile_commands.json for Sourcetrail
# Install into local install/ directory so use_this_mir.sh works
# Hack the rpath so installed Mir can find libs

cmake \
    "$DIR" \
    -DMIR_USE_LD=lld \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DCMAKE_INSTALL_PREFIX="$INSTALL" \
    -DCMAKE_INSTALL_RPATH="$INSTALL/lib" \
    $@

