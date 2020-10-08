#!/bin/bash

if [ -z $3 ] ; then n="0"
    else n=$3
fi

V="ESP8266"                         # Изменяемый параметр
ESPTOOL="/usr/local/bin/esptool.py" # Изменяемый параметр
PYTHON="/usr/bin/python3 -m"        # Изменяемый параметр
SERIAL="serial.tools.miniterm"      # Изменяемый параметр
SERIAL_SPEED=115200                 # Изменяемый параметр
SERIAL_PORT="/dev/ttyUSB$n"         # Изменяемый параметр
UPLOAD_SPEED=460800                 # Изменяемый параметр
FIRMWAREDIR=firmware
MINICOM="/usr/bin/minicom"

# Moнитор порта UART
monitor_board() {
sleep 1
echo "########################## MONITOR UART $V ###########################"
$PYTHON $SERIAL $SERIAL_PORT $SERIAL_SPEED
}

monitor_minicom() {
    sleep 1
    echo "####################### MONITOR UART $V Minicom ######################"
    $MINICOM usb
}

# Flash ID
chip_info() {
sleep 1
echo "##################### $V CHIP INFO ########################"
$ESPTOOL --port $SERIAL_PORT flash_id
if [[ $? -ne 0 ]]; then
    echo "######################## ERROR $V CHIP INFO! ###########################"
    exit 1
fi
}

# Chip ID
id_board() {
sleep 1
echo "############################ $V ID CHIP ##############################"
$ESPTOOL --port $SERIAL_PORT --baud $UPLOAD_SPEED chip_id
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
$ESPTOOL --port $SERIAL_PORT --baud $UPLOAD_SPEED flash_id
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
$ESPTOOL --port $SERIAL_PORT --baud $UPLOAD_SPEED read_mac
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
$ESPTOOL --port $SERIAL_PORT --baud $UPLOAD_SPEED erase_flash
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
$ESPTOOL --port $SERIAL_PORT --baud $UPLOAD_SPEED write_flash --flash_size=detect -fm dio 0 $FIRMWARE
if [[ $? -ne 0 ]]; then
    echo "######################## ERROR UPLOAD THE FIRMWARE! ###########################"
    exit 1
fi
echo "########################### ALL FINISH ############################"
}

# Запись последней скомпилированной прошивки
latest_write() {
    # Получаем информацию где запушен скрипт
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    # Получаем информацию о последней директории
    LATEST=$(echo $DIR | awk -F'/' '{print $NF}')
    # Получаем информацию о родительской диретории
    HOMEDIR=$(echo $DIR | sed "s/$LATEST//g")
    # Получаем информацию о последней прошивке в диретории
    FIRMWARE=$(ls $HOMEDIR/$FIRMWAREDIR | grep bin | tail -n 1)
    # Формируем путь к последней прошивке
    FIRMWARE="$FIRMWAREDIR/$FIRMWARE"
    # Записываем последнюю прошивку в микроконтроллер
    chip_write
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
    "-lw" )
          latest_write
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
    "-mpy" )
          monitor_board  # Moнитор порта UART
          ;;
    "-mcm" )
          monitor_minicom  # Moнитор порта UART
          ;;
    "-h" )
          echo "############################################ HELP ###############################################"
          echo "$0 -mpy | Moнитор порта UART PySerial"
          echo "$0 -mcm | Moнитор порта UART Minicom"
          echo "$0 -e   | Очистка $V"
          echo "$0 -w   | Только запись прошивки, необходимо передать имя прошивки"
          echo "$0 -lw  | Запись последней скомпилированной прошивки"
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

