FROM debian:10-slim
LABEL maintainer="Mikhail Fedorov" email="jwvsol@yandex.ru"
LABEL version="latest"

ARG USER
ARG USER_ID

ENV USER=${USER:-work}
ENV USER_ID=${USER_ID:-1000}

ARG TIMEZONE
ENV TIMEZONE=${TIMEZONE:-Europe/Moscow}

ENV SHELL=/bin/bash

ENV HOME_DIR=/home/${USER}

RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo $TIMEZONE > /etc/timezone

RUN groupadd --gid ${USER_ID} ${USER} \
    && useradd --uid ${USER_ID} --gid ${USER} --shell ${SHELL} --create-home ${HOME_DIR}

RUN set -eux \
    && apt update \
    && apt upgrade -y \
    && apt install -y python python-dev python-serial python-pip \
           python3 python3-dev python3-serial python3-pip \
           autoconf automake libtool libtool-bin gperf \
           flex bison texinfo gawk libncurses5-dev libexpat1-dev \
           sed git help2man wget unzip bzip2 unrar-free \
    && pip3 install setuptools esptool

# Копируем скрипт сборки прошивки и очистки проекта
# COPY src/make.sh make.sh
# RUN chmod +x make.sh && mv make.sh /usr/local/bin/
# COPY src/Makefile Makefile

# Даем разрешение новому пользователю для работы со скриптом вычисления make.sh
RUN chown $USER:$USER /usr/local/bin/make.sh
RUN mv Makefile $HOME_DIR && chown $USER:$USER $HOME_DIR/Makefile
# Изменяем пользователя
USER $USER
WORKDIR $HOME_DIR
# Клонируем репозитории micropython, скачиваем esp-open-sdk и собираем toolchain для сборки прошивки
RUN git clone --recursive https://github.com/pfalcon/esp-open-sdk.git && \
    cd esp-open-sdk && make STANDALONE=y && cd $HOME_DIR && \
    git clone https://github.com/micropython/micropython.git && \
    ln -s micropython/ports/esp8266 . && cd micropython && \
    git submodule update --init && make -C mpy-cross && exit && \
    ln -s $HOME_DIR/micropython/mpy-cross/mpy-cross /usr/local/bin/
ENTRYPOINT ["/bin/bash"]
