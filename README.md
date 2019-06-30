## Build MicroPython for microcontrollers and ESP8266 ESP32

![bash-small](https://user-images.githubusercontent.com/13176091/54089754-070c6c00-4375-11e9-8495-d06e9d5f3fe3.png)

Cборка ```firmware``` для ESP32 и ESP8266 выполняется в Docker где используются идентичные скрипты ```make.sh```. Скрипты различаются только параметрами передаваемыми ```esptool.py```.

Для сборки Docker, необходимо:

#### Для ESP8266
* [MicroPython port to ESP8266](https://github.com/micropython/micropython/tree/master/ports/esp8266#micropython-port-to-esp8266)
* [SDK for ESP8266/ESP8285 chips](https://github.com/pfalcon/esp-open-sdk)

#### Для ESP32
* [MicroPython port to the ESP32](https://github.com/micropython/micropython/tree/master/ports/esp32#micropython-port-to-the-esp32)
* [ESP-IDF](https://github.com/espressif/esp-idf#developing-with-esp-idf)
* [Xtensa Toolchain для ESP32](https://docs.espressif.com/projects/esp-idf/en/latest/get-started/linux-setup.html)

А так же ```esptool.py``` и ```setuptools```.

#### Сборка Docker для ESP8266
```bash
git clone https://github.com/gwvsol/ESP8266-ESP32-Script-to-build-MicroPython.git
cd esp8266
docker build -t esp8266:sdk .
```
#### Сборка Docker для ESP32
* На данный момент ```Dockerfile``` для сборки ```Docker``` не создан, планируется создать в будущем

В настоящее время можно использовать версию [v1](https://github.com/gwvsol/ESP8266-ESP32-Script-to-build-MicroPython/tree/v1) скриптов для сборки и прошивки ESP32

#### Использование для ESP8266

```bash
docker run -it --name esp8266 --rm -v $(pwd):/var/fw esp8266:sdk

make.sh -h

############################################ HELP ###############################################
/usr/local/bin/make.sh -m | Очистка от старых сборок и создание новой прошивки
/usr/local/bin/make.sh -h | Справка по работе со скриптом
#################################################################################################

```
Для записи прошивки используется скрипт ```write_erase.sh```

```bash
./write_erase.sh -h

############################################ HELP ###############################################
./write_erase.sh -i  | Информация о контроллере
./write_erase.sh -oe | Только очистка контроллера
./write_erase.sh -ow | Только прошивка, необходимо передать имя прошивки
./write_erase.sh -ew | Очистка контроллера и запись новой прошивки, необходимо передать имя прошивки
./write_erase.sh -h  | Справка по работе со скриптом
#################################################################################################

```
Скрипт необходимо разместить в директории проекта. Выполнить настройки скрипта, по описанию ниже. После чего запустить скрипт, например: ```./write_erase.sh```.

#### Использование для ESP32
На данный момент скрипты для сборки прошивки для ESP32 не созданы. Планируется создать их в будущем.
В настоящее время можно использовать версию [v1](https://github.com/gwvsol/ESP8266-ESP32-Script-to-build-MicroPython/tree/v1) скриптов для сборки и прошивки ESP32