#!/bin/bash
DATETIME=$(date +'%Y-%m-%d-%H-%M-%S')
VER="esp32"
NAME="$VER-$DATETIME.bin"
export ESPIDF=$HOME/esp-idf
export PATH=$PATH:$HOME/xtensa-esp32-elf/bin
SDK="$HOME/micropython/ports/esp32"
FIRMVARE_SDK="build-GENERIC/firmware.bin"
FIRMVARE="$HOME/firmware"
MODULES_SDK="$SDK/modules"
MODULES_FW="$HOME/modules"
#===============================
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
NORMAL=$(tput sgr0)
#===============================

# Очистка и сборка новой прошивки, если на каком-то шаге ошибка дальше не продолжается работа
# Очистка
clean_project() {
    cd $SDK
    echo "$CYAN####################### CLEAN SDK $VER ###########################$NORMAL"
    sleep 2
    make clean
    if [[ $? -ne 0 ]]; then
        echo "$RED###################### Error Clean! ########################$NORMAL"
        exit 1
    else
        echo "$CYAN#################### Clean Old project OK! ########################$NORMAL"
    fi
}

# Копирование исходного кода для компиляции
copy_modules() {
    cd $MODULES_FW
    echo "$CYAN################### COPYING THE SOURCE CODE #######################$NORMAL"
    find ./ -type f ! -name "*.md" -exec cp --parents -r -t $MODULES_SDK "{}" \+
    ls -l $MODULES_SDK
    echo "$CYAN############# COPYING THE SOURCE CODE IS COMPLETE #################$NORMAL"
}

# Сборка новой прошивки
build_project() {
    cd $SDK   
    echo "$CYAN###################### MAKE PROJECT $VER #########################$NORMAL"
    sleep 2
    make
    if [[ $? -ne 0 ]]; then
        echo "$RED###################### Error Make Firmware! ##########################$NORMAL"
        exit 1
    else
        echo "$CYAN####################### Make Firmware OK! #########################$NORMAL"
        cp $FIRMVARE_SDK $FIRMVARE/$NAME
        echo "NAMEFIRMWARE: $NAME"
        echo "$CYAN##################### FINISH MAKE FIRMWARE ########################$NORMAL"
    fi
}

case $1 in
    "-c" ) clean_project ;;
    "-cp" ) copy_modules ;;
    "-b" ) build_project ;;
    "-cb" ) 
        clean_project
        copy_modules
        build_project ;;
    "-h" )
        echo "$GREEN#################### HELP ##########################################"
        echo "$0 -c  | Очистка SDK"
        echo "$0 -cp | Копирование исходного кода"
        echo "$0 -b  | Cборка прошивки"
        echo "$0 -cb | Очистка SDK и сборка прошивки"
        echo "$0 -h  | Справка по работе со скриптом"
        echo "####################################################################$NORMAL"
        ;;
    *)
        echo "$GREEN####################################################################"
        echo "Для получения информации по работе со скриптом $0 -h"
        echo "####################################################################$NORMAL"
        ;;
esac
