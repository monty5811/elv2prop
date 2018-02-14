import json
from datetime import datetime as dt
from datetime import timedelta as td

import requests


def flatten_songs(s):
    if type(s['songs']) is not list:
        s['songs'] = s['songs']['song']
    return s


def get_services(token):
    today = dt.today() - td(days=6)
    end_day = today + td(days=40)
    r = requests.post(
        'https://api.elvanto.com/v1/services/getAll.json',
        data=json.dumps({
            'fields': ['songs'],
            'start': str(today.date()),
            'end': str(end_day.date())
        }),
        headers={
            'content-type': 'application/json',
            'Authorization': f'Bearer {token}',
        },
    )

    r.raise_for_status()

    data = r.json()
    if data['status'] != 'ok':
        raise

    if data['services']:
        return data['services']['service']
    else:
        raise
