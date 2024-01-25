# Update the PYTHONPATH to include Balrog's source code (so the tests can import Balrog modules.)
export PYTHONPATH="${PYTHONPATH}:/builds/worker/checkouts/vcs/src"
# Install the test's dependencies, you only have to do this when the container boots up.
python -I -m pip install -r /builds/worker/checkouts/vcs/requirements/test.txt --no-deps

# To run all the tests:
py.test --pdb -n auto --cov-config=tox.ini --cov-append --cov=auslib --cov-report term-missing tests

# Ex. of running a specific test:
py.test --pdb -n auto --cov-config=tox.ini --cov-append --cov=auslib --cov-report term-missing tests/test_db.py::TestPermissions::testGrantPermissions

# The excution will stop at the first raised Exception or breakpoint
# and drop you into the builtin Python debugger https://docs.python.org/3/library/pdb.html
