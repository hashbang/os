# #!os #

<http://github.com/hashbang/os>

## About ##

This is an effort to produce an AOSP based Android ROM with only the minimum
binary blobs in order for all hardware to function.

Additionally, we seek to produce signed deterministic builds allowing for high
accountability via redundant CI systems all getting the same hash.

Heavily inspired by the former CopperheadOS (RIP) project. We seek to provide a
trustable path to free public AOSP builds patched for privacy and security.

Additionally, this build system is intended to make it easy to build, sign
and publish your own custom AOSP rom from patches/configs/branding as you see
fit.

A common build system/strategy for vanilla AOSP and AOSP forks also makes it
easy to change between them as you see fit while still controlling your own
keys making debugging and comparisons easier.

## Status ##

Public releases are pending sustainable/automated CI/CD work to do reproducible
builds and multisig.

Testing is currently manual. "True" implies only all hardware and surface level
functionality appears to work. E2E testing integration is WIP

Testers, builders, and hosting bandwidth needed.

## Support ##

Please join us on IRC: ircs://irc.hashbang.sh/#!os

## Features ##

### Current

 * 100% Open Source and auditable
   * Except for mandatory vendor blobs hash verified from Google Servers
 * Minimal changes to stock AOSP functionality
 * Automated build system:
   * Completely run inside Docker for portability
   * Customize builds from central config file.
   * Automatically pin hashes from upstreams for reproducibility
   * Automated patching/inclusion of upstream Android Sources
 * Removed:
   * Google Play Services
   * Proprietary system apps
   * OMA-DM [backdoors][1]
   * Browser2 - Mostly unmaintained
   * Webview - Mostly unmaintained
   * Calendar - Mostly unmaintained
   * Quicksearch - Requires Google Play Services. Also removed from Launcher.
 * Added:
   * Custom Android Verified Boot included in factory images
   * F-Droid - Trusted as system app without need to enable "Unknown Sources"
   * Chromium - With several privacy/security patches
   * [Backup][2] - Minor OS changes made to allow backing up any app
   * [Updater][3] - Patched to use os.hashbang.sh update server

[1]: https://gist.github.com/thestinger/171b5ffdc54a50ee44497028aa137ed8
[2]: https://github.com/stevesoltys/backup
[3]: https://github.com/AndroidHardening/platform_packages_apps_Updater

### Future

 1. Reproducible builds
    * Allow third parties to prove a build came from expected open source code.
 2. Verified Builds
    * Test builds signed with test keys are automated and used for verification.
    * Third party verifiers will maintain webhook activated build nodes
      * Will be in different legal jurisdictions
      * should have a public reputation to lose if they tamper a build
      * can offer mirrors signed with their own keys
      * will publish signatures for test builds to be in 'verified' channel
    * Updater app will verify signatures from m-of-n builders (e.g 2 of 3)
    * Ability to build/sign/update own releases via Terraform automation
 3. Compatibility Test Suite
    * Every device should have a sponsor with an automated CTS test station
 4. Hardening
    * Test and integrate [Android Hardening Project][5] patches
      * Hardened Memory Allocator
      * Chromium security/privacy patches
      * Various platform patches for better permissions controls
    * BadUSB
      * Setup global settings option to toggle USB OTG support
      * Disable all USB devices by default
    * Allow build options to disable hardware as needed for airgap setups.
 5. Remote Attestation
    * Auditor app integration
      * -if- @thestinger can be convinced to open source it
      * He is seeking compensation for his time creating it. [Make An Offer][6]
 6. Two Factor Authentication
    * Replace proprietary Google Play Services U2F with open/auditable one.
 7. Accessibility
    * Global Dark Mode
    * One Handed Mode
 8. Fluff
    * Wallpaper/boot animation
    * Support channel link on home screen
    * Support flashing from windows for confused people we take pity on

[5]: https://github.com/AndroidHardening
[6]: mailto:danielmicay@gmail.com

## Devices ##

  | Device      | Codename   | Tested | Verifiable | Secure Boot | Download |
  |-------------|:----------:|:------:|:----------:|:-----------:|:--------:|
  | Pixel 3a XL | Bonito     | FALSE  | FALSE      | AVB 2.0     | Soon™    |
  | Pixel 3a    | Sargo      | FALSE  | FALSE      | AVB 2.0     | Soon™    |
  | Pixel 3 XL  | Crosshatch | TRUE   | FALSE      | AVB 2.0     | Soon™    |
  | Pixel 3     | Blueline   | FALSE  | FALSE      | AVB 2.0     | Soon™    |
  | Pixel 2 XL  | Taimen     | TRUE   | FALSE      | AVB 1.0     | Soon™    |
  | Pixel 2     | Walleye    | FALSE  | FALSE      | AVB 1.0     | Soon™    |
  | Pixel XL    | Marlin     | FALSE  | FALSE      | dm-verity   | Soon™    |
  | Pixel       | Sailfish   | FALSE  | FALSE      | dm-verity   | Soon™    |

  Release hosting is sponsored by [JFrog](https://www.jfrog.com/)

## Install ##

### Requirements ###

 * OSX/Linux host system
 * [Android Developer Tools][4]

[4]: https://developer.android.com/studio/releases/platform-tools


### Steps

1. Extract

```
unzip crosshatch-PQ1A.181205.006-factory-1947dcec.zip
cd crosshatch-PQ1A.181205.006/
```

1. Unlock the bootloader.

NOTE: You'll have to be in developer mode and enable OEM unlocking

```
adb reboot bootloader
fastboot flashing unlock
```

2. Reboot into fastboot

Once the bootloader is unlocked it will wipe the phone and you'll have to do
basic setup to be able to drop into fastboot. You can skip everything since
you'll be starting from scratch again after flashing #!OS

Reboot phone into the fastboot bootloader.

```
adb reboot bootloader
```

3. Run Flashing script

```
./flash-all.sh
```

## Building ##

### Requirements ###

 * Linux host system
 * Docker
 * x86_64 CPU
 * 10GB+ available memory
 * 250GB+ free disk space

### Generate Signing Keys ###

Each device needs its own set of keys:
```
make DEVICE=crosshatch keys
```

### Build Factory Image ###

Build flashable images for desired device:
```
make DEVICE=crosshatch clean build release
```

## Develop ##


### clean ###

Do basic cleaning without deleting cached artifacts/sources:
```
make clean
```

Clean everything but keys
```
make mrproper
```

### Compare ###

Build a given device twice from scratch and compare with diffoscope:
```
make shell
```

### Edit ###

Create a shell inside the docker environment:
```
make shell
```

### Patch ###

Output all untracked changes in android sources to a patchfile:
```
make diff > patches/my-feature.patch
```

### Flash ###
```
adb reboot fastboot
make install
```

## Release ##

WIP

### Update ###

Build latest config from upstream sources:

```
make config
```


## Questions ##

### Who is this project for?

Individuals that desire a device that favors privacy and security over easy
access to proprietary software and services.

### Wait can I not run -Insert-App-Here-

You technically can download/install most apps in the Play store but we of
course can't recommend that. Some apps that have a hard requirement on Google
Play Services can be tricked with [MicroG][mg] but this increases attack
surface and though it will probably work in many cases, this is not supported
or recommended.

Yalp store is an open source browser for Google Play Store and is available
on F-Droid.

Also see "Alternatives" below to find alternatives for popular apps.

### Why is -Insert-Device-Here- not supported?

Most vendors don't release sources and tooling to reproduce their builds or do
so with substantial delays. Many vendors even disable critical security
features they don't understand and allow various Supply Chain Attacks. These
are a headache to reverse engineer, test, audit, patch, and generally maintain.

Unless a vendor decides to produce source repos with at least the quality of
AOSP we will only support AOSP supported devices which today means the Pixel
series of mobile handsets.

Pixel devices start at $100-200 and we will try to maintain support for at
least one device at this price point to keep the project accessible.

### Why not use LineageOS, AOKP, or insert-project-here?

As of the time of this writing most popular ROMs are virtually unusable
without Google Play Services and the proprietary parts of android. They also
tend to make changes that make taking upstream source code time consuming thus
often delaying security updates.

Secondly virtually all roms sign using "test" keys, leaving all of them
vulnerable to Evil Maid Attacks and thus worse-off security wise than stock
Android.

Third, builds are almost never easily reproducible if at all meaning that a
single coerced maintainer could slip in a subtle flaw without very little
chance of detection

Lastly, they almost all source binaries from sketchy locations like the
infamous "[TheMuppets][tm]" repo which an unknown number of people have push
access to. This sort of activity acts as a security SPOF for popular roms.

### Why should anyone trust this project?

Trust, but Verify. While we may be upstanding people today, we might be
coerced tomorrow by a state actor that wants access to the device in your
pocket. You can run our reproducible build systems yourself and sound the
alarm if the builds we produce don't line up with the published source code.

The more people that verify, the less reason a bad actor has to try to attack
maintainers. Maintaining a system that requires zero trust on the maintainers
is a core part of our plan to be resistant to Australia-style strongarm
backdoor requests.

[tm]: https://github.com/TheMuppets

## Alternatives ##

Giving up Google Play services and stock proprietary applications is a big ask
for a lot of people that have grown to rely on particular apps for their
lifestyle.

To address this consider looking at some of the below alternatives for popular
applications.

Some things won't have alternatives and in those cases you will have to decide
to sideload a specific proprietary APK via Yalp Store or live without that app.

You may also find popular travel apps like Kayak, Uber ans Lyft have very
usable mobile webapps you can pin to your desktop for a similar experience to a
native app.

| App      | Alternative(s)   | Notes                                  |
|:--------:|:----------------:|:---------------------------------------|
| Chrome   | Chromium, OrFox  | Chromium is built-in to #!os           |
| Play     | F-Droid, Yalp    | F-Droid is built-in to #!oa            |
| GMail    | K9Mail           |                                        |
| Drive    | Nextcloud        |                                        |
| Music    | D-Sub            | Will need a Subsonic capable server    |
| Maps     | OsmAnd~          |                                        |
| Auth.    | Yubico Auth.     |                                        |
| Hangouts | Weechat, Riot.im |                                        |
| Voice    | Ring             |                                        |
| Youtube  | NewPipe, SkyTube |                                        |

## Notes ##

Use at your own risk. You might be eaten by a grue.
