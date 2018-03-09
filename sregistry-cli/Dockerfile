FROM krallin/centos-tini:centos7
MAINTAINER Michael J. Stealey <michael.j.stealey@gmail.com>

ENV USER_UID=1000 \
  USER_GID=1000 \
  SINGULARITY_VERSION=2.4.2 \
  PYTHON_VERSION=3.6 \
  REGISTRY_TOKEN='' \
  REGISTRY_USERNAME='' \
  REGISTRY_BASE=''

# set user/group IDs for singularity user account
RUN groupadd -r singularity --gid=$USER_GID \
    && useradd -r -g singularity -d /home/singularity --uid=$USER_UID singularity

# python 3.6
RUN yum -y install \
  yum-utils \
  git \
  sudo \
  which \
  && yum -y group install "Development Tools"
RUN yum -y install \
  https://centos7.iuscommunity.org/ius-release.rpm
RUN yum -y install \
  python36u \
  python36u-pip \
  python36u-devel

# singularity
COPY ./rpms /rpms
RUN yum -y localinstall \
	/rpms/singularity-runtime-2.4.2-1.el7.centos.x86_64.rpm \
	/rpms/singularity-devel-2.4.2-1.el7.centos.x86_64.rpm \
	/rpms/singularity-debuginfo-2.4.2-1.el7.centos.x86_64.rpm \
	/rpms/singularity-2.4.2-1.el7.centos.x86_64.rpm

# sregistry-cli
WORKDIR /home/singularity
RUN git clone -b development \
  https://www.github.com/singularityhub/sregistry-cli.git \
  && cd sregistry-cli \
  && sudo python3.6 setup.py install \
  && sudo pip3.6 install -e .[all]

COPY ./docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR /home/singularity

ENTRYPOINT ["/usr/local/bin/tini", "--", "/docker-entrypoint.sh"]
