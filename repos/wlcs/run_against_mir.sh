#!/bin/bash
set -euox pipefail

cmake --build build

# This was hacked together from 3 confusing SO answers, I have no idea how it works
FILTER=$(cat ../mir/tests/acceptance-tests/wayland/CMakeLists.txt | sed -n "/^set(EXPECTED_FAILURES$/,/)/ { /^set(EXPECTED_FAILURES$/d ; /)/d ; /^$/d ; p }" | sed 's/#.*$//g; s/\s//g' | sed -z 's/\n/:/g')

# These tests take a while and are annoying
FILTER="$FILTER:*times_out*"

exec ./build/wlcs ../mir/build/lib/miral_wlcs_integration.so --gtest_filter="-$FILTER" $@
