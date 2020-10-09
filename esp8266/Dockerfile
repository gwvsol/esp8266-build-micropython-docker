FROM ubuntu:18.04
LABEL maintainer="Mikhail Fedorov" email="gwvsol@gmail.com"
LABEL version="latest"
ARG USER
ARG USER_ID
ARG GROUP_ID
# Переменная оболочки 
ENV SHELL=/bin/bash
# Домашняя диретория пользователя
ENV HOME_DIR=/home/${USER}
ENV PATH=$PATH:${HOME_DIR}/esp-open-sdk/xtensa-lx106-elf/bin
# Устанавливаем временную зону
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
# Копируем скрипт сборки прошивки и очистки проекта
COPY src/make.sh make.sh
RUN chmod +x make.sh && mv make.sh /usr/local/bin/
COPY src/Makefile Makefile
# Создаем нового не привилигированного пользователя для работы с sdk
RUN groupadd --gid ${GROUP_ID} $USER \
  && useradd --uid ${USER_ID} --gid $USER --shell $SHELL --create-home $USER
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
