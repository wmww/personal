# Not executable because this needs to be sourced

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TRIPLET=$(gcc -dumpmachine)

export GTK_INSTALL="$DIR/install"
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
GTK_VERSION="[unknown]"
if which gtk4-launch | grep "install" >/dev/null; then
    GTK_VERSION=$(gtk4-launch --version)
elif which gtk-launch | grep "install" >/dev/null; then
    GTK_VERSION=$(gtk-launch --version)
fi

echo "Using GTK in $GTK_INSTALL (v$GTK_VERSION)"
