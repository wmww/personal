#!/bin/bash

# Set up CMake to compile KDevelop
# Most of this file is probably wrong because it's all trial and error

# Safe mode
set -euo pipefail

# Echo commands to terminal
set -x

# The build system doesn't like symlinks in the current working path
cd $(readlink -f $(pwd))

# Check that we are in the kdevelop directory
if ! grep 'kdevelop' CMakeLists.txt &> /dev/null; then
    echo "Please run this script when inside the KDevelop root source directory"
    exit 1
fi

mkdir -p build
cd build

export DESTDIR="$(pwd)/install"
export BINDIR="$DESTDIR/bin"
export LIBDIR="$DESTDIR/lib"
export INCLUDEDIR="$DESTDIR/include"

mkdir -p "$DESTDIR"

cmake .. \
    -DCMAKE_BUILD_TYPE=Debug \
    -DKDE_INSTALL_BINDIR="$BINDIR" \
    -DKDE_INSTALL_LIBDIR="$LIBDIR" \
    -DKDE_INSTALL_INCLUDEDIR="$INCLUDEDIR" \
    -DCMAKE_INSTALL_PREFIX="$DESTDIR" \
    -DLIB_INSTALL_DIR="$LIBDIR" \
    -DKDE_INSTALL_USE_QT_SYS_PATHS=OFF \
    -DBUILD_TESTING=OFF
