## Argument Variables ##

CPUS := $(shell nproc)
MEMORY := 10000
DISK := 300000
DEVICE := crosshatch
BACKEND := local
CHANNEL := beta
BUILD := user
FLAVOR := aosp
IMAGE := hashbang/aosp-build:latest
IMAGE_OPTIONS :=
NAME := aosp-build-$(FLAVOR)-$(BACKEND)
SHELL := /bin/bash

-include $(PWD)/config/env/$(BACKEND).env

## Default Target ##

.DEFAULT_GOAL := default
.PHONY: default
default: machine image fetch tools keys build release


## Primary Targets ##

.PHONY: fetch
fetch: submodule-update machine image
	$(contain) fetch

.PHONY: keys
keys:
	$(contain) keys

.PHONY: build
build:
	$(contain) build

.PHONY: release
release:
	$(contain) release

.PHONY: publish
publish:
	$(contain) publish

.PHONY: clean
clean:
	$(contain) clean

.PHONY: mrproper
mrproper: storage-delete machine-delete
	rm -rf build


## Secondary Targets ##

.PHONY: image
image:
	$(docker) build \
		--tag $(IMAGE) \
		--file $(PWD)/config/container/Dockerfile \
		$(IMAGE_OPTIONS) \
		$(PWD)

config/container/Dockerfile.minimal: config/container/Dockerfile config/container/render_template
	./config/container/render_template "$<" | grep -v '^#\s*$$' > "$@"

.PHONY: image-minimal
image-minimal: config/container/Dockerfile.minimal
	$(docker) build \
		--tag $(IMAGE) \
		--file "$(PWD)/$<" \
		$(IMAGE_OPTIONS) \
		$(PWD)

.PHONY: tools
tools:
	mkdir -p config/keys build/base release build/external
	$(contain) tools

.PHONY: vendor
vendor:
	$(contain) build-vendor

.PHONY: chromium
chromium:
	$(contain) build-chromium

.PHONY: kernel
kernel:
	$(contain) build-kernel


## Development ##

.PHONY: latest
latest: config submodule-latest fetch

.PHONY: manifest
manifest: config
	$(contain) bash -c "source <(environment) && manifest"

.PHONY: config
config:
	$(contain) bash -c "source <(environment) && config"

.PHONY: test-repro
test-repro:
	$(contain) test-repro

.PHONY: test
test: test-repro

.PHONY: patches
patches:
	@$(contain) bash -c "cd base; repo diff --absolute"

.PHONY: shell
shell:
	$(docker) inspect "$(NAME)" \
	&& $(docker) exec --interactive --tty "$(NAME)" shell \
	|| $(contain) shell

.PHONY: monitor
monitor:
	$(docker) inspect "$(NAME)" \
	&& $(docker) exec --interactive --tty "$(NAME)" htop

.PHONY: install
install: tools
	@scripts/flash


## Source Management ##

.PHONY: submodule-update
submodule-update:
	git submodule update --init --recursive

.PHONY: submodule-latest
submodule-latest:
	git submodule foreach 'git checkout master && git pull'

## Storage Bootstrapping ##

# TODO: detect if plugin is already installed or not
# TODO: Hash lock rexray with sha256 digest to prevent tag clobbering
.PHONY: storage-digitalocean
storage-digitalocean:
	$(docker) volume ls | grep $(NAME) \
	||( $(docker) plugin install \
			--grant-all-permissions \
			rexray/dobs:0.11.4 \
			DOBS_REGION=$(DIGITALOCEAN_REGION) \
			DOBS_TOKEN=$(DIGITALOCEAN_TOKEN) \
		; $(docker) volume create \
			--driver rexray/dobs:0.11.4 \
			--opt=size=$$(( $(DISK) / 1000 )) \
			--name=$(NAME) \
	)

.PHONY: storage-local
storage-local:
	$(docker) volume ls | grep $(NAME) \
	|| $(docker) volume create \
		--driver local \
		--opt type=none \
		--opt o=bind \
		--opt device=$(PWD)/build \
		$(NAME)

.PHONY: storage-delete
storage-delete:
	$(docker) volume rm -f $(NAME) || :


## VM Management ##

.PHONY: machine-start
machine-start: machine-install machine-create machine-date
	$(docker_machine) status $(NAME) \
	|| $(docker_machine) start $(NAME)

.PHONY: machine-sync
machine-sync:
	$(docker_machine) scp -r -d config/ $(NAME):$(PWD)/config/

.PHONY: machine-shell
machine-shell:
	$(docker_machine) ssh $(NAME)

.PHONY: machine-stop
machine-stop:
	$(docker_machine) stop $(NAME)

.PHONY: machine-delete
machine-delete:
	$(docker_machine) rm -f -y $(NAME)

.PHONY: machine-date
machine-date:
	$(docker_machine) ssh $(NAME) \
		"sudo date -s @$(shell date +%s)"

.PHONY: machine-create
machine-create: machine-install
	$(docker_machine) status $(NAME) \
	||( $(docker_machine) create \
			--driver $(BACKEND) \
			$(docker_machine_create_flags) \
			$(NAME) \
	)

.PHONY: machine-install
machine-install:
	# wget docker-machine & hash check here


## VM Bootstrapping ##

ifeq ($(BACKEND),local)

executables = docker
docker = docker
machine:
storage_flags = --volume $(PWD)/build/:/home/build/build/

else ifeq ($(BACKEND),virtualbox)

executables = docker-machine ssh virtualbox
docker = $(docker_machine) ssh $(NAME) -t docker
machine: machine-start storage-local
storage_flags = --volume $(NAME):/home/build/build/
docker_machine_create_flags = \
	--virtualbox-share-folder="$(PWD):$(PWD)" \
	--virtualbox-disk-size="$(DISK)" \
	--virtualbox-memory="$(MEMORY)" \
	--virtualbox-cpu-count="$(CPUS)"

else ifeq ($(BACKEND),digitalocean)

executables = docker-machine ssh
docker = $(docker_machine) ssh $(NAME) -t docker
machine: machine-start storage-digitalocean machine-sync
storage_flags = --volume $(NAME):/home/build/build/
docker_machine_create_flags = \
	--digitalocean-access-token=$(DIGITALOCEAN_TOKEN) \
	--digitalocean-region=$(DIGITALOCEAN_REGION) \
	--digitalocean-image=$(DIGITALOCEAN_IMAGE) \
	--digitalocean-size=$(DIGITALOCEAN_SIZE)

endif

userid = $(shell id -u)
groupid = $(shell id -g)
docker_machine = docker-machine --storage-path "${PWD}/build/machine"
contain := \
	$(docker) run \
		--rm \
		--tty \
		--interactive \
		--name "$(NAME)" \
		--hostname "$(NAME)" \
		--user $(userid):$(groupid) \
		--env DEVICE=$(DEVICE) \
		--security-opt seccomp=unconfined \
		--volume $(PWD)/config:/home/build/config \
		--volume $(PWD)/release:/home/build/release \
		--volume $(PWD)/scripts:/home/build/scripts \
		$(storage_flags) \
		$(IMAGE)


## Required Binary Check ##

check_executables := $(foreach exec,$(executables),\$(if \
	$(shell which $(exec)),some string,$(error "No $(exec) in PATH")))
