FROM centos:centos8 AS molecule-image

LABEL maintainer="Ivan Medaev"

WORKDIR /app

COPY requirements.txt .

RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-* \
    && sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-* \
    && yum update -y \
    && yum install -y \
        epel-release \
        iproute \
        policycoreutils \
        python3-devel \
        python3-pip \
        python3-wheel \
        selinux-policy-devel \
        selinux-policy-targeted \
        sudo \
        systemd \
    && yum clean all \
    && pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir --user -r requirements.txt \
    && rm -rf /usr/share/doc \
    && rm -rf /usr/share/man

CMD ["/usr/lib/systemd/systemd"]
