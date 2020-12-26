import json
import emoji


def count_in_one_file(person, path_to_json, timestamps=None, lengths=None, emojis=None):
    """person means our name and surname on Facebook,
    e.g. person == 'Jan Nowak' """
    if lengths is None:
        lengths = []
    if timestamps is None:
        timestamps = []
    if emojis is None:
        emojis = []
    with open(path_to_json, 'r') as j:
        data = json.load(j)
        for message in data['messages']:
            if message['sender_name'] != person:
                continue
            if 'content' in message:
                timestamps.append(message['timestamp_ms'])
                msg = message['content'].encode('iso-8859-1').decode('utf-8')
                lengths.append(len(msg))
                e = ''
                for key in emoji.UNICODE_EMOJI.keys():
                    if key in msg:
                        e += key
                emojis.append(e)
    return timestamps, lengths, emojis


