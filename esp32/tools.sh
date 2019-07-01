#!/bin/bash

if [ -z $3 ] ; then n="0"
    else n=$3
fi

V="ESP32"                         # Изменяемый параметр
ESPTOOL="/usr/local/bin/esptool.py" # Изменяемый параметр
PYTHON="/usr/bin/python3 -m"        # Изменяемый параметр
SERIAL="serial.tools.miniterm"      # Изменяемый параметр
SERIAL_SPEED=115200                 # Изменяемый параметр
SERIAL_PORT="/dev/ttyUSB$n"         # Изменяемый параметр
UPLOAD_SPEED=460800                 # Изменяемый параметр

# Moнитор порта UART
monitor_board() {
sleep 1
echo "########################## MONITOR UART $V ###########################"
$PYTHON $SERIAL $SERIAL_PORT $SERIAL_SPEED
}

# Flash ID
chip_info() {
sleep 1
echo "##################### $V CHIP INFO ########################"
$ESPTOOL --chip esp32 --port $SERIAL_PORT flash_id
if [[ $? -ne 0 ]]; then
    echo "######################## ERROR $V CHIP INFO! ###########################"
    exit 1
fi
}

# Chip ID
id_board() {
sleep 1
echo "############################ $V ID CHIP ##############################"
$ESPTOOL --chip esp32 --port $SERIAL_PORT --baud $UPLOAD_SPEED chip_id
if [[ $? -ne 0 ]]; then
    echo "######################### $V ERROR ID CHIP ###########################"
    exit 1
fi
echo "############################ $V ID CHIP ##############################"
}

# Flash ID
flash_board() {
sleep 1
echo "############################ $V ID FLASH #############################"
$ESPTOOL --chip esp32 --port $SERIAL_PORT --baud $UPLOAD_SPEED flash_id
if [[ $? -ne 0 ]]; then
    echo "######################## $V ERROR ID FLASH ###########################"
    exit 1
fi
echo "############################ $V ID FLASH #############################"
}

# MAC INFO
mac_board() {
sleep 1
echo "############################ $V MAC INFO #############################"
$ESPTOOL --chip esp32 --port $SERIAL_PORT --baud $UPLOAD_SPEED read_mac
if [[ $? -ne 0 ]]; then
    echo "######################## $V ERROR MAC INFO ###########################"
    exit 1
fi
echo "############################ $V MAC INFO #############################"
}

# Очистка чипа
chip_erase() {
sleep 1
echo "##################### ERASE FLASH $V ########################"
$ESPTOOL --chip esp32 --port $SERIAL_PORT --baud $UPLOAD_SPEED erase_flash
if [[ $? -ne 0 ]]; then
    echo "######################## ERROR ERASE FLASH! ###########################"
    exit 1
fi
}

# Запись прошивки
chip_write() {
sleep 1
echo "############# UPLOAD THE FIRMWARE INTO THE $V ###############"
echo "UPLOAD THE FIRMWARE $FIRMWARE"
$ESPTOOL --chip esp32 --port $SERIAL_PORT --baud $UPLOAD_SPEED write_flash -z 0x1000 $FIRMWARE
if [[ $? -ne 0 ]]; then
    echo "######################## ERROR UPLOAD THE FIRMWARE! ###########################"
    exit 1
fi
echo "########################### ALL FINISH ############################"
}

case $1 in
    "-i" )
          id_board       # Chip ID
          ;;
    "-if" )
          flash_board    # Flash ID
          ;;
    "-mac" )
          mac_board      # MAC INFO
          ;;
    "-e" )
          chip_erase     # Очистка чипа
          ;;
    "-w" )
          FIRMWARE=$2    # Только Запись прошивки
          echo "UPLOAD FIRMWARE $FIRMWARE"
          chip_write
          ;;
    "-ew" )
          FIRMWARE=$2    # Очистка чипа и запись прошивки
          chip_erase     # Очистка чипа
          echo "UPLOAD FIRMWARE $FIRMWARE"
          chip_write     # Запись прошивки
          ;;
    "-m" )
          monitor_board  # Moнитор порта UART
          ;;
    "-h" )
          echo "############################################ HELP ###############################################"
          echo "$0 -m   | Moнитор порта UART"
          echo "$0 -e   | Очистка $V"
          echo "$0 -w   | Только запись прошивки, необходимо передать имя прошивки"
          echo "$0 -ew  | Очистка $V и запись новой прошивки, необходимо передать имя прошивки"
          echo "$0 -i   | Информация об ID $V"
          echo "$0 -if  | ID Flash $V"
          echo "$0 -mac | MAC адрес $V"
          echo "$0 -h   | Справка по работе со скриптом"
          echo "#################################################################################################"
          ;;
     *)
          echo "####################################################################"
          echo "Для получения информации по работе со скриптом $0 -h"
          echo "####################################################################"
          ;;
esac