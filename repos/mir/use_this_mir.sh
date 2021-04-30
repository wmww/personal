# Not executable because this needs to be sourced

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
INSTALL="$DIR/install"

BIN_PATH="$GTK_INSTALL/usr/local/bin/"

if test "_$CUSTOM_MIR" != "_$INSTALL"; then
    export CUSTOM_MIR="$INSTALL"
    # Setting LD_LIBRARY_PATH is not needed because we set the rpath
    # We need to set the rpath in two places:
    # 1. for the thing using miral (setting LDFLAGS as we do below is picked up by at least meson)
    # 2. when building mir (so the private libraries can find each other) (this is done via a cmake argument in run_cmake.sh)
    # export LD_LIBRARY_PATH="$INSTALL/lib/:$LD_LIBRARY_PATH"
    export LDFLAGS="-Wl,-rpath=$INSTALL/lib"
    export PKG_CONFIG_PATH="$INSTALL/lib/pkgconfig/:$PKG_CONFIG_PATH"
else
    echo "Environment already set up"
fi

echo "Using Mir in $INSTALL"

