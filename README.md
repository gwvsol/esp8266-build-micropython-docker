## Build MicroPython for microcontrollers and ESP8266 ESP32

![bash-small](https://user-images.githubusercontent.com/13176091/54089754-070c6c00-4375-11e9-8495-d06e9d5f3fe3.png)

Для сборки ```firmware``` для ESP32 и ESP8266 используются идентичные скрипты ```makeESP32``` и ```makeESP8266```. Скрипты различаются только параметрами передаваемыми ```esptool.py```. 

Для работы скрипта, необходимо:

#### Для ESP8266
* [MicroPython port to ESP8266](https://github.com/micropython/micropython/tree/master/ports/esp8266#micropython-port-to-esp8266)
* [SDK for ESP8266/ESP8285 chips](https://github.com/pfalcon/esp-open-sdk)

#### Для ESP32
* [MicroPython port to the ESP32](https://github.com/micropython/micropython/tree/master/ports/esp32#micropython-port-to-the-esp32)
* [ESP-IDF](https://github.com/espressif/esp-idf#developing-with-esp-idf)
* [Toolchain](https://docs.espressif.com/projects/esp-idf/en/latest/get-started/linux-setup.html)

А так же ```esptool.py```.
* [esptool](https://github.com/espressif/esptool)

```bash
pip3 install setuptools
pip3 install esptool
```

#### Использование
```bash
############################################ HELP ###############################################
./makeESP32 -om | Только сборка прошивки
./makeESP32 -mw | Cборка прошивки, очистка контроллера и запись новой прошивки
./makeESP32 -ow | Только очистка контроллера и запись прошивки, необходимо передать имя прошивки
./makeESP32 --help | Справка по работе со скриптом
#################################################################################################
```
```bash
############################################ HELP ###############################################
./makeESP8266 -om | Только сборка прошивки
./makeESP8266 -mw | Cборка прошивки, очистка контроллера и запись новой прошивки
./makeESP8266 -ow | Только очистка контроллера и запись прошивки, необходимо передать имя прошивки
./makeESP8266 --help | Справка по работе со скриптом
#################################################################################################
```
Для настройки скрипта необходимо отредактировать:

##### Для ESP8266

```bash
v="ESP8266"                                                     # Название проекта
export PATH=$PATH:/var/data/esp-open-sdk/xtensa-lx106-elf/bin   # Расположение SDK для ESP8266
sdk='/var/data/micropython/ports/esp8266'                       # Расположение MicroPython для ESP8266
```
#### Для ESP32

```bash
v="ESP32"   # Название проекта
export ESPIDF=/var/data/esp-idf                     # Расположение ESP-IDF
export PATH=$PATH:/var/data/xtensa-esp32-elf/bin    # Расположение Toolchain для ESP32
sdk='/var/data/micropython/ports/esp32'             # Расположение MicroPython для ESP32
```

