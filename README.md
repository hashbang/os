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
   * Except for vendor driver blobs hash verified from Google Servers
 * All hardware works
   * Unless you use Sprint directly (or via Fi), which requires [backdoors][1]
 * No changes to stock AOSP functionality
 * Built-in F-Droid
   * Trusted as system app without need to enable "Unknown Sources"

[1]: https://gist.github.com/thestinger/171b5ffdc54a50ee44497028aa137ed8

## Devices ##

  | Device     | Codename   | Builds | Boots    | All H/W  | CTS      |
  |------------|:----------:|:------:|:--------:|:--------:|:--------:|
  | Pixel 3 XL | Crosshatch | TRUE   | TRUE     | TRUE     | Untested |
  | Pixel 3    | Blueline   | TRUE   | Untested | Untested | Untested |
  | Pixel 2 XL | Taimen     | FALSE  | Untested | Untested | Untested |
  | Pixel 2    | Walleye    | FALSE  | Untested | Untested | Untested |
  | Pixel XL   | Marlin     | FALSE  | Untested | Untested | Untested |
  | Pixel      | Sailfish   | FALSE  | Untested | Untested | Untested |

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
