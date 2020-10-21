#!/bin/bash
set -euo pipefail

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

CHECKOUT=master
if test $# -gt 1; then
    echo "Too many arguments"
    exit 1
elif test $# -eq 1; then
    CHECKOUT=$1
    echo "Will check out Sway and wlroots $CHECKOUT"
fi

build_package() {
    echo "Building package in $1"
    cd $1
    if [ -e build ]; then
        sudo ninja -C build uninstall
        rm -Rf build/
    fi
    git checkout master
    git pull origin master
    git checkout $CHECKOUT
    $SCRIPTS_DIR/wlroots-meson-build-arch.sh
    ninja -C build
    sudo ninja -C build install
}

build_package ~/code/wlroots
build_package ~/code/sway

echo "Done building and installing"
