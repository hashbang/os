device = ${DEVICE}

.DEFAULT_GOAL := default

default: build

image:
	@docker build -t hashbang/os:latest .

build: image
	@docker run \
	  -it \
	  -v android:/home/build \
	  --env-file config/$(device).env \
	  hashbang/os build

release: image
	@docker run \
	  -it \
	  -v android:/home/build \
	  -v $(PWD)/release:/home/build/release \
	  --env-file config/$(device).env \
	  hashbang/os release

keys: image
	@docker run \
	  -it \
	  -v android:/home/build \
	  --env-file config/$(device).env \
	  hashbang/os keys

shell: image
	@docker run \
	  -it \
	  -v android:/home/build \
	  -v $(PWD)/release:/home/build/release \
	  hashbang/os shell

diff:
	@docker run \
	  -v android:/home/build \
	  hashbang/os bash -c "cd base; repo diff -u"

install: image
	@docker run \
	  -it \
	  --privileged \
	  -u root \
	  -v android:/home/build \
	  --env-file=config/$(device).env \
	  hashbang/os flash

manifest: image
	@docker run \
	  -it \
	  -v android:/home/build \
	  --env-file=config/$(device).env \
	  hashbang/os manifest kernel > manifests/$(device)/kernel.xml && \
	docker run \
	  -it \
	  -v android:/home/build \
	  --env-file=config/$(device).env \
	  hashbang/os manifest platform > manifests/base.xml

clean: image
	@docker run \
	  -it \
	  -v android:/home/build \
	  hashbang/os clean

.PHONY: image build shell diff install update flash clean default

clean: image
	@docker run \
	  -it \
	  -v android:/home/build \
	  hashbang/os clean.sh

.PHONY: image build shell diff install update flash clean default
