image_hash = "f909bc4e3f39e81549f514958f7de01aaf14b3d12bf323f856e728eb491ee455"
image = "hashbang/aosp-build@sha256:$(image_hash)"
device = ${DEVICE}

.DEFAULT_GOAL := default

contain := \
	mkdir -p keys build/base && \
	mkdir -p keys build/release && \
	mkdir -p keys build/external && \
	docker run -it --rm -h "android" \
		-v $(PWD)/build/base:/home/build/base \
		-v $(PWD)/build/release:/home/build/release \
		-v $(PWD)/build/external:/home/build/external \
		-v $(PWD)/keys:/home/build/keys \
		-v $(PWD)/scripts:/home/build/scripts \
		-v $(PWD)/config.yml:/home/build/config.yml \
		-v $(PWD)/manifests:/home/build/manifests \
		-v $(PWD)/patches:/home/build/patches \
		-u $(shell id -u):$(shell id -g) \
		-e DEVICE=$(device) \
		$(image)

default: build

manifest:
	$(contain) manifest

config: manifest
	$(contain) config

fetch:
	mkdir -p build
	@$(contain) fetch

tools: fetch
	@$(contain) tools

keys: tools
	@$(contain) keys

build: fetch
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

test:
	@$(contain) test-repro

shell:
	@$(contain) shell

diff:
	@$(contain) bash -c "cd base; repo diff -u"

clean:
	@$(contain) clean

mrproper: clean
	rm -rf build

.PHONY: build shell diff install update flash clean tools default
