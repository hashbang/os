#!/bin/bash
set -e
device="${DEVICE?}"
build_type="${BUILD_TYPE?}"
build_variant="${BUILD_VARIANT?}"
driver_build="${DRIVER_BUILD?}"
kernel_defconfig="${KERNEL_DEFCONFIG?}"
kernel_build="${KERNEL_BUILD:-true}"
maintainer_name="${MAINTAINER_NAME:-aosp@null.com}"
maintainer_email="${MAINTAINER_EMAIL:-AOSP User}"
gcc_version="${GCC_VERSION:-4.9}"
key_dir="${KEY_DIR/:-build/make/tools/releasetools/testdata}"
temp_dir="$(mktemp -d)"
download_dir="${temp_dir}/downloads/"
build_dir="$PWD"
config_dir="/opt/android"
cores=$(nproc)
drivers=( google_devices qcom )
driver_url="https://dl.google.com/dl/android/aosp"
declare -A driver_sha256=(
    ["google_devices"]="${DRIVER_SHA256_GOOGLE?}"
    ["qcom"]="${DRIVER_SHA256_QCOM?}"
)
declare -A driver_crc=(
    ["google_devices"]="${DRIVER_CRC_GOOGLE?}"
    ["qcom"]="${DRIVER_CRC_QCOM?}"
)

function sha256() { openssl sha256 "$@" | cut -c -64; }

function key_hash(){ openssl x509 -in $1 -outform DER | sha256; }

cd "${build_dir}"

mkdir -p "${download_dir}" "${build_dir}"

# Setup Git
git config --global user.email "${maintainer_email}"
git config --global user.name "${maintainer_name}"
git config --global color.ui false

# Sync/reset repos
repo init -u "${config_dir}" -m manifest.xml
repo sync -c --no-tags --no-clone-bundle --jobs "${cores}"
repo forall -c 'git reset --hard ; git clean -fdx'

# Fetch driver blobs
for driver in "${drivers[@]}"; do
	file="${driver}-${device}-${driver_build}-${driver_crc[$driver]}.tgz"
	if [ ! -f "${build_dir}/${file}" ]; then
		wget "${driver_url}/${file}" -O "${download_dir}/${file}"
		file_hash="$(sha256 "${download_dir}/${file}")"
		echo "$file_hash"
		[[ "${driver_sha256[${driver}]}" == "$file_hash" ]] || \
			{ ( >&2 echo "Invalid hash for ${file}"); exit 1; }
		mv "${download_dir}/${file}" "${build_dir}/${file}"
	fi
	tar -xvf "${build_dir}/${file}" -C "${build_dir}"
	tail -n +315 "${build_dir}/extract-${driver}-${device}.sh" \
		| tar -xzv -C "${build_dir}"
done

# Apply Patches
for type in {global,${build_variant}} ; do
	for patch in "${config_dir}"/patches/"${type}"/*.patch; do
		patch -p1 --no-backup-if-mismatch < "${patch}"
	done
done

# Setup environment
# shellcheck disable=SC1091
source build/envsetup.sh
choosecombo "${build_type}" "aosp_${device}" "${build_variant}"

# Build tools
make -j "${cores}" fastboot
make -j "${cores}" dtc
make -j "${cores}" mkdtimg

# Build Kernel
if [ "$kernel_build" = true ]; then
	cat <<-EOF | bash
		export ARCH=arm64
		export CROSS_COMPILE="$PWD/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-${gcc_version}/bin/aarch64-linux-android-"
		cd "kernel/${device}"
		make "${kernel_defconfig}_defconfig"
		make -j "${cores}"
		cd -
		cp "kernel/${device}/kernel/arch/arm64/boot/dtbo.img" "device/google/${device}-kernel/"
		cp "kernel/${device}/kernel/arch/arm64/boot/Image.lz4-dtb" "device/google/${device}-kernel/"
	EOF
fi

# Build flashable image
make -j "${cores}" target-files-package

# Build OTA Update
make -j "${cores}" brillo_update_payload
