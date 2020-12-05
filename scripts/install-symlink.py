#!/usr/bin/python3

import sys
import os
from os import path
import pathlib

def expand_path(p: str) -> str:
    p = path.expanduser(p)
    p = path.expandvars(p)
    return p

def get_yn(message: str, default: bool) -> bool:
    y = 'Y' if default is True else 'y'
    n = 'N' if default is False else 'n'
    message += ' [' + y + '/' + n + ']'
    while True:
        result = input(message).strip().lower()
        if result == '':
            return default
        elif result in ['y', 'yes', 'yy']:
            return True
        elif result in ['n', 'no', 'nn']:
            return False

def main(target_path: str):
    target_path = path.abspath(target_path)
    assert path.isfile(target_path), repr(target_path) + ' does not exist'
    meta_path = target_path + '.meta'
    assert path.isfile(meta_path), repr(meta_path) + ' does not exist'
    with open(meta_path) as f:
        meta_path = f.read().strip()
    dest_dir = expand_path(meta_path)
    if not path.exists(dest_dir):
        if get_yn(repr(dest_dir) + ' does not exist, would you like to create it?', True):
            os.makedirs(dest_dir, exist_ok=True)
        else:
            print('Aborting')
            exit(1)
    assert path.isdir(dest_dir), repr(dest_dir) + ' is not a directory'
    dest_path = path.join(dest_dir, path.basename(target_path))
    if path.islink(dest_path):
        existing_target = os.readlink(dest_path)
        if existing_target == target_path:
            print(repr(dest_path) + ' already points to ' + repr(target_path))
            return
        print(repr(dest_path) + ' is already a link, pointing to ' + repr(existing_target) + '.')
        if get_yn('Replace?', True):
            os.remove(dest_path)
        else:
            print('Aborting')
            exit(1)
    if path.exists(dest_path):
        print(repr(dest_path) + ' already exists')
        exit(1)
    os.symlink(target_path, dest_path)
    print('Linked ' + repr(dest_path) + ' to ' + repr(target_path))

if __name__ == '__main__':
    assert len(sys.argv) == 2, 'Wrong number of args'
    target_path = sys.argv[1]
    main(target_path)
