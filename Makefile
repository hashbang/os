include aosp-build/Makefile

NAME := hashbangos-$(FLAVOR)-$(BACKEND)

contain-base-extend = \
		--volume $(PWD)/aosp-build/scripts:/opt/aosp-build/scripts \
		--volume $(PWD)/aosp-build/config:/opt/aosp-build/config \
		--volume $(PWD)/aosp-build/config/manifests:/home/build/config/manifests-aosp

.PHONY: HashbangMobile-setup
HashbangMobile-setup:
	cd aosp-build/ && ln -sf ../build

.PHONY: HashbangMobile-release
HashbangMobile-review: HashbangMobile-setup
	make -C aosp-build config ensure-git-status-clean
	make -C aosp-build manifest ensure-git-status-clean fetch
	make fetch review

HashbangMobile-build: clean fetch build release
