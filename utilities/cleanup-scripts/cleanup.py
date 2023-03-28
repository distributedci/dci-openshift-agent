#!/usr/bin/python3

import sys
import pathlib
import argparse
import re
import shutil

def get_directories(directory, pattern):
    directories = dict()
    prog = re.compile(pattern)
    currentDirectory = pathlib.Path(directory)
    for currentFile in currentDirectory.iterdir():
      m = prog.match(currentFile.name)
      if currentFile.is_dir() and m:
          if m.group(1) in directories:
              directories[m.group(1)].append("%s" % currentFile)
          else:
              directories[m.group(1)] = ["%s" % currentFile]
    return directories

def garbage_collect(directories, number, run, quiet):
    # Entries to skip from the end of the list
    if number > 0:
        number = number.__neg__()
    for version in directories:
        dir_version = directories[version]
        if len(dir_version) > 1:
            # This is a numeric sort, 2.10 will be before 2.9 but our use case
            # includes full date strings so it won't be a problem for us.
            dir_version.sort()
            for to_remove in dir_version[:number]:
                if not quiet:
                    print(to_remove)
                if run:
                    shutil.rmtree(to_remove)

def main():
    default_regex = r'([0-9]+\.[0-9]+\.[0-9]+).*nightly.*'
    parser = argparse.ArgumentParser(description='Garbage collect directories')
    parser.add_argument('directory', metavar='DIR',
            help='Directory to garbage collect')
    parser.add_argument('-p', '--pattern', dest='pattern',
            default=default_regex,
            help='Use Regex PATTERN, must include a group definition or'
                 ' it will fail.  default: %s' % default_regex,
            metavar="PATTERN")
    parser.add_argument('-n', '--number', dest='number',
            default=1, type=int,
            help='The NUMBER of entries to keep, default: 1')
    parser.add_argument('-r', '--run',
            action='store_true', dest='run', default=False,
            help='Specify this to actually do the garbage collection,'
                 ' otherwise it will just print what it will remove')
    parser.add_argument('-q', '--quiet',
            action='store_true', dest='quiet', default=False,
            help='Be Quiet')

    args = parser.parse_args()


    directories = get_directories(args.directory, args.pattern)
    garbage_collect(directories, args.number, args.run, args.quiet)

if __name__ == '__main__':
    sys.exit(main())

