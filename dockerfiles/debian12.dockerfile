FROM debian:bookworm AS molecule-image

LABEL maintainer="Ivan Medaev"

ENV PIP_PACKAGES="ansible"

COPY jenkins /etc/sudoers.d/jenkins

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get -y install --no-install-recommends \
    apt-utils \
    build-essential \
    locales \
    python3-dev \
    python3-pip \
    systemd \
    && pip3 install --no-cache-dir --upgrade pip --break-system-packages \
    && pip3 install --no-cache-dir $PIP_PACKAGES --break-system-packages \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt \
    && rm -rf /var/lib/cache \
    && rm -rf /var/lib/dpkg \
    && rm -rf /tmp/* /var/tmp/* \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1000 -f jenkins \
    && useradd -g 1000 -G jenkins -d /home/jenkins/ jenkins \
    && locale-gen en_US.UTF-8 \
    && rm -f /lib/systemd/system/systemd*udev* \
    && rm -f /lib/systemd/system/getty.target

CMD ["/lib/systemd/systemd"]
