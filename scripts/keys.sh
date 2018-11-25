#!/bin/bash

device="${DEVICE?}"
key_dir="${KEY_DIR:-${PWD}/keys/${device}}"
base_dir="$PWD/base"
cert_subject="${CERT_SUBJECT:-/CN=HashbangOS}"

[ ! -d "$key_dir" ] || {
	echo "Key directory already exists. Refusing to overwrite"; exit 1;
}
mkdir -p "$key_dir"
cd "$key_dir" || exit
export PATH="${base_dir}/development/tools:$PATH"
export PATH="${base_dir}/external/avb:$PATH"

for key in {releasekey,platform,shared,media,verity} ; do
	make_key "$key" "$cert_subject"
done

openssl genrsa -out avb.pem 2048
avbtool extract_public_key --key avb.pem --output avb_pkmd.bin
