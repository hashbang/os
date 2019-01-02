FROM ubuntu:cosmic

MAINTAINER Hashbang Team <team@hashbang.sh>

ENV HOME=/home/build
ENV PATH=/opt/android/scripts:/home/build/out/host/linux-x86/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ARG DEBIAN_FRONTEND=noninteractive

RUN \
    useradd -G plugdev,sudo -ms /bin/bash build && \
    apt-get update && \
    apt-get install -y \
        vim \
        repo \
        aapt \
        sudo \
        openjdk-8-jdk \
        android-tools-adb \
        bc \
        bsdmainutils \
        cgpt \
        bison \
        build-essential \
        curl \
        flex \
        git \
        g++-multilib\
        gcc-multilib\
        gnupg \
        gperf\
        imagemagick \
        lib32ncurses5-dev \
        lib32readline-dev \
        lib32z1-dev \
        liblz4-tool \
        libncurses5-dev \
        libsdl1.2-dev \
        libssl-dev \
        libwxgtk3.0-dev \
        libxml2 \
        libxml2-utils \
        lzop \
        libfaketime \
        pngcrush \
        python3 \
        python3-git \
        python3-yaml \
        rsync \
        schedtool \
        squashfs-tools \
        xsltproc \
        yasm \
        zip \
        zlib1g-dev \
        wget \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && echo "[color]\nui = auto\n[user]\nemail = aosp@null.com\nname = AOSP User" >> /etc/gitconfig

USER build
WORKDIR /home/build

ADD . /opt/android/

CMD [ "/bin/bash", "/usr/local/bin/build.sh" ]
