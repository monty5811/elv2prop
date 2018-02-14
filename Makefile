run:
	@FLASK_APP=server.server \
	FLASK_DEBUG=1 \
	E2P_PORT=4001 \
	E2P_HOST="0.0.0.0" \
	python elv2prop.py

watchjs:
	@cd client; yarn run watch

buildclient:
	@cd client; yarn run build

watchcss:
	@cd client; find . -name '*.css' | entr -c yarn css

buildserver:
	@python setup.py build

buildmsi:
	@python setup.py bdist_msi

release: buildjs buildserver

lintserver:
	@isort --apply --recursive server elv2prop.py setup.py; flake8 server/ elv2prop.py setup.py;

lintclient:
	cd client; yarn format

lint: lintserver lintclient
