FROM ubuntu:18.04
MAINTAINER Mikhail Fedorov "gwvsol@gmail.com"
LABEL version="latest"
ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update && \
    apt upgrade -y && \
    apt install -y python python-dev python-serial python-pip \
    python3 python3-dev python3-serial python3-pip \
    autoconf automake libtool libtool-bin gperf \
    flex bison texinfo gawk libncurses5-dev libexpat1-dev \
    sed git help2man wget unzip bzip2 unrar-free
RUN pip3 install setuptools && pip3 install esptool
COPY boot.sh boot.sh
RUN chmod +x boot.sh && mv boot.sh /usr/local/bin/
RUN useradd -rm -d /var/data -s /bin/bash -g root -G sudo -u 1000 work
USER work
WORKDIR /var/data
RUN git clone --recursive https://github.com/pfalcon/esp-open-sdk.git && \
    cd esp-open-sdk && make STANDALONE=y
RUN git clone https://github.com/micropython/micropython.git
RUN cd micropython && \
    git submodule update --init && \
    make -C mpy-cross && \
    exit && \
    ln -s /var/data/micropython/mpy-cross/mpy-cross /usr/local/bin/
ENTRYPOINT ["boot.sh"]
