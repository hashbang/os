device = ${DEVICE}
.DEFAULT_GOAL := default

default: build

image:
	docker build -t hashbang/os:latest .

build: image
	docker run \
	  -it \
	  -v android:/home/build \
	  --env-file config/$(device).env \
	  hashbang/os

shell: image
	docker run \
	  -it \
	  -v android:/home/build \
	  hashbang/os bash

diff: image
	docker run \
	  -it \
	  -v android:/home/build \
	  hashbang/os repo diff -u

install: image
	docker run \
	  -it \
	  --privileged \
	  -u root \
	  -v android:/home/build \
	  --env-file=configs/$(device).env \
	  hashbang/os flash.sh

clean:
	docker run \
	  -it \
	  -v android:/home/build \
	  hashbang/os make clean

.PHONY: image build shell diff flash clean default
