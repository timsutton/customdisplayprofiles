#!/bin/bash

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
# TODO: Can we improve the startup time? Even on an M1 Max it seems to take 4 seconds to 
# pyinstaller \
#   --clean \
#   --log-level DEBUG \
#   --onefile \
#   --distpath dist-onefile \
#   customdisplayprofiles.spec

pyinstaller \
  --clean \
  --log-level DEBUG \
  --distpath dist-onefile \
  --onefile \
  customdisplayprofiles

# pyinstaller \
#   --clean \
#   --log-level DEBUG \
#   --distpath dist-onedir \
#   --onedir \
#   customdisplayprofiles
