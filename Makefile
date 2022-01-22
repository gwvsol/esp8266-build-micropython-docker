.PHONY: help build start stop remove \
		pyserial minicom mac id upload \
		clean release release-clean

#============================================
DOCKER=$(shell which docker)
export PWD=$(shell pwd)
export USER=$(shell whoami)
export USER_ID=$(shell id -u `whoami`)

ifneq ("$(wildcard $(shell which timedatectl))","")
	export TIMEZONE=$(shell timedatectl status | awk '$$1 == "Time" && $$2 == "zone:" { print $$3 }')
endif

ENVIRONMENT=.env
ENVFILE=$(PWD)/${ENVIRONMENT}
ifneq ("$(wildcard $(ENVFILE))","")
    include ${ENVFILE}
    export ENVFILE=$(PWD)/${ENVIRONMENT}
endif

#============================================

.DEFAULT: help

help:
	@echo "make build	- Building a Docker"
	@echo "make start	- Start of Docker"
	@exit 0

build: ${DOCKER} ${ESPSDK_DOCKERFILE}
	[ `docker images | grep ${ESPSDK} | wc -l` -eq 1 ] || \
	docker build \
	--file ${PWD}/${ESPSDK_DOCKERFILE} \
	--build-arg TIMEZONE=${TIMEZONE} \
	--build-arg USER=${USER} \
	--build-arg USER_ID=${USER_ID} \
	--tag ${ESPSDK}:latest ./

start: ${DOCKER} ${ESPSDK_DOCKERFILE}
	[ `docker ps | grep ${ESPSDK} | wc -l` -eq 1 ] || \
	docker run \
	-it --name ${ESPSDK} \
	--rm \
	--volume ${PWD}/${ESPSDK_FIRMWARE}:/home/${USER}/firmware \
	--volume ${PWD}/${ESPSDK_SRC}:/home/${USER}/modules \
	${ESPSDK}:latest bash

build-firmware: ${DOCKER} ${ESPSDK_DOCKERFILE}
	[ `docker ps | grep ${ESPSDK} | wc -l` -eq 1 ] || \
	docker run \
	-it --name ${ESPSDK} \
	--rm \
	--volume ${PWD}/${ESPSDK_FIRMWARE}:/home/${USER}/firmware \
	--volume ${PWD}/${ESPSDK_SRC}:/home/${USER}/modules \
	${ESPSDK}:latest build

remove: ${DOCKER} ${ESPSDK_DOCKERFILE}
	! [ `${DOCKER} images | grep ${ESPSDK} | wc -l` -eq 1 ] || \
	${DOCKER} rmi ${ESPSDK}:${RELEASE_IMAGE}
