#! /bin/bash
# from https://github.com/MirServer/mir-test-tools/wiki/Notes

if [ -x "$(command -v fgconsole)" ]
then
  trap "sudo chvt $(sudo fgconsole)" EXIT
fi

if [ -v DISPLAY ]
then
  snap run mir-test-tools.gtk3-test || exit 1
  snap run mir-test-tools.qt-test || exit 1
  snap run mir-test-tools.sdl2-test || exit 1
  snap run mir-test-tools.smoke-test || exit 1
  snap run mir-test-tools.performance-test || exit 1
fi

sudo snap run mir-test-tools.gtk3-test || exit 1
sudo snap run mir-test-tools.qt-test || exit 1
sudo snap run mir-test-tools.sdl2-test || exit 1
sudo snap run mir-test-tools.smoke-test || exit 1
sudo snap run mir-test-tools.performance-test || exit 1

echo All tests passed
