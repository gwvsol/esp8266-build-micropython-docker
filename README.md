## Build MicroPython for microcontrollers and ESP8266 ESP32

![bash1](https://user-images.githubusercontent.com/13176091/54089658-f3acd100-4373-11e9-806c-67c8a018e1dd.png)

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

