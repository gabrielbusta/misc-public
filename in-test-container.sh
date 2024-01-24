python -I -m pip install -r /builds/worker/checkouts/vcs/requirements/test.txt --no-deps
py.test -n auto --cov-config=tox.ini --cov-append --cov=auslib --cov-report term-missing tests
