## Build MicroPython for esp8266 in Docker   
---  

Assembling ```FIRMWARE``` the ```ESP8266``` in Docker    

Dependencies:  

[MicroPython port to ESP8266](https://github.com/micropython/micropython/tree/master/ports/esp8266#micropython-port-to-esp8266)  
[SDK for ESP8266/ESP8285 chips](https://github.com/pfalcon/esp-open-sdk)    
[esptool GitHub](https://github.com/espressif/esptool)  
[esptool PyPI](https://pypi.org/project/esptool/)  
[setuptools PyPI](https://pypi.org/project/setuptools/)      
[pySerial PyPI](https://pypi.org/project/pyserial/)  
[pySerial GitHub](https://github.com/pyserial/pyserial)  
[pySerial Documentation](https://pyserial.readthedocs.io/en/latest/shortintro.html)   

### Using with a pre-assembled Docker image    
```bash
git clone https://github.com/gwvsol/esp8266-Build-MicroPython-in-Docker.git esp8266sdk

cd esp8266sdk

docker pull gwvsol/esp8266sdk

docker tag gwvsol/esp8266sdk:latest esp8266sdk:latest
```

### Building an SDK image in Docker
```bash
git clone https://github.com/gwvsol/esp8266-Build-MicroPython-in-Docker.git esp8266sdk

cd esp8266sdk

make build-img
```

### Using

```bash
drwxr-xr-x 2 work work 4096 авг  9 21:07 firmware
drwxr-xr-x 3 work work 4096 авг  9 11:19 src
```

Modules and libraries that need to be included in the firmware must be placed in the directory ```src```  
The assembled firmware will be in the directory ```firmware```  

```bash
make build-img - Building a Docker
make build-firmware - Firmware build for esp8266
make remove - Deleting a Docker image
make start - Start of Docker
make info - Information about the esp8266
make upload - Loading firmware to the esp8266
make clean - Cleaning the esp8266
make pyserial - Monitoring the operation of via pyserial
make minicom - Monitoring the operation of via minicon
```

### Firmware Assembly

```bash
make build-firmware - Firmware build for esp8266
```

### Writing firmware to esp8266, etc

```bash
make info - Information about the esp8266
make upload - Loading firmware to the esp8266
make clean - Cleaning the esp8266
make pyserial - Monitoring the operation of via pyserial
make minicom - Monitoring the operation of via minicon
```

***