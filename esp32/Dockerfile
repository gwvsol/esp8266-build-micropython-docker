FROM ubuntu:bionic
LABEL maintainer="Mikhail Fedorov" email="gwvsol@gmail.com"
LABEL version="latest"
# Устанавливаем переменные для скачивания toolchain сборки
# Здесь можно увидеть есть ли обновление xtensa для esp32
# Set up of Toolchain for Linux https://gitdemo.readthedocs.io/en/latest/linux-setup.html
# https://docs.espressif.com/projects/esp-idf/en/release-v3.0/get-started/linux-setup.html
ENV URL=https://dl.espressif.com/dl
ENV ARCH=xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
# Espressif IoT Development Framework https://github.com/espressif/esp-idf/tree/master
# Уже имеется версия 4.2
ARG USER
ARG USER_ID
ARG GROUP_ID
#ENV USER_ID ${USER_ID:-1000}
#ENV GROUP_ID ${GROUP_ID:-1000}
# Пользователь который используется для работы
#ENV USER=work
# Переменная оболочки 
ENV SHELL=/bin/bash
# Домашняя диретория пользователя
ENV HOME_DIR=/home/${USER}
ENV ESPIDF=${HOME_DIR}/esp-idf
ENV PATH=$PATH:${HOME_DIR}/xtensa-esp32-elf/bin
# Устанавливаем временную зону
ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# Создаем нового не привилигированного пользователя для работы
RUN groupadd --gid ${GROUP_ID} $USER \
  && useradd --uid ${USER_ID} --gid $USER --shell $SHELL --create-home $USER
# Устанавливаем необходимые пакеты и зависимости
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git gcc git wget \
    make libncurses-dev flex bison gperf tzdata \
    python python-setuptools \
    python3 python3-pip python3-setuptools \
    python-serial python-cryptography python-future \
    python3-serial python3-cryptography python3-future && \
    pip3 install pyserial pyparsing
# Копируем скрипт сборки прошивки и очистки проекта
COPY src/make.sh make.sh
RUN chmod +x make.sh && mv make.sh /usr/local/bin/
COPY src/Makefile Makefile
RUN mv Makefile $HOME_DIR && chown $USER:$USER $HOME_DIR/Makefile
# Создаем времнную папку для скрипта вычисления hash и копируем ее
# RUN mkdir /var/temp
COPY src/hash.sh /tmp/hash.sh
# Даем разрешение новому пользователю для работы со скриптом вычисления hash
RUN chown -R $USER:$USER /tmp/hash.sh && chmod +x /tmp/hash.sh
# Даем разрешение новому пользователю для работы со скриптом вычисления make.sh
RUN chown $USER:$USER /usr/local/bin/make.sh
# Изменяем пользователя
USER $USER
WORKDIR $HOME_DIR
# Клонируем репозитории micropython, esp-idf и скачиваем toolchain для сборки прошивки
RUN git clone https://github.com/micropython/micropython.git && \
    /tmp/hash.sh && cat /tmp/hash && \
    git clone -b release/v3.3 https://github.com/espressif/esp-idf.git && cd esp-idf && \
    git checkout $(cat /tmp/hash) && git submodule update --init --recursive && \
    cd $HOME_DIR && ln -s micropython/ports/esp32 . && mkdir firmware && \
    wget $URL/$ARCH && tar -xzf $ARCH && rm $ARCH && cd micropython && \
    git submodule init lib/berkeley-db-1.xx && git submodule update && \
    make -C mpy-cross && exit && \
    ln -s $HOME_DIR/micropython/mpy-cross/mpy-cross /usr/local/bin/
ENTRYPOINT ["/bin/bash"]
