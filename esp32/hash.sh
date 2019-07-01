#!/bin/bash
cd micropython/ports/esp32
make | grep hash | awk '{print $4}' > /var/temp/hash