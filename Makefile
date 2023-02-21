#============================================
export DOCKER=$(shell which docker)
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
.PHONY: help
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
.PHONY: pre-build
pre-build: ${ESPSDK_RULESACCESS} ${ESPSDK_MINICOMCONF}
	@printf "\033[0m"
	@printf "\033[32m"
	@echo "================================= PRE BUILD ================================"
#	sudo dnf install -y minicom esptool python3-pyserial python3-wheel
	@sudo apt update && sudo apt upgrade && \
	 sudo apt install -y minicom esptool python3-serial python3-wheel
	@[ -f ${SYSTEM_RULESACCESS} ] || sudo cp -r ${ESPSDK_RULESACCESS} ${SYSTEM_RULESACCESS}
	@sudo usermod -a -G dialout ${USER} && sudo udevadm control --reload-rules
	@[ -f ${SYSTEM_MINICOMCONF} ] || sudo cp -r ${ESPSDK_MINICOMCONF} ${SYSTEM_MINICOMCONF}
	@printf "\033[36m"
	@echo "============================== PRE BUILD OK! ==============================="
	@printf "\033[0m"

#===========================================================
# ######### Сборка base-micropyton-image в Docker ##########
#===========================================================
.PHONY: build-docker-base
build-docker-base: ${DOCKER} ${DOCKERFILE_BASE}
	@printf "\033[0m"
	@printf "\033[32m"
	@echo "============================== BUILD BASE IMAGE ============================"
	@${DOCKER} build \
	--file ${PWD}/${DOCKERFILE_BASE} \
	--tag base-micropyton-image-${MICROPYTHON_VERSION}:${IMAGE_TAG} .
	@${DOCKER} image prune --filter label=stage=builder --force
#	--build-arg TIMEZONE=${TIMEZONE}
#	--build-arg USER=${USER}
#	--build-arg USER_ID=${USER_ID}
	@echo "========== BUILD base-micropyton-image-${MICROPYTHON_VERSION}:${IMAGE_TAG} ========="
	@printf "\033[36m"
	@echo "=========================== BUILD BASE IMAGE OK! ==========================="
	@printf "\033[0m"

#===========================================================
# ######## Сборка ESPSDK micropyton-image в Docker #########
#===========================================================
.PHONY: build-docker-esp8266
build-docker-esp8266: ${DOCKER} ${ESPSDK_DOCKERFILE}
	@printf "\033[0m"
	@printf "\033[32m"
	@echo "========================= BUILD MICROPYTHON ESP8266 ========================"
	@[ `${DOCKER} images | grep ${ESPSDK} | wc -l` -eq 1 ] || \
	${DOCKER} build \
	--file ${PWD}/${ESPSDK_DOCKERFILE} \
	--tag ${ESPSDK}-${MICROPYTHON_VERSION}:${IMAGE_TAG} .
	@${DOCKER} image prune --filter label=stage=builder --force
#	--build-arg TIMEZONE=${TIMEZONE}
#	--build-arg USER=${USER}
#	--build-arg USER_ID=${USER_ID}
	@echo "================ BUILD ${ESPSDK}-${MICROPYTHON_VERSION}:${IMAGE_TAG} ==============="
	@printf "\033[36m"
	@echo "====================== BUILD MICROPYTHON ESP8266 OK! ======================="
	@printf "\033[0m"

#===========================================================
# ########## Запуск MICROPYTHON ESP8266 ESPSDK #############
#===========================================================
.PHONY: start
start: ${DOCKER} ${ESPSDK_DOCKERFILE}
	@printf "\033[0m"
	@printf "\033[33m"
	@echo "============================== START ESPSDK ================================"
	@[ `${DOCKER} ps | grep ${ESPSDK} | wc -l` -eq 1 ] || \
	${DOCKER} run \
		-it --name ${ESPSDK} \
		--rm \
		--volume ${PWD}/${ESPSDK_FIRMWARE}:/home/work/firmware \
		--volume ${PWD}/${ESPSDK_SRC}:/home/work/modules \
		${ESPSDK}-${MICROPYTHON_VERSION}:${IMAGE_TAG} bash
#	--volume ${PWD}/${ESPSDK_FIRMWARE}:/home/${USER}/firmware
#	--volume ${PWD}/${ESPSDK_SRC}:/home/${USER}/modules
	@printf "\033[33m"
	@echo "============================ START ESPSDK OK! =============================="
	@printf "\033[0m"

#===========================================================
# ############ Запуск BUILD FIRMWARE ESP8266 ###############
#===========================================================
.PHONY: build-firmware
build-firmware: ${DOCKER} ${ESPSDK_DOCKERFILE}
	@printf "\033[0m"
	@printf "\033[34m"
	@echo "============================ BUILD FIRMWARE ================================"
	@[ -d $(ARCHIVE) ] || mkdir ${ARCHIVE}
	@[ -d $(ESPSDK_FIRMWARE) ] || mkdir ${ESPSDK_FIRMWARE}
	@find "$(ESPSDK_FIRMWARE)" -name '*.bin' -type f -exec mv -v -t "$(ARCHIVE)" {} +
	@[ `${DOCKER} ps | grep ${ESPSDK} | wc -l` -eq 1 ] || \
		${DOCKER} run \
			-it --name ${ESPSDK} \
			--rm \
			--volume ${PWD}/${ESPSDK_FIRMWARE}:/home/work/firmware \
			--volume ${PWD}/${ESPSDK_SRC}:/home/work/modules \
			${ESPSDK}-${MICROPYTHON_VERSION}:${IMAGE_TAG} build
#	--volume ${PWD}/${ESPSDK_FIRMWARE}:/home/${USER}/firmware
#	--volume ${PWD}/${ESPSDK_SRC}:/home/${USER}/modules
	@printf "\033[34m"
	@echo "============================ BUILD FIRMWARE OK! ============================"
	@printf "\033[0m"

#===========================================================
# ######### Удаление MICROPYTHON ESP8266 ESPSDK ############
#===========================================================
.PHONY: delete-image
delete-image: clean?=
delete-image: base?=
delete-image: ${DOCKER}

ifdef clean
	@printf "\033[31m"
	@echo "================= CLEAN ${ESPSDK}-${MICROPYTHON_VERSION}:${IMAGE_TAG} =============="
	${DOCKER} rmi ${ESPSDK}-${MICROPYTHON_VERSION}:${IMAGE_TAG}
	@${DOCKER} rmi ${REGISTRY_HOST}/${ESPSDK}-${MICROPYTHON_VERSION}:${IMAGE_TAG}
	@printf "\033[0m"
else
	@printf "\033[36m"
	@echo "=========== SAVE LOCAL IMAGE ${ESPSDK}-${MICROPYTHON_VERSION}:${IMAGE_TAG} ========="
	@${DOCKER} rmi ${REGISTRY_HOST}/${ESPSDK}-${MICROPYTHON_VERSION}:${IMAGE_TAG}
	@echo "======= CLEAN ${REGISTRY_HOST}/${ESPSDK}-${MICROPYTHON_VERSION}:${IMAGE_TAG} ======="
	@printf "\033[0m"
endif

ifdef base
	@printf "\033[31m"
	@echo "=========== CLEAN base-micropyton-image-${MICROPYTHON_VERSION}:${IMAGE_TAG} ========"
	${DOCKER} rmi base-micropyton-image-${MICROPYTHON_VERSION}:${IMAGE_TAG}
	@printf "\033[0m"
endif


#===========================================================
# #### Публикация MICROPYTHON ESP8266 ESPSDK в REGISTRY ####
#===========================================================
# make deploy-docker - Публикация в REGISTRY
# make deploy-docker clean?=true - Публикация в REGISTRY и удаление локального образа
.PHONY: deploy-docker
deploy-docker: clean?=
deploy-docker: base?=
deploy-docker: ${DOCKER}
	@printf "\033[0m"
	@printf "\033[34m"
	@echo "=========================== DEPLOY IMAGE ESPSDK ============================"
	@${DOCKER} login -u ${REGISTRY_USER} -p ${REGISTRY_PASSWORD} ${REGISTRY_HOST}
	@${DOCKER} tag $${ESPSDK}-${MICROPYTHON_VERSION}:${IMAGE_TAG} \
		${REGISTRY_HOST}/${ESPSDK}-${MICROPYTHON_VERSION}:${IMAGE_TAG}
	@${DOCKER} push ${REGISTRY_HOST}/${ESPSDK}-${MICROPYTHON_VERSION}:${IMAGE_TAG}
	@${DOCKER} logout
	@printf "\033[32m"
	@echo "========================= DEPLOY IMAGE ESPSDK OK! =========================="
	@printf "\033[0m"
	@make delete-image clean=$(clean) base=$(base)

#===========================================================
# ##### Создание release src MICROPYTHON ESP8266 ESPSDK ####
#===========================================================
.PHONY: release
release:
	@printf "\033[0m"
	@printf "\033[34m"
	@echo "========================== CREATE RELEASE SRC =============================="
	@[ -d $(RELEASE) ] || mkdir ${RELEASE}
	@[ -d $(ARCHIVE) ] || mkdir ${ARCHIVE}
	@find "$(RELEASE)" -name '*.zip' -type f -exec mv -v -t "$(ARCHIVE)" {} +
	@find "$(ESPSDK_FIRMWARE)" -name '*.bin' -type f -exec mv -v -t "$(ARCHIVE)" {} +
	@zip -r ${RELEASE}/${ESPSDK}-$(shell date '+%Y-%m-%d-%H-%M-%S').zip \
		${README} ${MAKEFILE} ${DOCKERFILE} ${ESPSDK_SCRIPT} ${LICENSE} \
		${ESPSDK_SRC} ${ESPSDK_FIRMWARE} ${ESPSDK_SRC}
	@printf "\033[32m"
	@echo "=========================== CREATE RELEASE SRC OK! ========================="
	@printf "\033[0m"

#===========================================================
# ################# Запуск TOOLS ESP8266 ###################
#===========================================================
.PHONY: pyserial
pyserial: ${ESPSDK_TOOLS}
	@${ESPSDK_TOOLS} --pyserial

.PHONY: minicom
minicom: ${ESPSDK_TOOLS}
	@${ESPSDK_TOOLS} --minicom

.PHONY: info
info: ${ESPSDK_TOOLS}
	@${ESPSDK_TOOLS} --id

.PHONY: upload
upload: ${ESPSDK_TOOLS}
	@make clean
	@${ESPSDK_TOOLS} --latest_write

.PHONY: clean
clean: ${ESPSDK_TOOLS}
	@${ESPSDK_TOOLS} --erase

.PHONY: tools-help
tools-help: ${ESPSDK_TOOLS}
	@${ESPSDK_TOOLS} --help

#============================================