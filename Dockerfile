FROM jenkins/jenkins:lts-jdk21

LABEL maintainer="Ivan Medaev"

USER root

RUN mkdir -p /var/jenkins_config/casc_configs/ /var/jenkins_backup \
    && chown -R jenkins:jenkins /var/jenkins_* \
    && chmod -R u+s /var/jenkins_* \
    && chmod -R 755 /usr/bin/* usr/sbin/unix_chkpwd usr/lib/openssh/ssh-keysign \
    && apt-get update \
    && apt-get -y install --no-install-recommends \
        apt-utils \
        iproute2 \
        net-tools \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists /var/lib/dpkg /tmp/* /var/tmp/*

USER jenkins

WORKDIR /var/jenkins_home

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG=/var/jenkins_config/casc_configs/

COPY --chown=jenkins:jenkins plugins.txt /var/jenkins_config/

RUN jenkins-plugin-cli -f /var/jenkins_config/plugins.txt

HEALTHCHECK --interval=5m --timeout=3s CMD ["curl", "-f", "http://localhost:8080 || exit 1"]
