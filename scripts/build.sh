#!/bin/bash
set -e
cd $HOME

driver_version=pd1a.180720.030
declare -A driver_sha256=(
    ["google_devices"]="43834afa6c28e342ad5d57616748dff92eab1dca5aa873ada104f37512a4b1c0"
    ["qcom"]="b714836b7255b25b1ccfce9fe0820c348b4e07f44a536edce5763cd6de684fa6"
)
declare -A driver_crc=(
    ["google_devices"]="c47f3403"
    ["qcom"]="e30f765a"
)
device="$RELEASE"
manifest="https://android.googlesource.com/platform/manifest"
drivers=( google_devices qcom )
mirror="https://dl.google.com/dl/android/aosp"

temp_dir="$(mktemp -d)"
download_dir="${temp_dir}/downloads/"
release_dir="$HOME/android/"

function sha256() { openssl sha256 "$@" | awk '{print $2}'; }

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
	cat "${release_dir}/extract-${driver}-${device}.sh" \
		| tail -n +315 \
		| tar -xzv -C "${release_dir}"
done

git config --global user.email "staff@hashbang.sh"
git config --global user.name "Hashbang Staff"
git config --global color.ui false

repo --no-pager --color=auto init -u "${manifest}"
repo sync -j24

source build/envsetup.sh

lunch "aosp_${device}-userdebug"
make -j32
