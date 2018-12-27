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
  | Pixel XL   | Marlin     | Untested | Untested | FALSE         | Untested |
  | Pixel      | Sailfish   | Untested | Untested | FALSE         | Untested |

## Install ##

### Extract
```
unzip crosshatch-PQ1A.181205.006-factory-1947dcec.zip
cd crosshatch-PQ1A.181205.006/
```

### Flash
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

## Notes ##

Use at your own risk. You might be eaten by a grue.
