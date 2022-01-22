.PHONY: help pre-build build start stop remove \
		pyserial minicom get-mac get-id upload \
		clean release release-clean

#============================================
SOURCE=esp8266sdk
SRCDIR=src
DOCKERFILE=Dockerfile
PWD=$(shell pwd)
USER=$(shell whoami)
ID=$(shell id -u `whoami`)
MINICOMDIR=/etc/minicom
MINICOMCONF=minirc.usb
RULESDIR=/etc/udev/rules.d
RULESACCESS=80-usb-serial-access.rules
TOOLS=tools.sh
RELEASE=release
#============================================

.DEFAULT: help

help:
	@echo "make build	- Building a Docker"
	@echo "make start	- Start of Docker"
	@exit 0

build: ${DOCKERFILE}
	[ `docker images | grep ${SOURCE} | wc -l` -eq 1 ] || \
	docker build \
	--file ./${DOCKERFILE} \
	--build-arg USER=${USER} \
	--build-arg USER_ID=${ID} \
	--tag ${SOURCE}:latest ./

start: 
	[ `docker ps | grep ${SOURCE} | wc -l` -eq 1 ] || \
	docker run \
	-it --name ${SOURCE} \
	--rm \
	--volume ${PWD}/firmware:/home/${USER}/firmware \
	--volume ${PWD}/modules:/home/${USER}/modules \
	${SOURCE}:latest
