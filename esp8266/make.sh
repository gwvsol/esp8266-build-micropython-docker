#!/bin/bash
project="/var/fw"
dt=$(date +'%Y-%m-%d-%H-%M-%S')
v="ESP8266"
name="$v-$dt.bin"
cl_mk=false
ech=false
wch=false
export PATH=$PATH:/var/data/esp-open-sdk/xtensa-lx106-elf/bin
sdk='/var/data/micropython/ports/esp8266'
firmware='build/firmware-combined.bin'

# Очистка и сборка новой прошивки, если на каком-то шаге ошибка дальше не продолжается работа
make_fw() {
cd $sdk
echo "######################### CLEAN SDK ##############################"
sleep 3
make clean
if [[ $? -ne 0 ]]; then
    echo "######################## Error Clean! ###########################"
    exit 1
else
    echo "################### Clean Old project OK! ########################"
    echo "######################## MAKE PROJECT ############################"
    sleep 3
    make
    if [[ $? -ne 0 ]]; then
        echo "###################### Error Make Firmware! ##########################"
        exit 1
    else
        echo "###################### Make Firmware OK! #########################"
        cp $firmware $project/$name
        echo "FIRMWARE: $name"
        #cd $project
        #echo "THE FIRMWARE IS LOCATED:"
        #echo "$(pwd)"
        echo "##################### FINISH MAKE FIRMWARE ########################"
    fi
fi
}

case $1 in
     "-m" )
          make_fw
          ;;
     "-h" )
          echo "############################################ HELP ###############################################"
          echo "$0 -m | Очистка от старых сборок и создание новой прошивки"
          echo "$0 -h | Справка по работе со скриптом"
          echo "#################################################################################################"
          ;;
     *)
          echo "####################################################################"
          echo "Для получения информации по работе со скриптом $0 -h"
          echo "####################################################################"
          ;;
esac 