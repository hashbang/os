FROM ubuntu:cosmic

MAINTAINER Hashbang Team <team@hashbang.sh>

# Setup home and paths
ENV HOME=/home/build
ENV PATH=/home/build/scripts:/home/build/out/host/linux-x86/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Default UID/GID unless overridden to match local system
ARG UID=1000
ARG GID=1000

# Make sure debian does not try to ask questions
ARG DEBIAN_FRONTEND=noninteractive

# Add "build" user
RUN groupadd -g $GID -o build
RUN useradd -G plugdev,sudo -g $GID -u $UID -ms /bin/bash build

# Install APT Dependencies
RUN apt-get update
RUN apt-get install -y \
        curl \
        gnupg2 \
        apt-transport-https \
        ca-certificates \
        unzip \
        wget \
        vim \
        repo \
        aapt \
        sudo \
        openjdk-8-jdk \
        android-tools-adb \
        bc \
        bsdmainutils \
        repo \
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
        apt-utils

# Install kubectl
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg \
        | apt-key add -
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" \
        | tee -a /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update
RUN apt-get install -y kubectl

# Install terraform
RUN wget \
        "https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip" \
        -O /tmp/terraform.zip
RUN unzip /tmp/terraform.zip -d /usr/local/bin/

# Install helm/tiller
RUN wget \
        "https://storage.googleapis.com/kubernetes-helm/helm-v2.13.0-linux-amd64.tar.gz" \
        -O /tmp/helm.tar.gz
RUN tar -zxvf /tmp/helm.tar.gz -C /tmp
RUN mv /tmp/linux-amd64/helm /usr/local/bin/
RUN mv /tmp/linux-amd64/tiller /usr/local/bin/

# Allow sudo without password in container
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Setup Detault git config
RUN echo "[color]\nui = auto\n[user]\nemail = aosp@null.com\nname = AOSP User" >> /etc/gitconfig

# Cleanup
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Include current build config for automated builds
ADD ./manifests /home/build/manifests
ADD ./scripts /home/build/scripts
ADD ./patches /home/build/patches
ADD ./config.yml /home/build/config.yml

# Default to "build" user
USER build
WORKDIR /home/build

# Start with a builder script by default
CMD [ "/bin/bash", "/usr/local/bin/build.sh" ]
