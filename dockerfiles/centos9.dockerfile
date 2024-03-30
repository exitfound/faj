FROM dokken/centos-stream-9:main AS molecule-image

LABEL maintainer="Ivan Medaev"

ENV PIP_PACKAGES="ansible"

COPY jenkins /etc/sudoers.d/jenkins

WORKDIR /lib/systemd/system/sysinit.target.wants/

RUN yum install -y dnf-plugins-core \
    && dnf config-manager --set-enabled crb \
    && dnf update -y \
    && dnf install -y \
    epel-release \
    epel-next-release \
    python3-devel \
    python3-pip \
    python3-wheel \
    systemd \
    && pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir $PIP_PACKAGES \
    && yum clean all \
    && rm -rf /usr/share/doc \
    && rm -rf /usr/share/man

RUN groupadd -g 1000 -f jenkins \
    && useradd -g 1000 -G jenkins -d /home/jenkins/ jenkins \
    && (for i in *; do [ "$i" = systemd-tmpfiles-setup.service ] || rm -f "$i"; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

CMD ["/usr/lib/systemd/systemd"]
