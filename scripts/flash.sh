#!/bin/bash
set -e
cd "$HOME"

device="${DEVICE?}"
build_type="${BUILD_TYPE?}"
build_variant="${BUILD_VARIANT?}"

# shellcheck disable=SC1091
source build/envsetup.sh
choosecombo "${build_type}" "aosp_${device}" "${build_variant}"

fastboot devices
fastboot flashall -w
