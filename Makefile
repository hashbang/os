device = ${DEVICE}
config = ${CONFIG}
userid = $(shell id -u)
groupid = $(shell id -g)

.DEFAULT_GOAL := default

contain := \
	mkdir -p keys build/$(config)/base && \
	mkdir -p keys build/$(config)/release && \
	mkdir -p keys build/$(config)/external && \
	docker run -it --rm -h "android" \
		-v $(PWD)/build/$(config)/base:/home/build/base \
		-v $(PWD)/build/$(config)/release:/home/build/release \
		-v $(PWD)/build/$(config)/external:/home/build/external \
		-v $(PWD)/keys:/home/build/keys \
		-v $(PWD)/scripts:/home/build/scripts \
		-v $(PWD)/configs/$(config)/config.yml:/home/build/config.yml \
		-v $(PWD)/configs/$(config)/manifests:/home/build/manifests \
		-v $(PWD)/configs/$(config)/patches:/home/build/patches \
		-u $(userid):$(groupid) \
		-e DEVICE=$(device) \
		-e CONFIG=$(config) \
		hashbang-os:latest

default: build

image:
	@docker build \
		--build-arg UID=$(userid) \
		--build-arg GID=$(groupid) \
		-t hashbang-os:latest .

manifest: image
	$(contain) manifest
	cp \
		build/configs/$(config)/manifests/*.xml \
		configs/$(config)/manifests/ || :

config: manifest
	$(contain) config

fetch:
	mkdir -p build
	@$(contain) fetch

tools: fetch image
	@$(contain) tools

keys: tools
	@$(contain) keys

build: image tools
	@$(contain) build

kernel: tools
	@$(contain) build-kernel

vendor: tools
	@$(contain) build-vendor

chromium: tools
	@$(contain) build-chromium

release: tools
	mkdir -p build/release
	@$(contain) release

test-repro:
	@$(contain) test-repro

test: test-repro

shell:
	@$(contain) shell

diff:
	@$(contain) bash -c "cd base; repo diff -u"

clean: image
	@$(contain) clean

mrproper: clean
	@docker image rm -f hashbang-os:latest
	rm -rf build

install: tools
	@scripts/flash

.PHONY: image build shell diff install update flash clean tools default
