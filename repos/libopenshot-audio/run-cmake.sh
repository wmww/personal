#!/bin/bash
set -eox pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

sudo apt install libasound2-dev # assumes Ubuntu
cd "$DIR"
mkdir -p build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/home/wmww/code/media/libopenshot-audio/install
cd "$DIR"
make -C build
make -C build install
