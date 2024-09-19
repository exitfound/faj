FROM debian:buster AS molecule-image

LABEL maintainer="Ivan Medaev"

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get -y install --no-install-recommends \
        ansible \
        apt-utils \
        build-essential \
        locales \
        python3-apt \
        python3-dev \
        sudo \
        systemd \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /tmp/* /var/tmp/* \
    && locale-gen en_US.UTF-8 \
    && rm -f /lib/systemd/system/systemd*udev* \
    && rm -f /lib/systemd/system/getty.target

CMD ["/lib/systemd/systemd"]
