#!/bin/bash
set -e
cd "$HOME"

device="${DEVICE?}"
build_type="${BUILD_TYPE:-release}"
build_variant="${BUILD_VARIANT:-user}"

# shellcheck disable=SC1091
source build/envsetup.sh
choosecombo "${build_type}" "aosp_${device}" "${build_variant}"

fastboot devices
fastboot flashall -w
