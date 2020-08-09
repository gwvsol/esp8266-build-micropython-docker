## Build MicroPython for ESP8266 in Docker

![bash-small](https://user-images.githubusercontent.com/13176091/54089754-070c6c00-4375-11e9-8495-d06e9d5f3fe3.png)

Cборка ```FIRMWARE``` ESP8266 выполняется в Docker где используются скрипт ```make.sh```.   

Для сборки Docker, необходимо:

#### Для ESP8266
* [MicroPython port to ESP8266](https://github.com/micropython/micropython/tree/master/ports/esp8266#micropython-port-to-esp8266)
* [SDK for ESP8266/ESP8285 chips](https://github.com/pfalcon/esp-open-sdk)   

Кроме указанных выше зависимостей необходимо установить:    
*Для работы с микроконтроллерами*  
* [esptool GitHub](https://github.com/espressif/esptool)  
  [esptool PyPI](https://pypi.org/project/esptool/)  
  ```bash
  pip3 install esptool
  ```
* [setuptools PyPI](https://pypi.org/project/setuptools/)  
  ```bash
  pip3 install setuptools
  ```
*Для работы монитора порта UART необходим установить*     
* [pySerial PyPI](https://pypi.org/project/pyserial/)  
  [pySerial GitHub](https://github.com/pyserial/pyserial)  
  [pySerial Documentation](https://pyserial.readthedocs.io/en/latest/shortintro.html)   
  ```bash
  pip3 install pyserial
  ```


#### Сборка Docker для ESP8266
```bash
git clone https://github.com/gwvsol/ESP8266-ESP32-Script-to-build-MicroPython.git

cd esp8266

docker build -t esp8266:sdk .
```

#### Использование

```bash
docker run -it --name esp8266 --rm -v $(pwd):/var/fw esp8266:sdk

```

##### Работа со скриптом сборки

```bash
make.sh -h

############################################ HELP ###############################################
/usr/local/bin/make.sh -c  | Очистка SDK
/usr/local/bin/make.sh -m  | Cборка прошивки
/usr/local/bin/make.sh -cm | Очистка SDK и сборка прошивки
/usr/local/bin/make.sh -h  | Справка по работе со скриптом
#################################################################################################

```
#### Запись прошивки 
Для записи прошивки используется скрипт ```tools.sh```

```bash
./tools.sh -h

############################################ HELP ###############################################
./tools.sh -m   | Moнитор порта UART
./tools.sh -e   | Очистка ESP8266
./tools.sh -w   | Только запись прошивки, необходимо передать имя прошивки
./tools.sh -ew  | Очистка ESP8266 и запись новой прошивки, необходимо передать имя прошивки
./tools.sh -i   | Информация об ID ESP8266
./tools.sh -if  | ID Flash ESP8266
./tools.sh -mac | MAC адрес ESP8266
./tools.sh -h   | Справка по работе со скриптом
#################################################################################################

```
Скрипт ```tools.sh``` необходимо разместить в директории проекта.   
Для работы монитора порта UART необходим установить ```pyserial```  

***