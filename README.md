# hashbang-os #

<http://github.com/hashbang/os>

## About ##

This is an effort to produce an AOSP based Android ROM with only the minimum
binary blobs in order for all hardware to function.

Additionally, we seek to produce signed deterministic builds allowing for high
accountability via redundant CI systems all getting the same hash.

Heavily inspired by CopperheadOS (RIP) and its spiritual successor
RattlesnakeOS with a focus on providing a trustable path to free public AOSP
builds.

## Features ##

 * 100% Open Source and auditable
  * Except for vendor driver blobs hash verified from Google Servers
 * All hardware works
  * Unless you use Sprint directly or via Fi, which requires [backdoors][1]
 * No changes to stock AOSP functionality
 * Built-in F-Droid
  * Trusted as system app without need to enable "Unknown Sources"

[1]: https://gist.github.com/thestinger/171b5ffdc54a50ee44497028aa137ed8

## Devices ##

  * crosshatch (Pixel 3 XL)

## Development ##

### Requirements ###

 * Linux host system
 * Docker
 * x86_64 CPU
 * 10GB+ available memory
 * 60GB+ disk

### Edit ###

```
make shell
```

### Patch ###
```
make diff > patches/my-feature.patch
```

### Update ###

Update to latest manifests for desired device:
```
make DEVICE=crosshatch update
```

### Build ###

Build images for desired device:
```
make DEVICE=crosshatch
```

### Flash ###

Reboot device into Fastboot mode.

```
make install
```

## Notes ##

Use at your own risk. You might be eaten by a grue.
