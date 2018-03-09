FROM centos:7
MAINTAINER Michael J. Stealey <michael.j.stealey@gmail.com>

ENV SINGULARITY_VERSION=2.4.2

RUN yum -y install \
  epel-release \
  git \
  && yum -y groupinstall "Development Tools"

WORKDIR /

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
VOLUME ["/packages"]

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["ls", "-alh", "/packages"]
