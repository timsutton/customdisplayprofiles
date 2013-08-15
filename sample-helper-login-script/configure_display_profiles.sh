#!/bin/sh
#
# configure_display_profiles.sh
#
# Very simple helper script to run the customdisplayprofiles tool to
# set profiles stored in a known folder location, with subfolders named
# by display index, like in the sample structure below. No special
# handling is done for the case of multiple profiles in a folder,
# but the tool will ignore all arguments after the first anyway.
#
# This would allow someone calibrating a display to configure a profile
# for all users simply by copying the profile to the correct folder
# and ensuring it's the only file in this folder.
#
# This script would typically be run at login using a LaunchAgent.
#
# Sample folder hierarchy:
#
# /Library/Org/CustomDisplayProfiles
# ├── 1
# │   └── Custom Profile 1.icc
# └── 2
#     └── Custom Profile 2.icc


PROFILES_DIR=/Library/Org/CustomDisplayProfiles
TOOL_PATH=/usr/local/bin/customdisplayprofiles

for DISPLAY_INDEX in $(ls "${PROFILES_DIR}"); do
    echo "Setting profile for display $DISPLAY_INDEX..."
    $TOOL_PATH set --display $DISPLAY_INDEX "$PROFILES_DIR/$DISPLAY_INDEX"/*
done
