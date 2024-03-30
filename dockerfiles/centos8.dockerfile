FROM centos:centos8 AS molecule-image

LABEL maintainer="Ivan Medaev"

ENV PIP_PACKAGES="ansible"

WORKDIR /lib/systemd/system/sysinit.target.wants/

COPY jenkins /etc/sudoers.d/jenkins

RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-* \
    && sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-* \
    && rm -rf /usr/share/doc \
    && rm -rf /usr/share/man \
    && yum update -y \
    && yum install -y \
    epel-release \
    policycoreutils \
    python3-devel \
    python3-pip \
    selinux-policy-devel \
    selinux-policy-targeted \
    systemd \
    && yum clean all \
    && pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir $PIP_PACKAGES

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
