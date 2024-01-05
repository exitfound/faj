FROM jenkins/jenkins:lts-jdk11

LABEL maintainer="Ivan Medaev"

USER root

RUN mkdir -p /var/jenkins_config/casc_configs/ /var/jenkins_backup \
    && chown -R jenkins:jenkins /var/jenkins_home /var/jenkins_config /var/jenkins_backup \
    && apt-get update \
    && apt-get -y install --no-install-recommends \
        apt-utils \
        net-tools \
        iproute2 \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt /var/lib/dpkg /tmp/* /var/tmp/*

USER jenkins

WORKDIR /var/jenkins_home

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG=/var/jenkins_config/casc_configs/

COPY --chown=jenkins:jenkins plugins.txt /var/jenkins_config/

RUN jenkins-plugin-cli -f /var/jenkins_config/plugins.txt
