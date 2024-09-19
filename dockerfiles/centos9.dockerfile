FROM dokken/centos-stream-9:main AS molecule-image

LABEL maintainer="Ivan Medaev"

RUN yum install -y dnf-plugins-core \
    && dnf config-manager --set-enabled crb \
    && dnf update -y \
    && dnf install -y \
        ansible \
        epel-release \
        epel-next-release \
        python3-devel \
        python3-pip \
        python3-wheel \
        sudo \
        systemd \
    && yum clean all \
    && rm -rf /usr/share/doc \
    && rm -rf /usr/share/man \
    && (for i in ./*; do [ "$i" = systemd-tmpfiles-setup.service ] || rm -f "$i"; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

CMD ["/usr/lib/systemd/systemd"]
