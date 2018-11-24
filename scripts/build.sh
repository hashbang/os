#!/bin/bash
set -e
device="${DEVICE?}"
build_type="${BUILD_TYPE:-release}"
build_variant="${BUILD_VARIANT:-user}"
driver_build="${DRIVER_BUILD?}"
kernel_build="${KERNEL_BUILD:-true}"
maintainer_name="${MAINTAINER_NAME:-aosp@null.com}"
maintainer_email="${MAINTAINER_EMAIL:-AOSP User}"
temp_dir="$(mktemp -d)"
download_dir="${temp_dir}/downloads/"
base_dir="$PWD/base"
kernel_dir="$PWD/kernel"
driver_dir="$PWD/drivers"
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

function sha256() { sha256sum "$@" | cut -c -64; }

mkdir -p "${download_dir}" "${base_dir}" "${kernel_dir}" "${driver_dir}"

# Setup Git
git config --global user.email "${maintainer_email}"
git config --global user.name "${maintainer_name}"
git config --global color.ui false

# Sync/reset repos
cd "${base_dir}"
repo init -u "${config_dir}" -m manifests/base.xml
repo sync -c --no-tags --no-clone-bundle --jobs "${cores}"
repo forall -c 'git reset --hard ; git clean -fdx'

# Fetch/extract driver blobs
for driver in "${drivers[@]}"; do
	file="${driver}-${device}-${driver_build}-${driver_crc[$driver]}.tgz"
	if [ ! -f "${driver_dir}/${file}" ]; then
		wget "${driver_url}/${file}" -O "${download_dir}/${file}"
		file_hash="$(sha256 "${download_dir}/${file}")"
		[[ "${driver_sha256[${driver}]}" == "$file_hash" ]] || \
			{ ( >&2 echo "Invalid hash for ${file}"); exit 1; }
		mv "${download_dir}/${file}" "${driver_dir}/${file}"
	fi
	tar -xvf "${driver_dir}/${file}" -C "${temp_dir}"
	tail -n +315 "${temp_dir}/extract-${driver}-${device}.sh" \
		| tar -xzv -C "${base_dir}"
done

# Apply Patches
for type in {global,${build_variant}} ; do
	for patch in "${config_dir}"/patches/"${type}"/*.patch; do
		patch -p1 --no-backup-if-mismatch < "${patch}"
	done
done

# Build Kernel
if [ "$kernel_build" = true ]; then
	cat <<-EOF | bash
		cd "${kernel_dir}/${device}"
		repo init -u "${config_dir}" -m manifests/${device}/kernel.xml
		repo sync -c --no-tags --no-clone-bundle --jobs "${cores}"
		repo forall -c 'git reset --hard ; git clean -fdx'
		source build/envsetup.sh
		bash build/build.sh
		rm -rf ${base_dir}/device/google/${device}-kernel
		cp -R ${kernel_dir}/${device}/out/android-*/dist \
			${base_dir}/device/google/${device}-kernel
	EOF
fi

# Setup environment
# shellcheck disable=SC1091
source build/envsetup.sh
choosecombo "${build_type}" "aosp_${device}" "${build_variant}"

# Build tools
make -j "${cores}" \
	fastboot \
	dtc \
	mkdtimg \

# Build target files
make -j "${cores}" \
	target-files-package \
	brillo_update_payload
