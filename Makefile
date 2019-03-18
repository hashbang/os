device = ${DEVICE}
userid = $(shell id -u)
groupid = $(shell id -g)

.DEFAULT_GOAL := default

contain := \
	mkdir -p keys build && \
	docker run -it -h "android" \
		-v $(PWD)/build:/home/build \
		-v $(PWD)/keys:/home/build/keys \
		-v $(PWD)/terraform:/home/build/terraforms \
		-v $(PWD)/manifests:/opt/android/manifests:ro \
		-v $(PWD)/scripts:/home/build/scripts \
		-v $(PWD)/patches:/home/build/patches \
		-v $(PWD)/config.yml:/home/build/config.yml \
		-u $(userid):$(userid) \
		-e DEVICE=$(device) \
		--env-file=$(PWD)/terraform.env \
		hashbang-os:latest

default: build

image:
	@docker build \
		--squash \
		--build-arg UID=$(userid) \
		--build-arg GID=$(groupid) \
		-t hashbang-os:latest .

manifest: image
	$(contain) manifest

config: manifest
	$(contain) config
	cp build/manifests/* manifests

fetch:
	mkdir -p build
	@$(contain) fetch

tools: fetch image
	@$(contain) tools

keys: tools
	@$(contain) keys

build: tools
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
