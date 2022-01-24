.PHONY: help build-img build-firmware start remove \
		pyserial minicom id upload clean release

#============================================
DOCKER=$(shell which docker)
export ESPTOOL=$(shell which esptool)
export PYTHON=$(shell which python3)
export MINICOM=$(shell which minicom)
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
	@echo "make build-img - Building a Docker"
	@echo "make build-firmware - Firmware build for esp8266"
	@echo "make remove - Deleting a Docker image"
	@echo "make start - Start of Docker"
	@echo "make info - Information about the esp8266"
	@echo "make upload - Loading firmware to the esp8266"
	@echo "make clean - Cleaning the esp8266"
	@echo "make pyserial - Monitoring the operation of via pyserial"
	@echo "make minicom - Monitoring the operation of via minicon"
	@exit 0

#============================================

pre-build: ${ESPSDK_RULESACCESS} ${ESPSDK_MINICOMCONF}
#	sudo dnf install -y minicom esptool python3-pyserial python3-wheel
	sudo apt install -y minicom esptool python3-serial python3-wheel
	[ -f ${SYSTEM_RULESACCESS} ] || sudo cp -r ${ESPSDK_RULESACCESS} ${SYSTEM_RULESACCESS}
	sudo usermod -a -G dialout ${USER}
	sudo udevadm control --reload-rules
	[ -f ${SYSTEM_MINICOMCONF} ] || sudo cp -r ${ESPSDK_MINICOMCONF} ${SYSTEM_MINICOMCONF}

#============================================

build-img: ${DOCKER} ${ESPSDK_DOCKERFILE}
	[ `docker images | grep ${ESPSDK} | wc -l` -eq 1 ] || \
	docker build \
	--file ${PWD}/${ESPSDK_DOCKERFILE} \
	--tag ${ESPSDK}:${MICROPYTHON} .
#	--build-arg TIMEZONE=${TIMEZONE}
#	--build-arg USER=${USER}
#	--build-arg USER_ID=${USER_ID}

start: ${DOCKER} ${ESPSDK_DOCKERFILE}
	[ `docker ps | grep ${ESPSDK} | wc -l` -eq 1 ] || \
	docker run \
	-it --name ${ESPSDK} \
	--rm \
	--volume ${PWD}/${ESPSDK_FIRMWARE}:/home/work/firmware \
	--volume ${PWD}/${ESPSDK_SRC}:/home/work/modules \
	${ESPSDK}:${MICROPYTHON} bash
#	--volume ${PWD}/${ESPSDK_FIRMWARE}:/home/${USER}/firmware
#	--volume ${PWD}/${ESPSDK_SRC}:/home/${USER}/modules

build-firmware: ${DOCKER} ${ESPSDK_DOCKERFILE}
	[ -d $(ARCHIVE) ] || mkdir ${ARCHIVE}
	[ -d $(ESPSDK_FIRMWARE) ] || mkdir ${ESPSDK_FIRMWARE}
	find "$(ESPSDK_FIRMWARE)" -name '*.bin' -type f -exec mv -v -t "$(ARCHIVE)" {} +
	[ `docker ps | grep ${ESPSDK} | wc -l` -eq 1 ] || \
	docker run \
	-it --name ${ESPSDK} \
	--rm \
	--volume ${PWD}/${ESPSDK_FIRMWARE}:/home/work/firmware \
	--volume ${PWD}/${ESPSDK_SRC}:/home/work/modules \
	${ESPSDK}:${MICROPYTHON} build
#	--volume ${PWD}/${ESPSDK_FIRMWARE}:/home/${USER}/firmware
#	--volume ${PWD}/${ESPSDK_SRC}:/home/${USER}/modules

remove: ${DOCKER} ${ESPSDK_DOCKERFILE}
	! [ `${DOCKER} images | grep ${ESPSDK} | wc -l` -eq 1 ] || \
	${DOCKER} rmi ${ESPSDK}:${MICROPYTHON}

release:
	[ -d $(RELEASE) ] || mkdir ${RELEASE}
	[ -d $(ARCHIVE) ] || mkdir ${ARCHIVE}
	find "$(RELEASE)" -name '*.zip' -type f -exec mv -v -t "$(ARCHIVE)" {} +
	find "$(ESPSDK_FIRMWARE)" -name '*.bin' -type f -exec mv -v -t "$(ARCHIVE)" {} +
#	make build-firmware
	zip -r ${RELEASE}/${ESPSDK}-$(shell date '+%Y-%m-%d-%H-%M-%S').zip \
	${README} ${MAKEFILE} ${DOCKERFILE} ${ESPSDK_SCRIPT} ${LICENSE} \
	${ESPSDK_SRC} ${ESPSDK_FIRMWARE} ${ESPSDK_SRC}

#============================================

pyserial: ${ESPSDK_TOOLS}
	${ESPSDK_TOOLS} --pyserial

minicom: ${ESPSDK_TOOLS}
	${ESPSDK_TOOLS} --minicom

info: ${ESPSDK_TOOLS}
	${ESPSDK_TOOLS} --id

upload: ${ESPSDK_TOOLS}
	make clean
	${ESPSDK_TOOLS} --latest_write

clean: ${ESPSDK_TOOLS}
	${ESPSDK_TOOLS} --erase

tools-help: ${ESPSDK_TOOLS}
	${ESPSDK_TOOLS} --help

#============================================