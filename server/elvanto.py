import json
from datetime import datetime as dt
from datetime import timedelta as td

import requests


class ElvantoApiError(Exception):
    pass


class ElvantoNoServices(Exception):
    pass


def flatten_songs(s):
    if type(s['songs']) is not list:
        s['songs'] = s['songs']['song']
    return s


def add_pretty_date(s):
    d = dt.strptime(s['date'], '%Y-%m-%d %H:%M:%S')
    fmt = '%A %d %b - %H:%M'
    s['pretty_date'] = d.strftime(fmt)

    return s


def get_services(token):
    """
    Make a call to the Elvanto API to get all the services in the next 40 days.

    Returns a list of services or raises one of the following exceptions:
     - `ElvantoNoServices`
     - `ElvantoApiError`
     - `requests.exceptions.HTTPError`
    """
    today = dt.today() - td(days=1)
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
        try:
            err = data['error']
        except KeyError:
            err = {'code': 0, 'message': 'Unknown Error'}
        raise ElvantoApiError(err)

    if data['services']:
        services = data['services']['service']
        services = [flatten_songs(s) for s in services]
        services = [add_pretty_date(s) for s in services]
        return services
    else:
        raise ElvantoNoServices
