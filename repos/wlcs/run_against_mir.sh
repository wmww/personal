#!/bin/bash
set -euox pipefail

cmake --build build
exec ./build/wlcs ../mir/build/lib/miral_wlcs_integration.so --gtest_filter="-$(cat exclude.txt)" $@
