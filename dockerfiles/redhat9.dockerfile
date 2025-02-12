FROM redhat/ubi9:latest AS molecule-image

LABEL maintainer="Ivan Medaev"

WORKDIR /app

COPY requirements.txt .

RUN dnf update -y \
    && dnf install -y \
        python3-devel \
        python3-pip \
        python3-wheel \
        sudo \
        systemd \
    && dnf clean all \
    && pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir --user -r requirements.txt \
    && rm -rf /usr/share/doc \
    && rm -rf /usr/share/man

CMD ["/usr/lib/systemd/systemd"]
