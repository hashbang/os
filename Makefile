device = ${DEVICE}

.DEFAULT_GOAL := default

default: build

image:
	docker build -t hashbang/os:latest .

config: image
	docker run \
	  -it \
	  -h "android" \
	  -v android:/home/build \
	  -e DEVICE=$(device) \
	  hashbang/os bash -c "config" \
	> config.yml

manifest: image
	docker run \
	  -it \
	  -h "android" \
	  -v android:/home/build \
	  hashbang/os bash -c "[ -d '/home/build/manifests' ] || manifest"

fetch: manifest
	docker run \
	  -it \
	  -h "android" \
	  -v android:/home/build \
	  hashbang/os bash -c "fetch"

tools: fetch
	docker run \
	  -it \
	  -h "android" \
	  -v android:/home/build \
	  hashbang/os bash -c "tools"

keys: tools
	docker run \
	  -it \
	  -h "android" \
	  -v android:/home/build \
	  -e DEVICE=$(device) \
	  hashbang/os keys

build: tools
	docker run \
	  -it \
	  -h "android" \
	  -v android:/home/build \
	  -e DEVICE=$(device) \
	  hashbang/os build

kernel: tools
	docker run \
	  -it \
	  -h "android" \
	  -v android:/home/build \
	  -e DEVICE=$(device) \
	  hashbang/os build-kernel

vendor: tools
	docker run \
	  -it \
	  -h "android" \
	  -v android:/home/build \
	  -e DEVICE=$(device) \
	  hashbang/os build-vendor

chromium: tools
	docker run \
	  -it \
	  -h "android" \
	  -v android:/home/build \
	  hashbang/os build-chromium

release: tools
	docker run \
	  -it \
	  -h "android" \
	  -v android:/home/build \
	  -v $(PWD)/release:/home/build/release \
	  -e DEVICE=$(device) \
	  hashbang/os release

shell:
	docker run \
	  -it \
	  -h "android" \
	  -v android:/home/build \
	  -v $(PWD)/release:/home/build/release \
	  hashbang/os shell

diff:
	@docker run \
	  -v android:/home/build \
	  hashbang/os bash -c "cd base; repo diff -u"

install: tools
	docker run \
	  -it \
	  -h "android" \
	  --privileged \
	  -u root \
	  -v android:/home/build \
	  -e DEVICE=$(device) \
	  hashbang/os flash

clean: image
	docker run \
	  -it \
	  -h "android" \
	  -v android:/home/build \
	  hashbang/os clean

.PHONY: image build shell diff install update flash clean tools default
