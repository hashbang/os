FROM ubuntu:cosmic

MAINTAINER Hashbang Team <team@hashbang.sh>

ENV HOME=/home/build
ENV PATH=/home/build/scripts:/home/build/out/host/linux-x86/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ARG UID=1000
ARG GID=1000

ARG DEBIAN_FRONTEND=noninteractive

RUN \
    groupadd -g $GID -o build && \
    useradd -G plugdev,sudo -g $GID -u $UID -ms /bin/bash build && \
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
        diffoscope \
        flex \
        git \
        g++-multilib\
        gcc-multilib\
        gnupg \
        gperf\
        imagemagick \
        libncurses5 \
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
        ninja-build \
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
    && echo "[color]\nui = auto\n[user]\nemail = aosp@example.org\nname = AOSP User" >> /etc/gitconfig

ADD ./manifests /home/build/manifests
ADD ./scripts /home/build/scripts
ADD ./patches /home/build/patches
ADD ./configs /home/build/configs

USER build
WORKDIR /home/build

CMD [ "/bin/bash", "/usr/local/bin/build.sh" ]
