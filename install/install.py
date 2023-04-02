#!/usr/bin/env python

import argparse
from pathlib import Path
import yaml
import sys
import os
import copy

import spec

DRY_RUN = False

def confirm(prompt, default_yes=True):
    if default_yes:
        response = input(prompt + ' [Y/n] ')
        if not response:
            return True
    else:
        response = input(prompt + ' [y/N] ')
        if not response:
            return False
        
    match response.lower()[0]:
        case 'y':
            return True
        # Default to false with any value other than yes
        case _:
            return False

if __name__ == '__main__':
    script_directory = Path(sys.path[0])

    parser = argparse.ArgumentParser(
        prog='dotfiles-install',
        description='Manage dotfiles installation from git repo')
    
    parser.add_argument('-c', '--config', type=Path,
                        help='Configuration file to use')
    parser.add_argument('-s', '--spec', type=Path,
                        default=Path(script_directory, 'spec.yml'),
                        help='Program specification file to use')
    parser.add_argument('-d', '--directory', type=Path,
                        default='~/',
                        help='Target installation directory')
    parser.add_argument('-b', '--backup',
                        default=True,
                        action='store_true',
                        help='Whether to backup old dotfiles')
    parser.add_argument('-B', '--backup-directory', type=Path,
                        help='Directory to store backup files in, will be created',
                        default=Path('./backup'))
    parser.add_argument('--dry-run', type=bool,
                        default=False,
                        help='Just print actions that would be taken, but do not perform them')

    args = parser.parse_args()

    if args.backup and args.backup_directory == None:
        print('Backing up is turned on, but no backup directory specified.')
        print('Please provide a backup directory with -B')
        sys.exit(1)


    print(args)

    if not args.directory.expanduser().exists():
       print(f'Output directory {args.directory} does not exist, exiting')
       sys.exit(1)

    if not args.backup_directory.expanduser().exists():
        try: 
            args.backup_directory.mkdir()
        except Error as e:
            print(f'Error creating directory {args.backup_directory}, exiting')
            print(e)
            sys.exit(2)


    with open(args.spec, 'r') as stream:
        try:
            doc = yaml.safe_load(stream)
        except yaml.YAMLError as exc:
            print(exc)
            sys.exit(3)

        specification = spec.process(doc)

    with open(args.config, 'r') as stream:
        try:
            conf = yaml.safe_load(stream)
        except yaml.YAMLError as exc:
            print(exc)
            sys.exit(3)

    # Ensure that every program in the configuration has an associated spec

    not_found = [prog for prog in conf
                 if prog not in specification]
    if not_found:
        print('The following programs were not found in specification entries:')
        for prog in not_found:
            print('  - {}'.format(prog))
        print('Please remove these programs or revise the specification')
        sys.exit(4)

    # Resolve program dependencies, adding them to the install list
    install_list = set()
    
    stk = copy.copy(conf)
    while stk:
        prog = stk.pop()
        if prog in install_list:
            # We've already resolved this program's dependencies, move along
            continue

        install_list.add(prog)

        spec_entry = specification[prog]
        if spec_entry.depends != None:
            stk.extend(spec_entry.depends)

    should_backup = args.backup
    backup_dir = Path(args.backup_directory) if should_backup else None
    print('Programs ({}):'.format(len(install_list)))
    for p in install_list:
        print('  - {}'.format(p))
    print()
    print('Installing to {}/'.format(args.directory.expanduser()))

    if should_backup:
        print('Backing up existing files to {}/'.format(backup_dir))

    print()
    proceed = confirm('Proceed with installation?')
    if not proceed:
        sys.exit(1)

    import shutil

    skipped = False
    partial_installation = False
    for prog in install_list:
        files = specification[prog].files
        for f in files:
            src = Path(f)
            dest = Path(args.directory.expanduser(), f)
            backup_dest = Path(backup_dir, f)

            if src.is_file():
                if should_backup and dest.is_file():
                    shutil.copy(dest, backup_dest)
                shutil.copy(src, dest)
            elif src.is_dir():
                if should_backup and dest.is_dir():
                    shutil.copytree(dest, backup_dest, dirs_exist_ok=True)
                shutil.copytree(src, dest, dirs_exist_ok=True)
            else:
                skip = confirm("Don't know how to install {}, skip?".format(f))
                if skip:
                    skipped = True
                    continue
                else:
                    partial_installation = True
                    # There should be warning text about partial installation here
                    sys.exit(1)


