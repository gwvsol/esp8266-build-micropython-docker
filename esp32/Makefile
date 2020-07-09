.PHONY: help pre-build build start stop remove 

#============================================
SOURCE=esp32sdk
DOCKERFILE=Dockerfile
PWD=$(shell pwd)
USER=$(shell whoami)
ID=$(shell id -u `whoami`)
#GID=$(shell id -g `whoami`)
RELEASE=release
#============================================

.DEFAULT: help

help:
	@echo "make pre-build	- Preparing to building Docker"
	@echo "make build	- Building a Docker"
	@echo "make start	- Start of Docker"
	@echo "make stop	- Stopping Docker"
	@echo "make remove	- Deleting a node container"
	@exit 0

pre-build:
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y python3 python3-pip
	sudo python3 -m pip install setuptools
#	sudo python3 -m pip install --upgrade setuptools
	sudo python3 -m pip install pyserial
#	sudo python3 -m pip install --upgrade pyserial

build:
	docker build \
	--file ./${DOCKERFILE} \
	--build-arg USER=${USER} \
	--build-arg USER_ID=${ID} \
    --build-arg GROUP_ID=${ID} \
	--tag ${SOURCE}:latest ./

start: 
	docker run \
	-it --name ${SOURCE} \
	--rm \
	--volume ${PWD}:/home/${USER}/firmware \
	${SOURCE}:latest