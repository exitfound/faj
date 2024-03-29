FROM opensuse/leap:15.4 AS molecule-image

LABEL maintainer="Ivan Medaev"

ENV PIP_PACKAGES="ansible"

COPY jenkins /etc/sudoers.d/jenkins

RUN zypper install -y python3-devel \
    python3-pip \
    python3-wheel \
    xz \
    systemd \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir $PIP_PACKAGES \
    && zypper clean --all \
    && rm -rf /usr/share/doc \
    && rm -rf /usr/share/man

RUN groupadd -g 1000 -f jenkins \
    && useradd -g 1000 -G jenkins -d /home/jenkins/ jenkins

CMD ["/usr/lib/systemd/systemd"]
