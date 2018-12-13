device = ${DEVICE}

.DEFAULT_GOAL := default

default: build

image:
	docker build -t hashbang/os:latest .

build: image
	docker run \
	  -it \
	  -v android:/home/build \
	  -e DEVICE=$(device) \
	  hashbang/os build

kernel: image
	docker run \
	  -it \
	  -v android:/home/build \
	  -e DEVICE=$(device) \
	  hashbang/os build-kernel

vendor: image
	docker run \
	  -it \
	  -v android:/home/build \
	  -e DEVICE=$(device) \
	  hashbang/os build-vendor

chromium: image
	docker run \
	  -it \
	  -v android:/home/build \
	  hashbang/os build-chromium

release: image
	docker run \
	  -it \
	  -v android:/home/build \
	  -v $(PWD)/release:/home/build/release \
	  -e DEVICE=$(device) \
	  hashbang/os release

keys: image
	docker run \
	  -it \
	  -v android:/home/build \
	  -e DEVICE=$(device) \
	  hashbang/os keys

shell: image
	docker run \
	  -it \
	  -v android:/home/build \
	  -v $(PWD)/release:/home/build/release \
	  hashbang/os shell

diff:
	docker run \
	  -v android:/home/build \
	  hashbang/os bash -c "cd base; repo diff -u"

install: image
	docker run \
	  -it \
	  --privileged \
	  -u root \
	  -v android:/home/build \
	  -e DEVICE=$(device) \
	  hashbang/os flash

manifest: image
	docker run \
	  -it \
	  -v android:/home/build \
	  -e DEVICE=$(device) \
	  hashbang/os bash -c "manifest $(device) kernel | xmllint --format -" \
	> manifests/$(device)-kernel.xml
	docker run \
	  -it \
	  -v android:/home/build \
	  -e DEVICE=$(device) \
	  hashbang/os bash -c "manifest $(device) platform | xmllint --format -" \
	> manifests/base.xml

config: image
	docker run \
	  -it \
	  -v android:/home/build \
	  -e DEVICE=$(device) \
	  hashbang/os bash -c "config" \
	> config.json

clean: image
	docker run \
	  -it \
	  -v android:/home/build \
	  hashbang/os clean

.PHONY: image build shell diff install update flash clean default
