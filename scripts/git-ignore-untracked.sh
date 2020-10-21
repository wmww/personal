#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

if [ ! -d ".git" ]; then
  echo 'No .git directory'
  exit 1
fi

git status | grep -Pzo 'Untracked files:\n  .*\n(\t.*\n)+' | sed 's/\x0//' | grep -Po '(?<=\t).*$' | xargs -d '`' printf '\n# <autogenerated>\n%s# </autogenerated>\n\n' | tee -a .git/info/exclude
