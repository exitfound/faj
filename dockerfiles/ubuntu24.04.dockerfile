FROM ubuntu:24.04 AS molecule-image

LABEL maintainer="Ivan Medaev"

ENV PIP_PACKAGES="ansible"

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get -y install --no-install-recommends \
    apt-utils \
    build-essential \
    locales \
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    software-properties-common \
    systemd \
    && pip3 install --no-cache-dir --upgrade pip --break-system-packages \
    && pip3 install --no-cache-dir $PIP_PACKAGES --break-system-packages \ 
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /tmp/* /var/tmp/* \
    && locale-gen en_US.UTF-8

RUN rm -f /lib/systemd/system/systemd*udev* \
    && rm -f /lib/systemd/system/getty.target

CMD ["/lib/systemd/systemd"]
