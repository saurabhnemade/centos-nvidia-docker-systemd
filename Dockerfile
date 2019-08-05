FROM centos/systemd

ENV container docker
MAINTAINER The CentOS Project <cloud-ops@centos.org>
RUN yum -y install httpd; yum clean all; systemctl enable httpd.service
RUN systemctl enable systemd-user-sessions.service

# packaging dependencies
RUN yum install -y \
        rpm-build && \
    rm -rf /var/cache/yum/*

# packaging
ARG PKG_VERS
ARG PKG_REV
ARG RUNTIME_VERSION
ARG DOCKER_VERSION

ENV VERSION $PKG_VERS
ENV RELEASE $PKG_REV
ENV DOCKER_VERSION $DOCKER_VERSION
ENV DOCKER_VERSION $DOCKER_VERSION

# output directory
ENV DIST_DIR=/tmp/nvidia-container-runtime-$PKG_VERS/SOURCES
RUN mkdir -p $DIST_DIR /dist

COPY nvidia-docker $DIST_DIR
COPY daemon.json $DIST_DIR

WORKDIR $DIST_DIR/..
COPY rpm .

CMD rpmbuild --clean -bb \
             -D "_topdir $PWD" \
             -D "version $VERSION" \
             -D "release $RELEASE" \
             -D "docker_version $DOCKER_VERSION" \
             -D "runtime_version $RUNTIME_VERSION" \
             SPECS/nvidia-docker2.spec && \
    mv RPMS/noarch/*.rpm /dist




# Following is required for running ssh servcie
RUN yum -y install sudo
RUN yum -y install openssh-server passwd; yum clean all
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh
RUN mkdir /var/run/sshd
RUN ssh-keygen -A
RUN systemctl enable systemd-user-sessions.service

RUN sh /start.sh
EXPOSE 22


#### GPU DEPS ####
RUN yum -y install java-1.8.0-openjdk-headless curl
RUN yum -y install epel-release
RUN yum -y install deltarpm
#RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum -y install kernel-devel-$(uname -r) kernel-headers$(uname -r)
RUN curl -O https://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-10.0.130-1.x86_64.rpm
RUN rpm --install cuda-repo-rhel7-10.0.130-1.x86_64.rpm
RUN yum clean expire-cache
RUN yum -y install cuda-drivers
RUN yum -y install cuda

CMD ["/usr/sbin/init"]
