.PHONY: help pre-build build start stop remove \
		pyserial minicom get-mac get-id upload \
		clean release release-clean

#============================================
SOURCE=esp32sdk
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
	@echo "make pre-build	- Preparing to building Docker"
	@echo "make build	- Building a Docker"
	@echo "make start	- Start of Docker"
	@echo "make stop	- Stopping Docker"
	@echo "make remove	- Deleting a Docker image"
	@echo "make pyserial - Monitoring the operation of the microcontroller via pyserial"
	@echo "make minicom	- Monitoring the operation of the microcontroller via minicon"
	@echo "make get-mac	- Getting the Mac address of the microcontroller"
	@echo "make get-id	- Getting the microcontroller ID"
	@echo "make upload	- Loading firmware to the microcontroller"
	@echo "make clean	- Cleaning the microcontroller"
	@exit 0

pre-build: ${SRCDIR}/${RULESACCESS}
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y python3 python3-pip minicom
	sudo python3 -m pip install setuptools
	sudo python3 -m pip install esptool
#	sudo python3 -m pip install --upgrade setuptools
	sudo python3 -m pip install pyserial
#	sudo python3 -m pip install --upgrade pyserial
	[ -f ${RULESDIR}/${RULESACCESS} ] || sudo cp -r ${SRCDIR}/${RULESACCESS} ${RULESDIR}
	sudo usermod -a -G dialout ${USER}
	sudo udevadm control --reload-rules
	[ -f ${MINICOMDIR}/${MINICOMCONF} ] || sudo cp -r ${SRCDIR}/${MINICOMCONF} ${MINICOMDIR}

build: ${DOCKERFILE}
	[ `docker images | grep ${SOURCE} | wc -l` -eq 1 ] || \
	docker build \
	--file ./${DOCKERFILE} \
	--build-arg USER=${USER} \
	--build-arg USER_ID=${ID} \
    --build-arg GROUP_ID=${ID} \
	--tag ${SOURCE}:latest ./

start: 
	! [ `docker images | grep ${SOURCE} | wc -l` -eq 1 ] || \
	[ `docker ps | grep ${SOURCE} | wc -l` -eq 1 ] || \
	docker run \
	-it --name ${SOURCE} \
	--rm \
	--volume ${PWD}/firmware:/home/${USER}/firmware \
	--volume ${PWD}/modules:/home/${USER}/modules \
	${SOURCE}:latest
	! [ `docker ps | grep ${SOURCE} | wc -l` -eq 1 ] || \
	echo "\n *****The SDK in Docker is already running***** \n"

stop:
	! [ `docker images | grep ${SOURCE} | wc -l` -eq 1 ] || \
	! [ `docker ps | grep ${SOURCE} | wc -l` -eq 1 ] || \
	docker stop ${SOURCE}

remove: 
	make stop
	docker rmi ${SOURCE}:latest

release-clean: ${RELEASE}
	rm -fr ${RELEASE}

release: release-clean
	mkdir ${RELEASE}
	zip -r ${RELEASE}/${SOURCE}-$(shell date '+%Y-%m-%d').zip \
	README.md Makefile ${DOCKERFILE} src firmware/README.md modules/README.md

pyserial: ${SRCDIR}/${TOOLS}
	${SRCDIR}/${TOOLS} -mpy

minicom: ${SRCDIR}/${TOOLS}
	${SRCDIR}/${TOOLS} -mcm 

get-mac: ${SRCDIR}/${TOOLS}
	${SRCDIR}/${TOOLS} -mac

get-id: ${SRCDIR}/${TOOLS}
	${SRCDIR}/${TOOLS} -i

upload: ${SRCDIR}/${TOOLS}
	make clean
	${SRCDIR}/${TOOLS} -lw

clean: ${SRCDIR}/${TOOLS}
	${SRCDIR}/${TOOLS} -e
