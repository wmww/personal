#!/bin/bash
set -eox pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

OPENSHOT_AUDIO="$DIR/../libopenshot-audio/install"
if test ! -d "$OPENSHOT_AUDIO"; then
    echo "libopenshot-audio not installed at $OPENSHOT_AUDIO"
    exit 1
fi

sudo apt install \
    libfreetype6-dev \
    libasound2-dev \
    libavcodec-dev \
    libavdevice-dev \
    libavfilter-dev \
    libavformat-dev \
    libavutil-dev \
    libswresample-dev \
    libswscale-dev \
    libpostproc-dev \
    libfdk-aac-dev \
    libjsoncpp-dev \
    libzmq3-dev \
    qtbase5-dev \
    qtmultimedia5-dev \
    libunittest++-dev \
    python3-dev \
    swig \
    libmagick++-dev

cd "$DIR"
cmake -B build -S . -DOpenShotAudio_ROOT="$OPENSHOT_AUDIO" -DCMAKE_INSTALL_PREFIX="$DIR/install"
cmake --build build --verbose
cmake --install build
