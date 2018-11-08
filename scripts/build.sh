#!/bin/bash
set -e
cd "$HOME"

driver_version=pd1a.180720.030
declare -A driver_sha256=(
    ["google_devices"]="22086d86287320ce7469d88b1378a6028fae1c1e0f8b72c35e4efcaef6d2a682"
    ["qcom"]="22086d86287320ce7469d88b1378a6028fae1c1e0f8b72c35e4efcaef6d2a682"
)
declare -A driver_crc=(
    ["google_devices"]="d85db144"
    ["qcom"]="bf86f269"
)
device="$RELEASE"
manifest="https://android.googlesource.com/platform/manifest"
drivers=( google_devices qcom )
mirror="https://dl.google.com/dl/android/aosp"

temp_dir="$(mktemp -d)"
download_dir="${temp_dir}/downloads/"
release_dir="$HOME/android/"

function sha256() { openssl sha256 "$@" | awk '{print $2}'; }

cores=$(grep -c ^processor /proc/cpuinfo)

mkdir -p "${download_dir}" "${release_dir}"

for driver in "${drivers[@]}"; do
	file="${driver}-${device}-${driver_version}-${driver_crc[$driver]}.tgz"
	if [ ! -f "${release_dir}/${file}" ]; then
		wget "${mirror}/${file}" -O "${download_dir}/${file}"
		file_hash="$(sha256 "${download_dir}/${file}")"
		echo "$file_hash"
		[[ "${driver_sha256[${driver}]}" == "$file_hash" ]] || \
			{ ( >&2 echo "Invalid hash for ${file}"); exit 1; }
		mv "${download_dir}/${file}" "${release_dir}/${file}"
	fi
	tar -xvf "${release_dir}/${file}" -C "${release_dir}"
	tail -n +315 "${release_dir}/extract-${driver}-${device}.sh" \
		| tar -xzv -C "${release_dir}"
done

git config --global user.email "staff@hashbang.sh"
git config --global user.name "Hashbang Staff"
git config --global color.ui false

repo --no-pager --color=auto init -u "${manifest}"
repo sync -j"${cores}"

source build/envsetup.sh

lunch "aosp_${device}-userdebug"
make -j"${cores}"
