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
	  --env-file config/global.env \
	  --env-file config/$(device).env \
	  hashbang/os build

kernel: image
	docker run \
	  -it \
	  -v android:/home/build \
	  -e DEVICE=$(device) \
	  --env-file config/global.env \
	  --env-file config/$(device).env \
	  hashbang/os build-kernel

vendor: image
	docker run \
	  -it \
	  -v android:/home/build \
	  -e DEVICE=$(device) \
	  --env-file config/global.env \
	  --env-file config/$(device).env \
	  hashbang/os build-vendor

chromium: image
	docker run \
	  -it \
	  -v android:/home/build \
	  --env-file config/global.env \
	  hashbang/os build-chromium

release: image
	docker run \
	  -it \
	  -v android:/home/build \
	  -v $(PWD)/release:/home/build/release \
	  -e DEVICE=$(device) \
	  --env-file config/global.env \
	  --env-file config/$(device).env \
	  hashbang/os release

keys: image
	docker run \
	  -it \
	  -v android:/home/build \
	  -e DEVICE=$(device) \
	  --env-file config/global.env \
	  --env-file config/$(device).env \
	  hashbang/os keys

shell: image
	docker run \
	  -it \
	  -v android:/home/build \
	  --env-file config/global.env \
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
	  --env-file config/global.env \
	  --env-file=config/$(device).env \
	  hashbang/os flash

config: image
	docker run \
	  -it \
	  -v android:/home/build \
	  -e DEVICE=$(device) \
	  --env-file config/global.env \
	  --env-file=config/$(device).env \
	  hashbang/os bash -c "config $(device) kernel | xmllint --format -" \
	> config/$(device)-kernel.xml
	docker run \
	  -it \
	  -v android:/home/build \
	  -e DEVICE=$(device) \
	  --env-file config/global.env \
	  --env-file=config/$(device).env \
	  hashbang/os bash -c "config $(device) platform | xmllint --format -" \
	> config/base.xml
	docker run \
	  -it \
	  -v android:/home/build \
	  -e DEVICE=$(device) \
	  --env-file config/global.env \
	  --env-file=config/$(device).env \
	  hashbang/os bash -c "config $(device) images" \
	> config/images.jsonl

clean: image
	docker run \
	  -it \
	  -v android:/home/build \
	  hashbang/os clean

.PHONY: image build shell diff install update flash clean default

clean: image
	docker run \
	  -it \
	  -v android:/home/build \
	  hashbang/os clean

.PHONY: image build shell diff install update flash clean default
