#!/bin/bash
set -eox pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
find "$DIR" -name '*.pch' -o -name '*.gch' | xargs rm
