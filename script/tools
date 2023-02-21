#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
NORMAL=$(tput sgr0)

# Moнитор порта UART
pyserial_() {
sleep 1
echo "$GREEN ########################## MONITOR UART $VENDOR PYSERIAL ########################### $NORMAL"
$PYTHON -m $SERIAL_TOOLS $SERIAL_PORT $SERIAL_SPEED
}

minicom_() {
    sleep 1
    echo "$GREEN ####################### MONITOR UART $VENDOR MINICOM ###################### $NORMAL"
    $MINICOM usb
}

# Flash ID
chip_info() {
sleep 1
echo "$GREEN ##################### $VENDOR CHIP INFO ######################## $NORMAL $CYAN"
$ESPTOOL --port $SERIAL_PORT flash_id
if [[ $? -ne 0 ]]; then
    echo "$RED ######################## ERROR $VENDOR CHIP INFO! ########################### $NORMAL"
    exit 1
fi
}

# Chip ID
id_board() {
sleep 1
echo "$GREEN ############################ $VENDOR ID CHIP ############################## $NORMAL  $CYAN"
$ESPTOOL --port $SERIAL_PORT --baud $UPLOAD_SPEED chip_id
if [[ $? -ne 0 ]]; then
    echo "$RED ######################### $VENDOR ERROR ID CHIP ########################### $NORMAL"
    exit 1
fi
echo "$GREEN ############################ $VENDOR ID CHIP ############################## $NORMAL"
}

# Flash ID
flash_board() {
sleep 1
echo "$GREEN ############################ $VENDOR ID FLASH ############################# $NORMAL"
$ESPTOOL --port $SERIAL_PORT --baud $UPLOAD_SPEED flash_id
if [[ $? -ne 0 ]]; then
    echo "$RED ######################## $VENDOR ERROR ID FLASH ########################### $NORMAL"
    exit 1
fi
echo "$GREEN ############################ $VENDOR ID FLASH ############################# $NORMAL"
}

# MAC INFO
mac_board() {
sleep 1
echo "$GREEN ############################ $VENDOR MAC INFO ############################# $NORMAL"
$ESPTOOL --port $SERIAL_PORT --baud $UPLOAD_SPEED read_mac
if [[ $? -ne 0 ]]; then
    echo "$RED ######################## $VENDOR ERROR MAC INFO ########################### $NORMAL"
    exit 1
fi
echo "$GREEN ############################ $VENDOR MAC INFO ############################# $NORMAL"
}

# Очистка чипа
chip_erase() {
sleep 1
echo "$GREEN ############################ ERASE FLASH $VENDOR ############################### $NORMAL $RED"
$ESPTOOL --port $SERIAL_PORT --baud $UPLOAD_SPEED erase_flash
echo "$NORMAL"
if [[ $? -ne 0 ]]; then
    echo "$RED ######################## ERROR ERASE FLASH! ########################### $NORMAL"
    exit 1
fi
}

# Запись прошивки
chip_write() {
sleep 1
echo "$GREEN ######################### UPLOAD FIRMWARE INTO $VENDOR ######################### $NORMAL $CYAN"
echo "UPLOAD THE FIRMWARE $FIRMWARE"
$ESPTOOL --port $SERIAL_PORT --baud $UPLOAD_SPEED write_flash --flash_size=detect -fm dio 0 $FIRMWARE
if [[ $? -ne 0 ]]; then
    echo "$RED ######################## ERROR UPLOAD THE FIRMWARE! ########################### $NORMAL"
    exit 1
fi
echo "$GREEN ########################### UPLOAD INTO $VENDOR DONE ############################ $NORMAL"
}

# Запись последней скомпилированной прошивки
latest_write() {
    ## Получаем информацию где запушен скрипт
    #DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    ## Получаем информацию о последней директории
    #LATEST=$(echo $DIR | awk -F'/' '{print $NF}')
    ## Получаем информацию о родительской диретории
    #HOMEDIR=$(echo $DIR | sed "s/$LATEST//g")
    ## Получаем информацию о последней прошивке в диретории
    FIRMWARE=$(ls $PWD/$ESPSDK_FIRMWARE | grep bin | tail -n 1)
    # Формируем путь к последней прошивке
    FIRMWARE="$PWD/$ESPSDK_FIRMWARE/$FIRMWARE"
    # Записываем последнюю прошивку в микроконтроллер
    chip_write
}

case $1 in
    "--id" )
          id_board ;;
    "--fid" )
          flash_board ;;
    "--mac" )
          mac_board ;;
    "--erase" )
          chip_erase ;;
    "--latest_write" )
          latest_write ;;
    "--write" )
          FIRMWARE=$2
          echo "UPLOAD FIRMWARE $FIRMWARE"
          chip_write ;;
    "--erase_write" )
          FIRMWARE=$2
          chip_erase
          echo "UPLOAD FIRMWARE $FIRMWARE"
          chip_write ;;
    "--pyserial" )
          pyserial_ ;;
    "--minicom" )
          minicom_ ;;
    "--help" )
          echo "$GREEN ############################ HELP ############################ $NORMAL $CYAN"
          echo "$0 --pyserial      | Moнитор порта UART PYSERIAL"
          echo "$0 --minicom       | Moнитор порта UART MINICOM"
      #     echo "$0 --erase         | Очистка $VENDOR"
      #     echo "$0 --write         | Только запись прошивки, необходимо передать имя прошивки"
          echo "$0 --latest_write  | Запись последней прошивки"
      #     echo "$0 --erase_write   | Очистка $VENDOR и запись новой прошивки, необходимо передать имя прошивки"
          echo "$0 --id            | Информация об ID $VENDOR"
      #     echo "$0 --fid           | ID Flash $VENDOR"
      #     echo "$0 --mac           | MAC адрес $VENDOR"
          echo "$0 --help          | Справка по работе со скриптом"
          echo "$GREEN ############################################################## $NORMAL" ;;
     *)
          echo "$GREEN ######################################################## $NORMAL"
          echo "Для получения информации по работе со скриптом $0 --help"
          echo "$GREEN ############################################################## $NORMAL" ;;
esac
