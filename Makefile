export MAINTAINER:=ulm0
export NAME:=gitlab
export IMAGE:=$(MAINTAINER)/$(NAME)
export CE_VERSION:=$(shell ./ci/version)
export CE_TAG:=test
export ARCHS:=ARMv6 or later

ifeq ($(CI_COMMIT_REF_NAME), $(CE_VERSION))
	export CE_TAG=$(CE_VERSION)
endif

all: version build push

help:
	# General commands:
	# make all => build push
	# make version - show information about the current version
	#
	# Commands
	# make build - build the GitLab image
	# make push - push the image to Docker Hub

version: FORCE
	@echo "---"
	@echo Version: $(CE_VERSION)
	@echo Image: $(IMAGE):$(CE_TAG)
	@echo Platorms: $(ARCHS)
	@echo ""
	@echo Brought to you by ulm0
	@echo "---"

build:
	# Build the GitLab image
	@./ci/build

push:
	# Push image to Docker Hub
	@./ci/release

FORCE:
