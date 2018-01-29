export MAINTAINER:=ulm0
export NAME:=gitlab
export IMAGE:=$(MAINTAINER)/$(NAME)
export CE_VERSION:=$(shell ./ci/version)
export ARCHS:=ARMv6 or later

all: version image

help:
	# General commands:
	# make all => image
	# make version - show information about the current version
	#
	# Build commands
	# make image - release images to docker hub and project registry

version: FORCE
	@echo "---"
	@echo Version: $(CE_VERSION)
	@echo Image: $(IMAGE):$(CE_VERSION)
	@echo Platorms: $(ARCHS)
	@echo ""
	@echo Brought to you by ulm0
	@echo "---"

image:
	# Build and push the Docker image
	@./ci/build_and_release

FORCE:
