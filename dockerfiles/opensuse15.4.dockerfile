FROM opensuse/leap:15.4 AS molecule-image

LABEL maintainer="Ivan Medaev"

RUN zypper install --no-recommends -y \
        ansible \
        python3-devel \
        python3-pip \
        python3-wheel \
        xz \
        sudo \
        systemd \
    && zypper clean --all \
    && rm -rf /usr/share/doc \
    && rm -rf /usr/share/man \
    && groupadd -g 1000 -f jenkins \
    && useradd -g 1000 -G jenkins -d /home/jenkins/ jenkins

CMD ["/usr/lib/systemd/systemd"]
