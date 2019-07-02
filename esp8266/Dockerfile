FROM ubuntu:18.04
LABEL maintainer="Mikhail Fedorov" email="gwvsol@gmail.com"
LABEL version="latest"
# Устанавливаем временную зону (необходима для пакета unrar-free)
ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# Устанавливаем необходимые пакеты и зависимости
RUN apt update && \
    apt upgrade -y && \
    apt install -y python python-dev python-serial python-pip \
    python3 python3-dev python3-serial python3-pip \
    autoconf automake libtool libtool-bin gperf \
    flex bison texinfo gawk libncurses5-dev libexpat1-dev \
    sed git help2man wget unzip bzip2 unrar-free && \
    pip3 install setuptools && pip3 install esptool
# Копируем скрипт установки переменных окружения и запуска оболочки bash
COPY boot.sh boot.sh
RUN chmod +x boot.sh && mv boot.sh /usr/local/bin/
# Создаем нового не привилигированного пользователя для работы с sdk
RUN useradd -rm -d /var/data -s /bin/bash -g root -G sudo -u 1000 work
# Изменяем пользователя
USER work
WORKDIR /var/data
# Клонируем репозитории micropython, скачиваем esp-open-sdk и собираем toolchain для сборки прошивки
RUN git clone --recursive https://github.com/pfalcon/esp-open-sdk.git && \
    cd esp-open-sdk && make STANDALONE=y && cd /var/data && \
    git clone https://github.com/micropython/micropython.git && \
    ln -s micropython/ports/esp8266 . && cd micropython && \
    git submodule update --init && make -C mpy-cross && exit && \
    ln -s /var/data/micropython/mpy-cross/mpy-cross /usr/local/bin/
ENTRYPOINT ["boot.sh"]
