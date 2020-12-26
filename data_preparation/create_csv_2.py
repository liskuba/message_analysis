import pandas as pd
import time
from count_in_all_files_2 import count_in_all_files_2
from dateutil import tz


def create_csv_2(person, list_of_paths_to_directories, output_file_path, print_paths=False):
    start = time.time()
    timestamps, reactions = count_in_all_files_2(
        person, list_of_paths_to_directories, print_paths
    )
    if print_paths:
        print(f'All files read in {time.time() - start} second')
        print('Creating data frame...')
    df = pd.DataFrame({'timestamp': timestamps,
                       'reaction': reactions})
    # df['date'] = pd.to_datetime(df['timestamp'], unit='ms', utc=True).dt.tz_convert(tz=tz.tzlocal())
    # df['day_of_the_week'] = df['date'].dt.strftime("%A")
    # df['floored_hour'] = df['date'].dt.strftime("%H")
    df = df.sort_values(by=['timestamp'], ascending=False)
    df.to_csv(output_file_path, index=False)
    if print_paths:
        print('Output file created')
        print(f'Measured time of creating csv_2 : {time.time() - start} seconds')
    return df
