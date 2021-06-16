#!/bin/bash
set -euox pipefail

cmake --build build

if test ! -e exclude.txt; then
    echo 'exclude.txt not found'
    exit 1
fi

exec ./build/wlcs ../mir/build/lib/miral_wlcs_integration.so --gtest_filter="-$(cat exclude.txt)" $@
