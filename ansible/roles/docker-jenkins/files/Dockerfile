FROM jenkins/jenkins:lts-jdk11

LABEL maintainer="Ivan Medaev"

USER root

RUN mkdir -p /var/jenkins_config/casc_configs/ \
    && chown -R jenkins:jenkins /var/jenkins_home /var/jenkins_config \
    && apt-get update \
    && apt-get -y install \
        apt-utils \
        net-tools \
        iproute2 \
        apt-transport-https \
        ca-certificates \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && rm -rf /tmp/* /var/tmp/*

USER jenkins

WORKDIR /var/jenkins_home

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG=/var/jenkins_config/casc_configs/

COPY --chown=jenkins:jenkins plugins.txt /var/jenkins_config/

RUN jenkins-plugin-cli -f /var/jenkins_config/plugins.txt
