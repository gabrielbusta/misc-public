export PYTHONPATH="${PYTHONPATH}:/builds/worker/checkouts/vcs/src"
python -I -m pip install -r /builds/worker/checkouts/vcs/requirements/test.txt --no-deps
py.test --pdb -n auto --cov-config=tox.ini --cov-append --cov=auslib --cov-report term-missing tests

py.test --pdb -n auto --cov-config=tox.ini --cov-append --cov=auslib --cov-report term-missing tests/test_db.py::testGrantPermissions
