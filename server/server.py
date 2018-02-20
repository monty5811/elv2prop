import json

import requests
from flask import (Flask, abort, jsonify, make_response, render_template,
                   request)

from .config import save_config_to_file
from .elvanto import ElvantoApiError, ElvantoNoServices, get_services
from .prop import (add_song_to_playlist, create_new_playlist, find_song_files,
                   write_playlist_to_file)


app = Flask(__name__, static_folder='static', static_url_path='/static')


@app.route('/')
def index():
    if app.config.C_from_file:
        try:
            all_files = json.dumps(find_song_files(app.config.C))
        except Exception:
            all_files = []
    else:
        all_files = []

    return render_template(
        'index.html',
        config=json.dumps(app.config.C),
        config_from_file=json.dumps(app.config.C_from_file),
        all_files=all_files,
        version=app.config.version,
    )


@app.route('/fetch', methods=['POST'])
def fetch():
    token = request.json.get('token', '')
    try:
        services = get_services(token)
    except requests.exceptions.HTTPError:
        resp = make_response(jsonify({'msg': 'We encountered a problem talking to Elvanto, please try again'}))
        resp.status_code = 503
        return resp
    except ElvantoApiError as e:
        resp = make_response(jsonify({'msg': 'Elvanto API Error', 'extra': e.args[0]}))
        resp.status_code = 503
        return resp
    except ElvantoNoServices:
        resp = make_response(jsonify({'msg': 'No services found on Elvanto'}))
        resp.status_code = 404
        return resp

    return jsonify(services)


@app.route('/choose', methods=['POST'])
def choose():
    # choose service
    service = request.json.get('service', {})
    titles = service.get('titles', [])
    # find matching songs and return to client
    files = find_song_files(app.config.C, songs=titles)
    return jsonify(files)



@app.route('/confirm', methods=['POST'])
def confirm():
    # confirm - write to disk
    service = request.json.get('service', {})
    extra_songs = request.json.get('extras', [])
    songs = request.json.get('songs', [])
    songs = [s['pro'] for s in songs if s['pro'] is not None]

    songs = songs + extra_songs

    playlist = create_new_playlist(service)
    for song in songs:
        playlist = add_song_to_playlist(app.config.C, playlist, song)
    write_playlist_to_file(app.config.C, playlist)

    return jsonify({'status': 'Done'})


@app.route('/update-config', methods=['POST'])
def update_config():
    # update config from client side, persist to disk
    conf = request.json.get('config')
    if conf is None:
        abort(400)

    app.config.C = conf
    save_config_to_file(conf)
    app.config.C_from_file = True

    return jsonify(conf)


@app.after_request
def add_header(r):
    """
    Add headers to both force latest IE rendering engine or Chrome Frame,
    and also to cache the rendered page for 10 minutes.
    """
    r.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    r.headers["Pragma"] = "no-cache"
    r.headers["Expires"] = "0"
    r.headers['Cache-Control'] = 'public, max-age=0'
    return r


def start(host=None, port=None, config=None, config_from_file=None, version=''):
    app.config.C = config
    app.config.C_from_file = config_from_file
    app.config.version = version
    app.run(host=host, port=port)
