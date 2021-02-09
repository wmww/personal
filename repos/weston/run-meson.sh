#!/bin/bash
set -eox pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source "$DIR/env.sh"

export WLD="$INSTALL" # Does this do anything? idk
mkdir -p "$INSTALL"

meson build -Dlauncher-logind=false -Dbackend-rdp=false -Dpipewire=false -Dprefix="$INSTALL"

echo "
You can now build with
  ninja -C build install
and run with
  (source env.sh; weston)"
