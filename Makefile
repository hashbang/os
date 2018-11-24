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
	  hashbang/os build.sh

release: image
	@docker run \
	  -it \
	  -v android:/home/build \
	  --env-file config/$(device).env \
	  hashbang/os release.sh

shell: image
	@docker run \
	  -it \
	  -v android:/home/build \
	  hashbang/os bash

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
	  hashbang/os flash.sh

update: image
	@docker run \
	  -it \
	  -v android:/home/build \
	  --env-file=config/$(device).env \
	  hashbang/os get-manifest.py kernel > manifests/$(device)/kernel.xml
	@docker run \
	  -it \
	  -v android:/home/build \
	  --env-file=config/$(device).env \
	  hashbang/os get-manifest.py platform > manifests/base.xml

clean: image
	@docker run \
	  -it \
	  -v android:/home/build \
	  hashbang/os clean.sh

.PHONY: image build shell diff install update flash clean default
