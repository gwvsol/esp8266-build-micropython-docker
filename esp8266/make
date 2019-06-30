#!/bin/bash
project=$(pwd)
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
clean_make() {
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
        echo "NAME FIRMWARE:"
        echo "$name"
        cd $project
        echo "THE FIRMWARE IS LOCATED:"
        echo "$(pwd)"
        echo "##################### FINISH MAKE FIRMWARE ########################"
    fi
fi
}

chip_erase() {
sleep 1
echo "##################### ERASE FLASH ESP8266 ########################"
esptool.py --port /dev/ttyUSB0 erase_flash
if [[ $? -ne 0 ]]; then
    echo "######################## ERROR ERASE FLASH! ###########################"
    exit 1
fi
}

chip_write() {
sleep 1
echo "############# UPLOAD THE FIRMWARE INTO THE ESP8266 ###############"
echo "UPLOAD THE FIRMWARE $name"
esptool.py --port /dev/ttyUSB0 --baud 460800 write_flash --flash_size=detect -fm dio 0 $name
if [[ $? -ne 0 ]]; then
    echo "######################## ERROR UPLOAD THE FIRMWARE! ###########################"
    exit 1
fi
echo "########################### ALL FINISH ############################"
}

case $1 in
     "-om" )
          cl_mk=true
          ;;
     "-mw" )
          cl_mk=true
          ech=true
          wch=true
          ;;
     "-ow" )
          name=$2
          echo "UPLOAD FIRMWARE $name"
          ech=true
          wch=true
          ;;
     "--help" )
          echo "############################################ HELP ###############################################"
          echo "$0 -om | Только сборка прошивки"
          echo "$0 -mw | Cборка прошивки, очистка контроллера и запись новой прошивки"
          echo "$0 -ow | Только очистка контроллера и запись прошивки, необходимо передать имя прошивки"
          echo "$0 --help | Справка по работе со скриптом"
          echo "#################################################################################################"
          ;;
     *)
          echo "####################################################################"
          echo "Для получения информации по работе со скриптом $0 --help"
          echo "####################################################################"
          ;;
esac

if $cl_mk; then clean_make 
fi

if $ech; then chip_erase 
fi

if $wch; then chip_write 
fi

