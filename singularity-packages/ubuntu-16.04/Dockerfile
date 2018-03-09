FROM ubuntu:16.04
MAINTAINER Michael J. Stealey <michael.j.stealey@gmail.com>

ENV SINGULARITY_VERSION=2.4.2

RUN apt-get update && apt-get install -y \
  build-essential \
  libtool \
  autotools-dev \
  automake \
  autoconf \
  git \
  debhelper \
  dh-autoreconf \
  help2man \
  python

WORKDIR /

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
VOLUME ["/packages"]

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["ls", "-alh", "/packages"]
