#!/bin/bash
set -e

# to build the panel:
# ./run_autogen.sh
# make && make install

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
INSTALL="$DIR/install"

GSETTINGS_SCHEMA_DIR="$INSTALL/share/glib-2.0/schemas/" "$INSTALL/bin/mate-panel"
