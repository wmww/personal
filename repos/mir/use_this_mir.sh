# Not executable because this needs to be sourced

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
INSTALL="$DIR/install"

BIN_PATH="$GTK_INSTALL/usr/local/bin/"

if test "_$CUSTOM_MIR" != "_$INSTALL"; then
    export CUSTOM_MIR="$INSTALL"
    export LD_LIBRARY_PATH="$INSTALL/lib/:$LD_LIBRARY_PATH"
    export PKG_CONFIG_PATH="$INSTALL/lib/pkgconfig/:$PKG_CONFIG_PATH"
else
    echo "Environment already set up"
fi

echo "Using Mir in $INSTALL"

