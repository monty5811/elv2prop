import os
import sys
import threading
import webbrowser
from time import sleep

import psutil

from server import server
from server.config import load_from_file
from setup import version

try:
    import webview
except ImportError:
    pass


LINUX = sys.platform.startswith('linux')


def start_browser(url):
    # wait a while for flask to start, then open the browser
    sleep(3)
    webbrowser.open_new_tab(url)


def main():
    config, loaded_from_file = load_from_file()

    e2p_port = int(os.environ.get('E2P_PORT', 11843))
    e2p_host = str(os.environ.get('E2P_HOST', 'localhost'))

    server_kwargs = {
            'host': e2p_host,
            'port': e2p_port,
            'config': config,
            'config_from_file': loaded_from_file,
            'version': version,
        }

    url = f'http://{e2p_host}:{e2p_port}'
    if LINUX:
        # start browser
        t = threading.Thread(target=start_browser, args=(url,))
        t.start()
        server.start(
            host=e2p_host,
            port=e2p_port,
            config=config,
            config_from_file=loaded_from_file,
            version=version,
        )
    else:
        # on windows or macOS, use webview:
        t = threading.Thread(
            target=server.start,
            kwargs=server_kwargs
        )
        t.daemon = True
        t.start()
        sleep(3)  # wait for flask to start
        webview.create_window(
            "E -> P",
            f'{url}',
            resizable=False,
            width=1000,
            height=800,
            background_color='#f2f2f2',
        )


def check_prop():
    if 'propresenter' in [x.name().lower() for x in psutil.process_iter()]:
        print('It looks like ProPresenter may be running, please close it and hit enter to continue')
        input()
        check_prop()


if __name__ == '__main__':
    check_prop()
    main()
