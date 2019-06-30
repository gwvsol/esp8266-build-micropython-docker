#!/bin/bash

inf=false
ech=false
wch=false

if [ -z $3 ] ; then n="0"
    else n=$3
fi

port="/dev/ttyUSB$n"

chip_info() {
sleep 1
echo "##################### ESP8266 CHIP INFO ########################"
esptool.py --port $port flash_id
if [[ $? -ne 0 ]]; then
    echo "######################## ERROR ESP8266 CHIP INFO! ###########################"
    exit 1
fi
}

chip_erase() {
sleep 1
echo "##################### ERASE FLASH ESP8266 ########################"
esptool.py --port $port erase_flash
if [[ $? -ne 0 ]]; then
    echo "######################## ERROR ERASE FLASH! ###########################"
    exit 1
fi
}

chip_write() {
sleep 1
echo "############# UPLOAD THE FIRMWARE INTO THE ESP8266 ###############"
echo "UPLOAD THE FIRMWARE $name"
esptool.py --port $port --baud 460800 write_flash --flash_size=detect -fm dio 0 $name
if [[ $? -ne 0 ]]; then
    echo "######################## ERROR UPLOAD THE FIRMWARE! ###########################"
    exit 1
fi
echo "########################### ALL FINISH ############################"
}

case $1 in
    "-i" )
        inf=true
        ;;
    "-oe" )
        ech=true
        ;;
    "-ow" )
        name=$2
        echo "UPLOAD FIRMWARE $name"
        wch=true
        ;;
    "-ew" )
        name=$2
        echo "UPLOAD FIRMWARE $name"
        ech=true
        wch=true
        ;;
    "-h" )
        echo "############################################ HELP ###############################################"
        echo "$0 -i  | Информация о контроллере"
        echo "$0 -oe | Только очистка контроллера"
        echo "$0 -ow | Только прошивка, необходимо передать имя прошивки"
        echo "$0 -ew | Очистка контроллера и запись новой прошивки, необходимо передать имя прошивки"
        echo "$0 -h  | Справка по работе со скриптом"
        echo "#################################################################################################"
        ;;
    *)
        echo "####################################################################"
        echo "Для получения информации по работе со скриптом $0 -h"
        echo "####################################################################"
        ;;
esac

if $inf; then chip_info 
fi

if $ech; then chip_erase 
fi

if $wch; then chip_write 
fi

