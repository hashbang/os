#!/bin/bash
set -e
device="${DEVICE?}"
build_type="${BUILD_TYPE?}"
build_variant="${BUILD_VARIANT?}"
manifest_branch="${MANIFEST_BRANCH?}"
driver_build="${DRIVER_BUILD?}"
kernel_name="${KERNEL_NAME?}"
kernel_ref="${KERNEL_REF?}"
kernel_defconfig="${KERNEL_DEFCONFIG?}"
kernel_build="${KERNEL_BUILD:-true}"
gcc_version="${GCC_VERSION?}"
drivers=( google_devices qcom )
manifest_url="https://android.googlesource.com/platform/manifest"
driver_url="https://dl.google.com/dl/android/aosp"
kernel_url="https://android.googlesource.com/kernel/${kernel_name}"
temp_dir="$(mktemp -d)"
download_dir="${temp_dir}/downloads/"
build_dir="$PWD"
cores=$(nproc)

declare -A driver_sha256=(
    ["google_devices"]="${DRIVER_SHA256_GOOGLE?}"
    ["qcom"]="${DRIVER_SHA256_QCOM?}"
)
declare -A driver_crc=(
    ["google_devices"]="${DRIVER_CRC_GOOGLE?}"
    ["qcom"]="${DRIVER_CRC_QCOM?}"
)

function sha256() { openssl sha256 "$@" | awk '{print $2}'; }

cd "${build_dir}"

# Setup Git
git config --global user.email "staff@hashbang.sh"
git config --global user.name "Hashbang Staff"
git config --global color.ui false

# Sync repos
repo init -u "$manifest_url" -b "$manifest_branch" --depth 1
repo sync -c --no-tags --no-clone-bundle --jobs "${cores}"

# Fetch driver blobs
mkdir -p "${download_dir}" "${build_dir}"
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

# Setup enviornment
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
		if [ ! -d "kernel/${kernel_name}" ]; then
			mkdir -p "kernel/${kernel_name}"
			git clone "${kernel_url}" "kernel/${kernel_name}"
		fi
		cd "kernel/${kernel_name}"
		git pull origin "${kernel_ref}"
		git checkout "${kernel_ref}"
		make "${kernel_defconfig}_defconfig"
		make -j "${cores}"
		cd -
		cp "kernel/arch/arm64/boot/dtbo.img" "device/google/${device}-kernel/"
		cp "kernel/arch/arm64/boot/Image.lz4-dtb" "device/google/${device}-kernel/"
	EOF
fi

# Build flashable image
make -j "${cores}" target-files-package

# Build OTA Update
make -j "${cores}" brillo_update_payload
