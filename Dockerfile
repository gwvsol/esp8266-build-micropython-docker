######################################################################
##
## STAGE 1: Build xtensa toolchain
##

FROM debian:buster

ENV ESP_OPEN_SDK=https://github.com/pfalcon/esp-open-sdk.git
ENV MICROPYTHON=https://github.com/micropython/micropython.git
ENV NEWLIB=https://gsdview.appspot.com/nativeclient-mirror/toolchain/newlib/newlib-2.0.0.tar.gz
ENV NCURSES=http://gnu.mirrors.pair.com/ncurses/ncurses-6.0.tar.gz
ENV MPFR=https://www.mpfr.org/mpfr-3.1.3/mpfr-3.1.3.tar.xz
ENV MPC=https://toolchains.bootlin.com/downloads/releases/sources/mpc-1.0.3/mpc-1.0.3.tar.gz
ENV ISL=https://gcc.gnu.org/pub/gcc/infrastructure/isl-0.14.tar.bz2
ENV GMP=https://ftp.gnu.org/gnu/gmp/gmp-6.0.0a.tar.xz
ENV GBL=https://ftp.gnu.org/gnu/gdb/gdb-7.10.tar.xz
ENV EXPAT=http://repository.timesys.com/buildsources/e/expat/expat-2.1.0/expat-2.1.0.tar.gz
ENV CLOOG=http://www.bastoul.net/cloog/pages/download/cloog-0.18.4.tar.gz
ENV BINUTILS=https://ftp.gnu.org/gnu/binutils/binutils-2.25.1.tar.bz2
ENV GCC=https://ftp.gnu.org/gnu/gcc/gcc-4.8.5/gcc-4.8.5.tar.bz2

ARG USER
ENV USER=${USER:-work}
ARG USER_ID
ENV USER_ID=${USER_ID:-1000}

ENV SHELL=/bin/bash

ENV TOOLS=tools

ENV HOME_DIR=/home/${USER}

RUN groupadd --gid ${USER_ID} ${USER} \
    && useradd --uid ${USER_ID} --gid ${USER} --shell ${SHELL} --create-home ${USER}

RUN set -eux \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y python python-dev python-pip \
           python3 python3-dev python3-pip \
           autoconf automake libtool libtool-bin gperf \
           flex bison texinfo gawk libncurses5-dev libexpat1-dev \
           sed git help2man wget unzip bzip2 unrar-free \
    && pip3 install setuptools esptool

COPY script/Makefile.Fix-build-errors-with-bash-4.patch /tmp

USER ${USER}
WORKDIR ${HOME_DIR}

RUN git clone --recursive ${ESP_OPEN_SDK} ${TOOLS} \
    && cd ${HOME_DIR}/${TOOLS} \
    && mkdir -p crosstool-NG/.build/tarballs \
    && cd crosstool-NG/.build/tarballs \
    && wget ${NEWLIB} && wget ${NCURSES} && wget ${MPFR} \
    && wget ${MPC} && wget ${ISL} && wget ${GMP} && wget ${GBL} \
    && wget ${EXPAT} && wget ${CLOOG} && wget ${BINUTILS} && wget ${GCC}

RUN cd ${HOME_DIR}/${TOOLS} \
    && patch Makefile /tmp/Makefile.Fix-build-errors-with-bash-4.patch \
    && make STANDALONE=y

RUN cd ${HOME_DIR} \
    && git clone ${MICROPYTHON} \
    && ln -s micropython/ports/esp8266 . \
    && cd micropython \
    && make -C mpy-cross

######################################################################
##
## STAGE 2: This is the final image
##

FROM debian:buster
LABEL maintainer="Mikhail Fedorov" email="jwvsol@yandex.ru"
LABEL version="latest"

ENV MICROPYTHON=https://github.com/micropython/micropython.git

ARG USER
ENV USER=${USER:-work}
ARG USER_ID
ENV USER_ID=${USER_ID:-1000}

ENV TOOLS=tools

ARG TIMEZONE
ENV TIMEZONE=${TIMEZONE:-Europe/Moscow}

ENV SHELL=/bin/bash
ENV HOME_DIR=/home/${USER}

RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo $TIMEZONE > /etc/timezone

RUN groupadd --gid ${USER_ID} ${USER} \
    && useradd --uid ${USER_ID} --gid ${USER} --shell ${SHELL} --create-home ${USER}

RUN set -eux \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y python python3 python3-pip \
           python-serial python3-serial autoconf automake \
           git libtool libtool-bin && pip3 install esptool

COPY --from=0 ${HOME_DIR}/${TOOLS}/xtensa-lx106-elf /usr/local/xtensa-lx106-elf
COPY --from=0 ${HOME_DIR}/micropython/mpy-cross/mpy-cross /usr/local/bin/mpy-cross
COPY script/build.sh /usr/local/bin/
COPY script/entrypoint.sh /usr/local/bin/

ENV PATH=/usr/local/xtensa-lx106-elf/bin:$PATH

USER ${USER}
WORKDIR ${HOME_DIR}

RUN cd ${HOME_DIR} \
    && git clone ${MICROPYTHON} \
    && ln -s micropython/ports/esp8266 . \
    && cd micropython \
    && git submodule update --init

ENTRYPOINT ["entrypoint.sh"]
