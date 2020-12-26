import os
from fnmatch import fnmatch
from count_in_one_file_2 import count_in_one_file_2


def count_in_all_files_2(person, list_of_paths_to_directories, print_paths=False):
    """every directory should ends with '/'"""
    pattern = "message_*.json"
    timestamps = []
    reactions = []
    i = 0
    for directory in list_of_paths_to_directories:
        for path, subdirs, files in os.walk(directory + 'messages/'):
            for name in files:
                if fnmatch(name, pattern):
                    if print_paths:
                        i += 1
                        print(f'{i}. {os.path.join(path, name)}')
                    timestamps, reactions = count_in_one_file_2(
                        person, os.path.join(path, name), timestamps, reactions
                    )
    return timestamps, reactions
