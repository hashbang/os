#!/bin/bash

cd "$HOME/base" || exit
rm -rf device/google/*-kernel
repo forall -c 'git reset --hard ; git clean -fdx'
make clean

cd "$HOME/kernel" || exit
mapfile -t -d '' dirs < <(find . -type d -print0)
for dir in "${dirs[@]}"; do (
	cd "$dir" || exit;
	repo forall -c 'git reset --hard ; git clean -fdx';
	make clean
) done
