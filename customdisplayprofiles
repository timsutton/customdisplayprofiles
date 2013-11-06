#!/usr/bin/python
#
# customdisplayprofiles
#
# A command-line utility for setting custom ColorSync ICC profiles
# for connected displays.
#
# Copyright 2013 Timothy Sutton

import os
import objc
import Foundation
import Quartz
import optparse
import sys

from pprint import pprint

# - below is bridge metadata of we need of the ColorSync framework
# - last two arguments of ColorSyncProfileVerify have additional
#   type_modifier metadata for 'out'-type arguments so that they
#   can be passed by reference, though this currently does not seem
#   to function correctly
objc.parseBridgeSupport("""<?xml version='1.0'?>
<!DOCTYPE signatures SYSTEM "file://localhost/System/Library/DTDs/BridgeSupport.dtd">
<signatures version='1.0'>
    <cftype name='ColorSyncProfileRef' type='^{ColorSyncProfile=}' tollfree='__NSCFType' gettypeid_func='ColorSyncProfileGetTypeID'/>
    <constant name='kColorSyncDeviceDefaultProfileID' type='^{__CFString=}'/>
    <constant name='kColorSyncDisplayDeviceClass' type='^{__CFString=}'/>
    <constant name='kColorSyncProfile' type='^{__CFString=}'/>
    <constant name='kColorSyncProfileUserScope' type='^{__CFString=}'/>
    <function name='CGDisplayCreateUUIDFromDisplayID'>
    <arg type='I'/>
    <retval already_retained='true' type='^{__CFUUID=}'/>
    </function>
    <function name='ColorSyncDeviceCopyDeviceInfo'>
    <arg type='^{__CFString=}'/>
    <arg type='^{__CFUUID=}'/>
    <retval already_retained='true' type='^{__CFDictionary=}'/>
    </function>
    <function name='ColorSyncDeviceSetCustomProfiles'>
    <arg type='^{__CFString=}'/>
    <arg type='^{__CFUUID=}'/>
    <arg type='^{__CFDictionary=}'/>
    <retval type='B'/>
    </function>
    <function name='ColorSyncProfileCreateWithURL'>
    <arg type='^{__CFURL=}'/>
    <arg type='^^{_CFError}' type_modifier='o'/>
    <retval already_retained='true' type='^{ColorSyncProfile=}'/>
    </function>
    <function name='ColorSyncProfileVerify'>
    <arg type='^{ColorSyncProfile=}'/>
    <arg type='^^{_CFError}' type_modifier='o'/>
    <arg type='^^{_CFError}' type_modifier='o'/>
    <retval type='B'/>
    </function>
</signatures>
""", globals(), '/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/ColorSync.framework')


def errorExit(msg, code=1):
    print >> sys.stderr, msg
    exit(code)


def verify_profile(profile_url):
    # objc still doesn't seem to know about the CFErrorRefs below
    profile, create_err = ColorSyncProfileCreateWithURL(profile_url, None)
    usable, errors, warnings = ColorSyncProfileVerify(profile, None, None)

    if errors:
        print >> sys.stderr, "Errors verifying profile:"
        print >> sys.stderr, errors
    if warnings:
        print >> sys.stderr, "Warnings verifying profile:"
        print >> sys.stderr, warnings
    if not usable:
        errorExit("Profile could not be verified!")


def main():
    possible_actions = {
        "current-path": "Print path of current custom profile for device, if any",
        "displays": "List online displays and their associated numbers",
        "info": "Print out dictionary of device info",
        "set": "Set custom profile for device",
        "unset": "Unset custom profile for device",
    }
    possible_user_scopes = ["any", "current"]
    default_user_scope = 'current'

    usage = """%s <action> [options] [/path/to/profile]

Available actions:
""" % (os.path.basename(__file__))
    for k, v in possible_actions.items():
        usage += "    {:<20}{}\n".format(k, v)

    o = optparse.OptionParser(usage=usage)
    o.add_option('-d', '--display', type='int', default=1,
        help="Display number to target the action given. A value of '1' "
             "is the default, and means the main display. Second display "
             "is '2', etc. Verify the numbers using the 'displays' action.")
    o.add_option('-u', '--user-scope', default=default_user_scope,
        help="User scope in which to apply the custom profile, when used with the "
             "'set' action. Either 'any' or 'current'. 'any' requires "
             "root privileges. Defaults to %s."
             % (default_user_scope))
    opts, args = o.parse_args()

    if len(args) == 0:
        o.print_help()
        exit(1)

    if opts.user_scope:
        if opts.user_scope not in possible_user_scopes:
            errorExit("--user-scope must be one of: %s" % ", ".join(possible_user_scopes))
        if opts.user_scope == 'any' and os.getuid() != 0:
            errorExit("You must have root privileges to modify the any-user scope!")

    if args[0] not in possible_actions.keys():
        o.print_help()
        exit(1)

    chosen_action = args[0]

    max_displays = 8
    # display list retrieval borrowed from Greg Neagle's mirrortool.py
    # https://gist.github.com/gregneagle/5722568
    (err, display_ids, 
     number_of_online_displays) = Quartz.CGGetOnlineDisplayList(
                                                    max_displays, None, None)
    if err:
        errorExit("Error in obtaining online display list: %s" % err)

    # validate --display option
    invalid_display_id = False
    if opts.display <= 0:
        invalid_display_id = True
        invalid_msg = "Display IDs start at 1."

    if opts.display > number_of_online_displays:
        invalid_display_id = True
        if number_of_online_displays == 1:
            invalid_msg = "There is only one display online."
        else:
            invalid_msg = "There are only %s displays online." % number_of_online_displays

    if invalid_display_id:
        msg = "--display %s is not valid. " % opts.display
        msg += invalid_msg
        errorExit(msg)

    # Some logic to ensure the first display is always the main one, but
    # might confuse things if >2 displays connected.
    # main_display_id = Quartz.CGMainDisplayID()
    # if number_of_online_displays == 2:
    #     # main display always seems to be the first ID, but in the opposite
    #     # case, swap them so it's the first
    #     if display_ids[1] == main_display_id:
    #         temp = display_ids[0]
    #         display_ids[0] = main_display_id
    #         display_ids[1] = temp

    displays = []
    for index, display_id in enumerate(display_ids):
        display = {}
        display['id'] = display_id
        display['human_id'] = index + 1
        display['device_info'] = ColorSyncDeviceCopyDeviceInfo(
            kColorSyncDisplayDeviceClass, CGDisplayCreateUUIDFromDisplayID(display_id))
        displays.append(display)

    target_display = displays[opts.display - 1]

    if chosen_action == 'displays':
        for display in displays:
            print "%s: %s" % (display['human_id'], display['device_info']['DeviceDescription'])

    if chosen_action == "current-path":
        if 'CustomProfiles' in target_display['device_info'].keys():
            current_profile_url = target_display['device_info']['CustomProfiles']['1']
            print Foundation.CFURLCopyFileSystemPath(current_profile_url, Foundation.kCFURLPOSIXPathStyle)

    if chosen_action == "info":
        pprint(target_display['device_info'])

    if chosen_action in ["set", "unset"]:
        if chosen_action == "unset":
            profile_url = Foundation.kCFNull
        else:
            if len(args) < 2:
                errorExit("The 'set' action requires a path to an ICC profile as an argument.")
            profile_path = args[1]
            if not os.path.exists(profile_path):
                sys.exit("Can't locate profile at path %s!" % profile_path)
            if os.path.isdir(profile_path):
                errorExit("%s is a directory, not a profile!")
            profile_url = Foundation.CFURLCreateFromFileSystemRepresentation(None, profile_path, len(profile_path), False)
            verify_profile(profile_url)

        user_scope = eval('Foundation.kCFPreferences%sUser' % opts.user_scope.capitalize())

        # info on config dict required:
        # /System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/ColorSync.framework/Versions/A/Headers/ColorSyncDevice.h
        # http://web.archiveorange.com/archive/print/YwdQZYJTswvvG79VTuyD
        new_profile_dict = { kColorSyncDeviceDefaultProfileID: profile_url,
                             kColorSyncProfileUserScope: user_scope }

        success = ColorSyncDeviceSetCustomProfiles(
                    kColorSyncDisplayDeviceClass,
                    target_display['device_info']['DeviceID'],
                    new_profile_dict)
        if not success:
            errorExit("Setting custom profile was unsuccessful!")

if __name__ == '__main__':
    main()
