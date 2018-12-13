FROM centos:7
MAINTAINER Michael J. Stealey <michael.j.stealey@gmail.com>

# Release versions: https://github.com/sylabs/singularity/releases
ENV SINGULARITY_VERSION=2.6.1

RUN yum -y install \
  epel-release \
  git \
  libarchive-devel \
  && yum -y groupinstall "Development Tools"

WORKDIR /

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
VOLUME ["/packages"]

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["ls", "-alh", "/packages"]
