#!/bin/bash

# This script will output a single self-contained executable at
# the output specified to pyinstaller's `--distpath` option

set -eu -o pipefail

# Pick a Python distribution to use, we'll use Apple's for now
PYTHON_DIST_BIN=/usr/bin/python3
# PYTHON_DIST_BIN=/opt/homebrew/bin/python3

# clean and setup
command -v deactivate && deactivate
rm -rf .venv dist-*
"${PYTHON_DIST_BIN}" -m venv .venv
source .venv/bin/activate

# build virtualenv
pip install -U pip
pip install -r requirements-build.txt

# build it
pyinstaller \
  --clean \
  --log-level DEBUG \
  --distpath dist-onefile \
  --onefile \
  customdisplayprofiles
