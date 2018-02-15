#!/usr/bin/env python
"""Build script."""
import os

from cx_Freeze import Executable, setup

version = '2018.02.15'


def find_files():
    """Add non-python files to build."""
    return [
        os.path.join('server', 'static'),
        os.path.join('server', 'templates'),
    ]


build_exe_options = {
    'packages': ['os', 'idna', 'encodings', 'asyncio', 'jinja2', 'requests', ],
    'excludes': ['tkinter', 'tcl', ],
    'include_files': find_files(),
    'include_msvcr': True,
}

company_name = 'monty5811'
product_name = 'elv2prop'

bdist_msi_options = {
    'upgrade_code': '{4376bf82-edf1-47ec-a4fb-35622b6c1d08}',
    'add_to_path': True,
    'initial_target_dir': rf'[ProgramFilesFolder]\{company_name}\{product_name}',
}

PYTHON_INSTALL_DIR = os.path.dirname(os.path.dirname(os.__file__))
os.environ['TCL_LIBRARY'] = os.path.join(PYTHON_INSTALL_DIR, 'tcl', 'tcl8.6')
os.environ['TK_LIBRARY'] = os.path.join(PYTHON_INSTALL_DIR, 'tcl', 'tk8.6')

if __name__ == '__main__':
    setup(
        name='elv2prop',
        version='2017.08.20',
        description='elv2prop',
        options={
            'build_exe': build_exe_options,
            'bdist_msi': bdist_msi_options,
        },
        executables=[Executable('elv2prop.py', base=None)]
    )
