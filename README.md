# elv2prop

Ever wanted to pull your Elvanto services into ProPresenter? Now you can.

**This is alpha quality software with no guarantees - you should back up all your ProPresenter data before starting.**

**This has only been tested with ProPresenter 6 - it will probably not work with 5**

[![Build status](https://ci.appveyor.com/api/projects/status/42c7posfw6j9n78l/branch/master?svg=true)](https://ci.appveyor.com/project/monty5811/elv2prop/branch/master)

## Setup in Elvanto

The first thing you need to do is to register an application to access the Elvanto API.
This will let us grab the services and songs from Elvanto.
Follow the "Register an Application" instructions [here](https://www.elvanto.com/api/getting-started).
You need to set the redirect url to `http://localhost:11843`.

You need to make note of the "CLIENT ID" - you will need it later.

## Download and Install

* Download the latest release from here: [https://github.com/monty5811/elv2prop/releases](https://github.com/monty5811/elv2prop/releases)
* Then run the installer (you will get some warnings about the installer not being signed)

## First Run

**Do not run this tool when ProPresenter is open - it will not work and may corrupt your data.**

 * Open the installation folder (by default `C:\Program Files (x86)\monty5811\elv2prop`)
 * Run the `elv2prop.exe` file
 * You will be asked for the Client ID from above
 * Best guesses for the location of your ProPresenter data will be made, please check these are correct
 * Save the configuration
 * Login to Elvanto when prompted (note, your user account must have access to services on Elvanto)
 * Choose the service you want to sync
 * Add any additional files from ProPresenter to the playlist
 * Click save
 * Close the elv2prop window
 * Open ProPresenter to view your new playlist

## Development

The application is made up of two components - a server and a client.

### Server

The server is a python (3.6) app that runs a webserver that the client connects to.

The server is responsible for:

 * Fetching the services from Elvanto (can't be done in the client as the Elvanto API does not support CORS)
 * Finding ProPresenter files and matching them to songs in the Services
 * Making changes to the ProPresenter config files
 * Persisting settings to disk

#### Setup

```bash
python -m venv venv
. venv/bin/activate
pip install -r requirements-dev.txt
make run # start a dev server
```

Run the linters:

```bash
make lint
```

### Client

The client is a webapp written in Elm (0.18) and is responsible for:

 * Presenting the UI to the user
 * Handling oauth tokens for Elvanto access

The client runs in a web view.

#### Setup

```bash
cd client
yarn install
cd ..
make buildclient # to build the assets for distribution
make watchjs # watch for code changes
```
