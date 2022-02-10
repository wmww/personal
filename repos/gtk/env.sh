# Not executable because this needs to be sourced

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TRIPLET=$(gcc -dumpmachine)
MAJOR_VERSION=3
if test -f "$DIR/meson.build"; then
    MAJOR_VERSION=$(grep -Po "version\s*:\s*'\d*\." "meson.build" | sed 's/[^0-9]//g')
fi

export GTK_INSTALL="$DIR/install"
export DESTDIR="$GTK_INSTALL"
export GTK_IM_MODULE_FILE="$GTK_INSTALL/immodules.cache"
export GTK_PATH="$GTK_INSTALL/usr/local/lib/$TRIPLET/gtk-${MAJOR_VERSION}.0/"
mkdir -p "$GTK_INSTALL"

BIN_PATH="$GTK_INSTALL/usr/local/bin/"

if test -z "$CUSTOM_GTK_SET"; then
    export   CUSTOM_GTK_SET=1
    export PATH="$BIN_PATH:$PATH"
    export LD_LIBRARY_PATH="$GTK_INSTALL/usr/local/lib/:$GTK_INSTALL/usr/local/lib/$TRIPLET/:$LD_LIBRARY_PATH"
    export PKG_CONFIG_PATH="$GTK_INSTALL/usr/local/lib/pkgconfig/:$GTK_INSTALL/usr/local/lib/$TRIPLET/pkgconfig:$PKG_CONFIG_PATH"
else
    echo "Environment already set up"
fi

# Look for a gtk-launch with "install" in it's path to detect the version
if test "$MAJOR_VERSION" = "3"; then
    GTK_VERSION=$(gtk-launch --version)
else
    GTK_VERSION=$("gtk${MAJOR_VERSION}-launch" --version)
fi

echo "Using GTK in $GTK_INSTALL (v$GTK_VERSION)"
