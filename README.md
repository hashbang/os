# hashbang-os #

<http://github.com/hashbang/os>

## About ##

!! - WIP - !!

This is an effort to produce an AOSP based Android ROM with only the minimum
binary blobs in order for all hardware to function.

Additionally, we seek to produce signed deterministic builds allowing for high
accountability via redundant CI systems all getting the same hash.

## Features ##

  * Minimal changes from AOSP.
  * Google Fi LTE, Bluetooth, Wifi all work as expected
  * Chromium as default browser
  * OMA Device management backdoors removed
  * Build-in F-Droid as Play Store alternative
  * No security shortcuts like disabling/crippling SELinux.
  * Google Apps and Play Services are not supported
  * Vendor blobs auto-extracted direct from Google Servers

## Dependencies ##

 * x86_64 CPU
 * 10GB+ available memory
 * 60GB+ disk
 * Docker

## Building ##

Build images for desired DEVICE:
```
docker run -v android:/home/build -e DEVICE="blueline" -it hashbang/os
```

## Installation ##

Reboot into Fastboot mode.

```
> fastboot -w flashall
```

## Notes ##

Use at your own risk. You might be eaten by a grue.
