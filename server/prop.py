import os
import re
import shutil
import uuid
import warnings
from collections import OrderedDict
from datetime import datetime as dt
from urllib import parse

import xmltodict

with warnings.catch_warnings():
    warnings.simplefilter("ignore")
    from fuzzywuzzy import process as fwprocess


def scrub_title(title):
    title = title.replace('.pro6', '')
    title = title.lower()
    return re.sub(r'\W+', '', title)


def find_song_files(config: dict, songs=None) -> dict:
    song_files = os.listdir(config['song_library_path'])

    if songs is None:
        # return all song files:
        return song_files

    # otherwise, match provides songs
    songs_cleaned = {scrub_title(s): s for s in songs}
    song_files_cleaned = {scrub_title(s): s for s in song_files}

    out = []
    for s in songs_cleaned:
        try:
            tmp = song_files_cleaned[s]
        except KeyError:
            best_match = fwprocess.extractOne(
                s,
                song_files_cleaned.keys(),
                score_cutoff=80,
            )
            if best_match is None:
                tmp = None
            else:
                tmp = song_files_cleaned[best_match[0]]
        out.append(
            {'elv': songs_cleaned[s], 'pro': tmp}
        )
    return out


def create_new_playlist(chosen_service):
    # create dict we can serilize with xmltodict
    return OrderedDict([
        ('@displayName', f'{chosen_service["name"]} - {chosen_service["date"]}'),
        ('@UUID', str(uuid.uuid4())),
        ('@smartDirectoryURL', ''),
        ('@modifiedDate', dt.now().isoformat()),
        ('@type', '3'),
        ('@isExpanded', 'true'),
        ('@hotFolderType', '2'),
        ('array', [OrderedDict([
            ('@rvXMLIvarName', 'children'),
            ('RVDocumentCue', [])
        ]),
            OrderedDict([('@rvXMLIvarName', 'events')]),
        ])
    ])


def add_song_to_playlist(config, playlist, song):
    song_path = os.path.join(config['song_library_path'], song)
    # add song to playlist
    song_dict = OrderedDict([
        ('@UUID', str(uuid.uuid4())),
        ('@displayName', song),
        ('@filePath', parse.quote(song_path)),
        ('@selectedArrangementID', '00000000-0000-0000-0000-000000000000'),
        ('@actionType', '0'),
        ('@timeStamp', '0'),
        ('@delayTime', '0'),
    ])
    playlist['array'][0]['RVDocumentCue'].append(song_dict)
    return playlist


def write_backup_file(config):
    backup_name = f'{config["playlist_file_path"]}.backup'
    shutil.copyfile(config['playlist_file_path'], backup_name)


def write_playlist_to_file(config, playlist):
    write_backup_file(config)
    # read playlists file and parse
    with open(config['playlist_file_path'], 'r', encoding='utf-8') as f:
        xml_data = f.read()
        data = xmltodict.parse(xml_data)
    # add new playlist
    if type(data['RVPlaylistDocument']['RVPlaylistNode']['array'][0]['RVPlaylistNode']) == OrderedDict:
        data['RVPlaylistDocument']['RVPlaylistNode']['array'][0]['RVPlaylistNode'] = [
            data['RVPlaylistDocument']['RVPlaylistNode']['array'][0]['RVPlaylistNode'],
            playlist,
        ]
    else:
        data['RVPlaylistDocument']['RVPlaylistNode']['array'][0]['RVPlaylistNode'].append(playlist)
    # write out file
    with open(config['playlist_file_path'], 'w') as f:
        f.write(xmltodict.unparse(data))


def get_most_recent_pro6pl_file(p):
    try:
        files = [(os.path.join(p, f.name), f.stat().st_mtime) for f in os.scandir(p) if f.name.endswith('.pro6pl')]
        return max(files, key=lambda t: t[1])

    except Exception:
        # TODO log
        return None, 0


def find_song_path(playlist_file_path):
    try:
        root_pro6_path = os.path.dirname(os.path.dirname(playlist_file_path))
        settings_file_path = os.path.join(root_pro6_path, 'Preferences', 'GeneralPreferences.pro6pref')
        with open(settings_file_path, 'r', encoding='utf-8') as f:
            xml_data = f.read()
            data = xmltodict.parse(xml_data)
            return data['RVPreferencesGeneral']['SelectedLibraryFolder']['Location']
    except Exception as e:
        return None


def guess_file_paths(DEBUG=False):
    if DEBUG:
        return 'test', 'test'

    home_dir = os.path.expanduser('~')
    playlist_dir_home = os.path.join(
        home_dir,
        'AppData',
        'Roaming',
        'RenewedVision',
        'ProPresenter6',
        'PlaylistData',
    )
    playlist_dir_global = os.path.join(
        os.path.abspath(os.sep),
        'ProgramData',
        'RenewedVision',
        'ProPresenter6',
        'PlaylistData',
    )
    playlist_file_home, home_t = get_most_recent_pro6pl_file(playlist_dir_home)
    playlist_file_global, global_t = get_most_recent_pro6pl_file(playlist_dir_global)

    if home_t > global_t:
        # use home dir
        return playlist_file_home, find_song_path(playlist_file_home)
    else:
        # use global dir
        return playlist_file_global, find_song_path(playlist_file_global)
