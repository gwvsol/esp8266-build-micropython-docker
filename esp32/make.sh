#!/bin/bash
PROJECT='/var/fw'
DT=$(date +'%Y-%m-%d-%H-%M-%S')
V="ESP32"
NAME="$V-$DT.bin"
export ESPIDF=/var/data/esp-idf
export PATH=$PATH:/var/data/xtensa-esp32-elf/bin
SDK='/var/data/micropython/ports/esp32'
FIRMVARE='build/firmware.bin'

# Очистка и сборка новой прошивки, если на каком-то шаге ошибка дальше не продолжается работа
# Очистка
clean_project() {
    cd $SDK
    echo "######################### CLEAN SDK $V ##############################"
    sleep 2
    make clean
    if [[ $? -ne 0 ]]; then
        echo "######################## Error Clean! ###########################"
        exit 1
    else
        echo "################### Clean Old project OK! ########################"
    fi
}

# Сборка новой прошивки
make_project() {
    cd $SDK   
    echo "######################## MAKE PROJECT $V ############################"
    sleep 2
    make
    if [[ $? -ne 0 ]]; then
        echo "###################### Error Make Firmware! ##########################"
        exit 1
    else
        echo "###################### Make Firmware OK! #########################"
        cp $FIRMVARE $PROJECT/$NAME
        echo "NAME FIRMWARE:"
        echo "$NAME"
        echo "##################### FINISH MAKE FIRMWARE ########################"
    fi
}

case $1 in
    "-c" )
        clean_project
        ;;
    "-m" )
        make_project
        ;;
    "-cm" )
        clean_project
        make_project
        ;;
    "-h" )
        echo "#################### HELP ##########################################"
        echo "$0 -c  | Очистка SDK"
        echo "$0 -m  | Cборка прошивки"
        echo "$0 -cm | Очистка SDK и сборка прошивки"
        echo "$0 -h  | Справка по работе со скриптом"
        echo "####################################################################"
        ;;
    *)
        echo "####################################################################"
        echo "Для получения информации по работе со скриптом $0 -h"
        echo "####################################################################"
        ;;
esac
