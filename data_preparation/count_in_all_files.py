import os
from fnmatch import fnmatch
from count_in_one_file import count_in_one_file


def count_in_all_files(person, list_of_paths_to_directories, print_paths=False):
    """every directory should ends with '/'"""
    pattern = "message_*.json"
    timestamps = []
    lengths = []
    emojis = []
    i = 0
    for directory in list_of_paths_to_directories:
        for path, subdirs, files in os.walk(directory + 'messages' + os.path.sep):
            for name in files:
                if fnmatch(name, pattern):
                    if print_paths:
                        i += 1
                        print(f'{i}. {os.path.join(path, name)}')
                    timestamps, lengths, emojis = count_in_one_file(
                        person, os.path.join(path, name), timestamps, lengths, emojis
                    )
    return timestamps, lengths, emojis
