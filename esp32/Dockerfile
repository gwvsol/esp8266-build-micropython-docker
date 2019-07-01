FROM ubuntu:18.04
MAINTAINER Mikhail Fedorov "gwvsol@gmail.com"
LABEL version="latest"
ENV URL=https://dl.espressif.com/dl
ENV ARCH=xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
RUN apt update && \
    apt upgrade -y && \
    apt install -y git gcc git wget \
    make libncurses-dev flex bison gperf \
    python python-setuptools \
    python3 python3-pip python3-setuptools \
    python-serial python-cryptography python-future \
    python3-serial python3-cryptography python3-future && \
    pip3 install pyserial pyparsing
COPY boot.sh boot.sh
RUN chmod +x boot.sh && mv boot.sh /usr/local/bin/
COPY make.sh make.sh
RUN chmod +x make.sh && mv make.sh /usr/local/bin/
RUN mkdir /var/temp
COPY hash.sh /var/temp/hash.sh
RUN useradd -rm -d /var/data -s /bin/bash -g root -G sudo -u 1000 work
RUN chown -R work:root /var/temp && chmod +x /var/temp/hash.sh
RUN chown work:root /usr/local/bin/make.sh 
USER work
WORKDIR /var/data
RUN git clone https://github.com/micropython/micropython.git && \
    /var/temp/hash.sh && cat /var/temp/hash && \
    git clone https://github.com/espressif/esp-idf.git && cd esp-idf && \
    git checkout $(cat /var/temp/hash) && git submodule update --init --recursive && \
    cd /var/data && ln -s micropython/ports/esp32 . && \
    wget $URL/$ARCH && tar -xzf $ARCH && rm $ARCH && cd micropython && \
    git submodule init lib/berkeley-db-1.xx && git submodule update && \
    make -C mpy-cross && exit && \
    ln -s /var/data/micropython/mpy-cross/mpy-cross /usr/local/bin/
ENTRYPOINT ["boot.sh"]
