# customdisplayprofiles

This is a simple command-line Python script that can check, set or unset a custom ColorSync ICC profile for a given display. It uses PyObjC and the most current (as of 2013) ColorSync API to do this.

## Installation

You can either **(1)** download a pre-compiled executable, or **(2)** execute the script directly with a Python runtime you have available.

### 1. Pre-compiled executable

Download the latest version from the [Releases](https://github.com/timsutton/customdisplayprofiles/releases/latest) section, make the file executable and run it. The executable contains the necessary runtime and libraries, bundled via [PyInstaller](https://pyinstaller.org/).

### 2. Execute the script directly

Clone or download this repo (or just the single `customdisplayprofiles` script) and execute it directly. You'll also need to have the [PyObjC PyPi package](https://pypi.org/project/pyobjc/) installed and available in your Python runtime's environment:

`pip3 install pyobjc`


## Usage

### Setting a profile

Use the `set` action to set a profile (as the user running the command) for the main display.

`customdisplayprofiles set /path/to/profile.icc`

Use the `--display` option to configure an alternate display.

`customdisplayprofiles set --display 2 /path/to/profile.icc`

If you want to get a list of displays with their associated index:

`customdisplayprofiles displays`


### Configurable user scope

The `--user-scope` option allows you to define whether the profile will be applied to the "Current" or "Any" user domain, which may allow you set this preference as a default for all users:

`customdisplayprofiles set --user-scope any /path/to/profile.icc`

Specifying `any` here requires root privileges, as it will write these preferences to a system-owned location.

More information on the user preferences system on OS X can be found [here](https://developer.apple.com/library/mac/#documentation/userexperience/Conceptual/PreferencePanes/Concepts/Managing.html) and [here](http://developer.apple.com/library/ios/#DOCUMENTATION/MacOSX/Conceptual/BPRuntimeConfig/Articles/UserPreferences.html).


### Retrieving the current profile

The full path to an ICC profile can be printed to stdout:

`customdisplayprofiles current-path`

This could be useful if you want to check the current setting using an idempotent login script or a configuration framework like Puppet.

`current-path` will output nothing if there is no profile currently set for that display.


### Full details

A more complete dictionary of information can be printed with the `info` action:

<pre><code>➜ ./customdisplayprofiles info
{
    CustomProfiles =     {
        1 = "file://localhost/Library/Application%20Support/Adobe/Color/Profiles/SMPTE-C.icc";
    };
    DeviceClass = mntr;
    DeviceDescription = iMac;
    DeviceHostScope = kCFPreferencesCurrentHost;
    DeviceID = "<CFUUID 0x7fb6204abea0> 00000610-0000-B005-0000-0000042C0140";
    DeviceUserScope = kCFPreferencesAnyUser;
    FactoryProfiles =     {
        1 =         {
            DeviceModeDescription = iMac;
            DeviceProfileURL = "file://localhost/Library/ColorSync/Profiles/Displays/iMac-00000610-0000-B005-0000-0000042C0140.icc";
        };
        DeviceDefaultProfileID = 1;
    };
}
</pre></code>


## Sample wrapper script

There's a (very simple) example script in the [sample-helper-login-script](https://github.com/timsutton/customdisplayprofiles/blob/master/sample-helper-login-script/configure_display_profiles.sh) folder, which demonstrates how you could wrap this utility in an environment where you don't manage the ICC profiles directly. Someone calibrating a display would only need to drop the profile in a known folder location, indexed by display number, and at login for all users, the desired color profiles are configured for each online display.


## Building a pkg

You might want to build a pkg to deploy the script to one or more Macs in your environment. To create a pkg so, you can run the `make` command in the repo folder. 
The included Makefile will be used to create a package which will install `customdisplayprofiles` in `/usr/local/bin`
If you'd like to install the script at a different path, you can override the default when creating the package with  
`make INSTALLPATH=/path/to/installfolder`

If you're also using munki, there's a `make munki` command to import the package into your munki repository.

```
# first run make to create the pkg
make

# Then, import the package into munki
make MUNKI_REPO_SUBDIR=util munki
```
