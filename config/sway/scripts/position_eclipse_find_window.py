#!/usr/bin/python3

import subprocess
import json

def is_visible_eclipse(node):
    return node.get('app_id') == 'Eclipse' and node['visible']

def is_find_replace(node):
    return is_visible_eclipse(node) and 'Find/Replace' in str(node.get('name'))

def is_main_eclipse(node):
    return is_visible_eclipse(node) and not is_find_replace(node)

def find_node(node, pred):
    if pred(node):
        return node
    else:
        for child in node['nodes']:
            result = find_node(child, pred)
            if result:
                return result
        for child in node['floating_nodes']:
            result = find_node(child, pred)
            if result:
                return result
    return None

def swaymsg(options, args):
    args = ['swaymsg'] + options + ['--'] + args
    result = subprocess.run(args, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError('`' + ' '.join(args) + '` failed:\n' + result.stderr)
    return result.stdout

def notify(msg):
    subprocess.run(['notify-send', str(msg)])

def main():
    result = swaymsg(['-t', 'get_tree'], [])
    tree = json.loads(result)
    toplevel = find_node(tree, is_main_eclipse)
    if toplevel is None:
        raise RuntimeError('Could not find main Eclipse window')
    popup = find_node(tree, is_find_replace)
    if popup is None:
        raise RuntimeError('Could not find find/replace window')
    toplevel_rect = toplevel['rect']
    popup_rect = popup['rect']
    popup_x = toplevel_rect['x'] + toplevel_rect['width'] - popup_rect['width']
    popup_y = toplevel_rect['y'] + toplevel_rect['height'] - popup_rect['height']
    args = ['[con_id=' + str(popup['id']) + ']', 'move', 'position', str(popup_x), str(popup_y)]
    result = swaymsg([], args)

if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        notify(e)
        raise e
