#!/usr/bin/env bash
set -e

version=${SINGULARITY_VERSION}

git clone https://github.com/singularityware/singularity.git
cd singularity
git checkout tags/${version} -b ${version}
mkdir m4
./autogen.sh
./configure
make dist
rpmbuild -ta singularity-*.tar.gz

cp /root/rpmbuild/RPMS/x86_64/*.rpm /packages

exec "$@"

exit 0;
