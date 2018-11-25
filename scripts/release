#!/bin/bash
# shellcheck disable=SC1091,SC1090
set -e

device="${DEVICE?}"
base_dir="$PWD/base"
build_number="$(cat "${base_dir}"/out/build_number.txt 2>/dev/null)"
version=$(
	grep -Po "export BUILD_ID=\\K.+" "${base_dir}/build/core/build_id.mk" \
	| tr '[:upper:]' '[:lower:]' \
)
target_files="${device}-target_files-${build_number}.zip"
prefix=aosp
key_dir="${KEY_DIR:-${PWD}/keys/${device}}"
release_dir="$PWD/release/${device}/${build_number}"
target_out_dir="${base_dir}/out/target/product/${device}"
inter_dir="${target_out_dir}/obj/PACKAGING/target_files_intermediates"

source "${base_dir}/build/envsetup.sh"
source "${base_dir}/device/common/clear-factory-images-variables.sh"

export LANG=C
export _JAVA_OPTIONS=-XX:-UsePerfData
export DISPLAY_BUILD_NUMBER=true
export BUILD_NUMBER="$build_number"
export PATH="${base_dir}/build/tools/releasetools:$PATH"

mkdir -p "$release_dir"
cd "$base_dir"

echo "Running sign_target_files_apks"
sign_target_files_apks \
	-o \
	-d "$key_dir" \
	--avb_vbmeta_key "${key_dir}/avb.pem" \
    --avb_vbmeta_algorithm SHA256_RSA2048 \
    --avb_system_key "${key_dir}/avb.pem" \
    --avb_system_algorithm SHA256_RSA2048 \
  	"${inter_dir}/${prefix}_${device}-target_files-${build_number}.zip" \
	"$release_dir/$target_files"

echo "Running ota_from_target_files"
ota_from_target_files \
	--block \
	-k "${key_dir}/releasekey" \
  	"${release_dir}/${target_files}" \
    "${release_dir}/${device}-ota_update-${build_number}.zip"

echo "Running img_from_target_files"
img_from_target_files \
	"${release_dir}/${target_files}" \
	"${release_dir}/${device}-img-${build_number}.zip"

echo "Running generate-factory-images"
cd "$release_dir"
source "${base_dir}/device/common/generate-factory-images-common.sh"
mv "${device}-${version}-factory.tar" "${device}-factory-${build_number}.tar"
rm -f "${device}-factory-${build_number}.tar.xz"

echo "Running compress of factory image with pxz"
time pxz -v -T0 -9 -z "${device}-factory-${build_number}.tar"
