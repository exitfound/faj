FROM centos:centos8 AS molecule-image

LABEL maintainer="Ivan Medaev"

COPY requirements.txt .

RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-* \
    && sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-* \
    && yum update -y \
    && yum install -y \
        ansible \
        epel-release \
        policycoreutils \
        python3-devel \
        python3-pip \
        selinux-policy-devel \
        selinux-policy-targeted \
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
