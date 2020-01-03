#!/bin/bash
cd micropython/ports/esp32
#make | grep hash | awk '{print $4}' > /var/temp/hash
make | grep 'hash (v3.3)' | awk '{print $5}' > /var/temp/hash