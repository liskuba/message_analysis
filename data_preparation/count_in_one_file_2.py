import json


def count_in_one_file_2(person, path_to_json, timestamps=None, reactions=None):
    """person means our name and surname on Facebook,
    e.g. person == 'Jan Nowak' """
    if timestamps is None:
        timestamps = []
    if reactions is None:
        reactions = []
    with open(path_to_json, 'r') as j:
        data = json.load(j)
        for message in data['messages']:
            if 'reactions' in message:
                for reaction in message['reactions']:
                    if reaction['actor'] == person:
                        timestamps.append(message['timestamp_ms'])
                        reactions.append(reaction['reaction'].encode('iso-8859-1').decode('utf-8'))
    return timestamps, reactions
