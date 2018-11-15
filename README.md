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

  * Minimal changes from AOSP.
  * Google Fi LTE, Bluetooth, Wifi all work as expected
  * Chromium as default browser
  * OMA Device management backdoors removed
  * Build-in F-Droid as Play Store alternative
  * No security shortcuts like disabling/crippling SELinux.
  * Google Apps and Play Services are not supported
  * Vendor blobs auto-extracted direct from Google Servers

## Known Issues ##

  * Only Pixel 3 XL supported at this time
  * Builds not yet reproducible
  * Signing is not a thing yet
  * Touchscreen and most other drivers not working

## Requirements ##

 * A supported device
 * x86_64 CPU
 * 10GB+ available memory
 * 60GB+ disk
 * Docker

## Building ##

Create a volume for storing android sources and build artifacts:
```
docker volume create android
```

Build images for desired device:
```
docker run \
  -it \
  -v android:/home/build \
  -e "DEVICE=crosshatch" \
  --env-file config/crosshatch.env \
  hashbang/os
```

## Flashing ##

Reboot into Fastboot mode.

```
docker run \
  -it \
  --privileged \
  -u root \
  -v android:/home/build \
  --env-file=configs/crosshatch.env \
  hashbang/os flash.sh
```

## Notes ##

Use at your own risk. You might be eaten by a grue.
