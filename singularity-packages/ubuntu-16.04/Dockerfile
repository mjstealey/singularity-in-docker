FROM ubuntu:16.04
MAINTAINER Michael J. Stealey <michael.j.stealey@gmail.com>

# Release versions: https://github.com/sylabs/singularity/releases
ENV SINGULARITY_VERSION=2.6.1

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
  python \
  libarchive-dev

WORKDIR /

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
VOLUME ["/packages"]

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["ls", "-alh", "/packages"]
