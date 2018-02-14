import json
import os

from server import prop

CONF_PATH = os.path.join(os.path.expanduser('~'), '.elv2prop', '.elv2prop_conf')

empty_config = {
    'client_id': None,
    'song_library_path': None,
    'playlist_file_path': None,
}


def check_config(c):
    return all([x is not None for x in c.values()])


def load_from_file():
    os.makedirs(os.path.dirname(CONF_PATH), exist_ok=True)

    try:
        with open(CONF_PATH, 'r') as f:
            config = json.load(f)
    except FileNotFoundError:
        print('No config found, guess at paths')
        playlist_file, song_folder = prop.guess_file_paths()
        config = empty_config.copy()
        config['song_library_path'] = song_folder
        config['playlist_file_path'] = playlist_file
        return config, False

    if check_config(config):
        print('Loading config from file')
        return config, True

    return empty_config, False


def save_config_to_file(c):
    with open(CONF_PATH, 'w') as f:
        f.write(json.dumps(c))
