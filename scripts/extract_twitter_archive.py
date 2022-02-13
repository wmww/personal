#!/bin/python3

import os
import sys
import subprocess
import logging
import datetime
import re
import json
from typing import Tuple, Optional

human_date_format = '%b %-d, %Y'
output_file_prefix = 'Twitter Data '
output_file_date_format = '%Y-%m-%d'
default_targets = [
    os.path.expanduser('~/heavy/Resources/Backup'),
    os.path.expanduser('~/data/heavy/Resources/Backup'),
]
rt_media_max_size = 1024 * 1024
media_max_size = 1024 * 1024 * 10

# TODO: add multi-account support, using `unzip -p file.zip data/account.js` to ID the account

class Program:
    def __init__(self, program: str, package: str):
        result = subprocess.run(['which', program], capture_output=True)
        assert result.returncode == 0, program + ' command does not exist, install ' + package
        self.name = program
        logging.info('%s executable detected', program)

    def run(self, args: list[str]) -> None:
        cmd = [self.name] + args
        logging.info('running: `%s`', ' '.join(cmd))
        result = subprocess.run(cmd)
        result.check_returncode()

def path_size(path: str) -> int:
    if not os.path.exists(path):
        return 0
    if not os.path.isdir(path):
        return os.path.getsize(path)
    size = 0
    for item in os.listdir(path):
        size += path_size(os.path.join(path, item))
    return size

def format_size(size: float) -> str:
    for postfix in ['B', 'KB', 'MB', 'GB', 'TB']:
        if size < 1024:
            return str(int(size)) + postfix
        size /= 1024.0
    return str(size) + 'PB'

def format_reduction(initial: float, final: float) -> str:
    percent = int((initial - final) / initial * 1000) / 10.0
    if percent > 0:
        word = 'smaller'
    elif percent < 0:
        word = 'bigger'
    else:
        word = 'same size'
    percent = abs(percent)
    return (
        'from ' + format_size(initial) +
        ' to ' + format_size(final) +
        ' (' + str(percent) + '% ' + word + ')'
    )

def downloads_dir() -> str:
    return os.path.expanduser('~/Downloads')

def load_blessed_media_ids(archive: str) -> set[str]:
    tweet_js_path = os.path.join(archive, 'data', 'tweet.js')
    logging.info('loading %s', tweet_js_path)
    with open(tweet_js_path, 'r') as f:
        raw_contents = f.read()
    json_str = raw_contents.split('=', 1)[1]
    logging.info('parsing massive tweet.js JSON')
    tweets = json.loads(json_str)
    logging.info('finding media IDs of user\'s tweets')
    blessed: set[str] = set()
    for item in tweets:
        tweet = item['tweet']
        media_list = (
            tweet.get('extended_entities', {}).get('media', []) +
            tweet.get('entities', {}).get('media', [])
        )
        for media in media_list:
            assert isinstance(media['id'], str)
            blessed.add(media['id'])
    logging.info('found %d blessed media IDs', len(blessed))
    return blessed

def remove_non_blessed_media(media_dir: str, blessed: set[str]) -> None:
    original = path_size(media_dir)
    removed = 0
    kept = 0
    for item in os.listdir(media_dir):
        path = os.path.join(media_dir, item)
        media_id = item.split('-', 1)[0]
        if media_id not in blessed and path_size(path) > rt_media_max_size:
            os.remove(path)
            removed += 1
        else:
            kept += 1
    new_size = path_size(media_dir)
    logging.info(
        'removed %d media files and kept %d in %s. size reduced %s',
        removed,
        kept,
        os.path.basename(media_dir),
        format_reduction(original, new_size)
    )

def remove_larger_than(media_dir: str, max_size: float) -> None:
    original = path_size(media_dir)
    removed = 0
    kept = 0
    if not os.path.isdir(media_dir):
        logging.info('%s is not a directory, skipping', media_dir)
        return
    for item in os.listdir(media_dir):
        path = os.path.join(media_dir, item)
        if path_size(path) > max_size:
            os.remove(path)
            removed += 1
        else:
            kept += 1
    new_size = path_size(media_dir)
    logging.info(
        'removed %d media files larger than %s and kept the other %d in %s. size reduced %s',
        removed,
        format_size(max_size),
        kept,
        os.path.basename(media_dir),
        format_reduction(original, new_size)
    )

def remove_all_recursive(parent: str) -> None:
    assert output_file_prefix in parent
    for item in os.listdir(parent):
        path = os.path.join(parent, item)
        if os.path.isdir(path):
            remove_all_recursive(path)
        elif os.path.isfile(path):
            os.remove(path)

def trim_archive_size(archive: str) -> None:
    blessed = load_blessed_media_ids(archive)
    data_dir = os.path.join(archive, 'data')
    remove_non_blessed_media(os.path.join(data_dir, 'tweet_media'), blessed)
    remove_larger_than(os.path.join(data_dir, 'tweet_media'), media_max_size)
    remove_larger_than(os.path.join(data_dir, 'direct_messages_group_media'), media_max_size)
    remove_larger_than(os.path.join(data_dir, 'direct_messages_media'), media_max_size)
    remove_larger_than(os.path.join(data_dir, 'spaces_media'), 0)
    remove_all_recursive(os.path.join(archive, 'assets', 'images', 'twemoji'))
    logging.info('removed twemoji')
    try:
        os.remove(os.path.join(data_dir, 'ad-impressions.js'))
        logging.info('removed ad-impressions.js')
    except FileNotFoundError:
        pass
    try:
        os.remove(os.path.join(data_dir, 'ad-engagements.js'))
        logging.info('removed ad-engagements.js')
    except FileNotFoundError:
        pass

def latest_archive() -> Tuple[str, datetime.date]:
    downloads = downloads_dir()
    candidate: Optional[Tuple[str, datetime.date]] = None
    pattern = r'^twitter-(\d{4}-\d{2}-\d{2})-\w+\.zip$'
    regex = re.compile(pattern)
    logging.info('searching %s for twitter archives', downloads)
    for item in os.listdir(downloads):
        match = regex.fullmatch(item)
        if match is not None:
            path = os.path.join(downloads, item)
            date = datetime.date.fromisoformat(match.group(1))
            logging.info('found twitter archive %s from %s', item, date.strftime(human_date_format))
            if candidate is None or candidate[1] < date:
                candidate = (path, date)
    assert candidate is not None, 'no file matching ' + pattern + ' in ' + downloads
    logging.info(
        'newest archive from %s (zipped size: %s)',
        candidate[1].strftime(human_date_format),
        format_size(path_size(candidate[0]))
    )
    return candidate

def trash_old(parent: str, trash: Program) -> float:
    cumulative_size = 0
    for item in os.listdir(parent):
        path = os.path.join(parent, item)
        if os.path.isdir(path) and item.startswith(output_file_prefix):
            size = path_size(path)
            trash.run([path])
            logging.info('old archive \'%s\' trashed (size: %s)', item, format_size(size))
            cumulative_size += size
    return cumulative_size

def find_target(target_arg: Optional[str]) -> str:
    if target_arg is not None:
        assert os.path.isdir(target_arg), target_arg + ' is not a valid directory'
        return target_arg
    else:
        for target in default_targets:
            if os.path.isdir(target):
                return target
        assert False, 'Failed to find target, none of these exist:\n  ' + '\n  '.join(default_targets)

def main() -> None:
    if '-h' in sys.argv or '--help' in sys.argv:
        print(
            'Tool that:\n' +
            ' - finds the latest Twitter archive in ~/Downloads\n' +
            ' - extracts it to the given directory or of the defaults\n' +
            ' - trashes old archives\n' +
            ' - deletes unneeded large files in the archive'
        )
        exit(0)
    trash = Program('trash', 'trash-cli')
    unzip = Program('unzip', 'unzip')
    source, date = latest_archive()
    target_arg = None
    if len(sys.argv) == 2:
        target_arg = sys.argv[1]
    elif len(sys.argv) > 2:
        assert False, 'Invalid number of arguments'
    target = find_target(target_arg)
    old_size = trash_old(target, trash)
    dir_name = output_file_prefix + date.strftime(output_file_date_format)
    dest = os.path.join(target, dir_name)
    unzip.run(['-q', source, '-d', dest])
    initial_dest_size = path_size(dest)
    logging.info('archive extracted into \'%s\' (size: %s)', dest, format_size(initial_dest_size))
    trim_archive_size(dest)
    new_size = path_size(dest)
    logging.info('archive size reduced %s', format_reduction(initial_dest_size, new_size))
    logging.info('since previous archive, size changed %s', format_reduction(old_size, new_size))

if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    main()
    logging.info('done')
