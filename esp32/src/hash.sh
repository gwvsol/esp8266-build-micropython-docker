#!/bin/bash
cd micropython/ports/esp32
#make | grep hash | awk '{print $4}' > /tmp/hash
# Имеется версия 4.0 bete, но с ней работает не стабильно
# Используем пока версию 3.3
make | grep 'hash (v3.3)' | awk '{print $5}' > /tmp/hash