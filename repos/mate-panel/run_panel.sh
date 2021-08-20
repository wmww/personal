#!/bin/bash

# Set the script to abort on error
set -e

# to build the panel:
# ./run_autogen.sh
# make && make install

# Get the path to the install directory next to this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
INSTALL="$DIR/install"

# Run the panel using the gsettings schema from the install directory
GSETTINGS_SCHEMA_DIR="$INSTALL/share/glib-2.0/schemas/" "$INSTALL/bin/mate-panel"
