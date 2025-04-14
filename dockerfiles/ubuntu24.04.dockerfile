FROM ubuntu:24.04 AS molecule-image

LABEL maintainer="Ivan Medaev"

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get -y install --no-install-recommends \
    ansible \
    apt-utils \
    bash-completion \
    build-essential \
    iproute2 \
    locales \
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    software-properties-common \
    sudo \
    systemd \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /tmp/* /var/tmp/* \
    && locale-gen en_US.UTF-8 \
    && mkdir /etc/bash_completion.d/ \
    && rm -f /lib/systemd/system/systemd*udev* \
    && rm -f /lib/systemd/system/getty.target

CMD ["/lib/systemd/systemd"]
