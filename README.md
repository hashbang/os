# hashbang-os #

<http://github.com/hashbang/os>

## About ##

This is an effort to produce an AOSP based Android ROM with only the minimum
binary blobs in order for all hardware to function.

Additionally, we seek to produce signed deterministic builds allowing for high
accountability via redundant CI systems all getting the same hash.

Heavily inspired by the former CopperheadOS (RIP) project. We seek to provide a
trustable path to free public AOSP builds patched for privacy and security.

## Features ##

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

## Devices ##

  | Device     | Codename   | Boots    | All H/W  | Reproducible  | CTS      |
  |------------|:----------:|:--------:|:--------:|:-------------:|:--------:|
  | Pixel 3 XL | Crosshatch | TRUE     | TRUE     | FALSE         | Untested |
  | Pixel 3    | Blueline   | Untested | Untested | FALSE         | Untested |
  | Pixel 2 XL | Taimen     | TRUE     | TRUE     | FALSE         | Untested |
  | Pixel 2    | Walleye    | Untested | Untested | FALSE         | Untested |
  | Pixel XL   | Marlin     | TRUE     | TRUE     | FALSE         | Untested |
  | Pixel      | Sailfish   | Untested | Untested | FALSE         | Untested |

## Install ##

### Requirements ###

 * OSX/Linux host system
 * [Android Developer Tools][4]

[4]: https://developer.android.com/studio/releases/platform-tools

### Extract
```
unzip crosshatch-PQ1A.181205.006-factory-1947dcec.zip
cd crosshatch-PQ1A.181205.006/
```

### Flash

Unlock the bootloader.

NOTE: You'll have to be in developer mode and enable OEM unlocking

```
adb reboot bootloader
fastboot flashing unlock
```

Once the bootloader is unlocked it will wipe the phone and you'll have to do
basic setup to be able to drop into fastboot. You can skip everything since
you'll be starting from scratch again after flashing #!OS

Reboot phone in fastboot and flash

#### Pixel

```
adb reboot bootloader
./flash-all.sh
```

#### Pixel 2+

```
adb reboot fastboot
./flash-all.sh
```

## Building ##

### Requirements ###

 * Linux host system
 * Docker
 * x86_64 CPU
 * 10GB+ available memory
 * 60GB+ disk

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

### Update ###

Build latest manifests/config from upstream sources:

```
make DEVICE=crosshatch config manifest
```

### Edit ###
```
make shell
```

### Patch ###
```
make diff > patches/my-feature.patch
```

### Flash ###
```
adb reboot fastboot
make install
```

### Manually Flashing OTAs ###
If you're working on a new feature and want to apply it to just your phone for
testing.

```
cd <release directory>
mv <device>-ota_update-<date>.zip ota.zip
adb reboot recovery
adb sideload ota.zip
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

### Why not use LineageOS, AOKP, or insert-project-here ?

As of the time of this writing most popular ROMs are virtually unusuable
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

To address this consider looking at some of the below alternatives for for
popular applications.

Some things won't have alternatives and in those cases you will have to decide
to sideload a specific proprietary APK via Yalp Store or live without that app.

You may also find popular travel apps like Kayak, Uber ans Lyft have very
usable mobile webapps you can pin to your desktop for a similar experience to a
native app.

| Proprietary App | Alternative(s)   | Notes                                  |
|:---------------:|:----------------:|:---------------------------------------|
| Play Store      | F-Droid          | Only supports Open Source applications |
| Chrome          | Chromium         | Built-in to #!os                       |
| Google Music    | D-Sub            | Will need a Subsonic capable server    |
| Google Maps     | OsmAnd~          |                                        |
| Google Auth.    | Yubico Auth.     |                                        |
| Youtube         | NewPipe, SkyTube |                                        |
| Drive           | Nextcloud        |                                        |
| Hangouts        | Weechat, Riot.im |                                        |
| Voice           | Ring             |                                        |

## Notes ##

Use at your own risk. You might be eaten by a grue.
