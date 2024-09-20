FROM opensuse/leap:15.4 AS molecule-image

LABEL maintainer="Ivan Medaev"

RUN zypper update --no-recommends --force-resolution --no-confirm \
    && zypper install --no-recommends --no-confirm \
        ansible \
        python3-devel \
        python3-pip \
        python3-wheel \
        xz \
        sudo \
        systemd \
    && zypper clean --all \
    && rm -rf /usr/share/doc \
    && rm -rf /usr/share/man

CMD ["/usr/lib/systemd/systemd"]
