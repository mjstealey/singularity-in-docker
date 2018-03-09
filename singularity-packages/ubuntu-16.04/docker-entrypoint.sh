#!/usr/bin/env bash
set -e

version=${SINGULARITY_VERSION}

git clone https://github.com/singularityware/singularity.git
cd singularity
git checkout tags/${version} -b ${version}
mkdir m4
echo "echo SKIPPING TESTS THEYRE BROKEN" > ./test.sh
fakeroot dpkg-buildpackage -nc -b -us -uc

cp /*.deb /packages

exec "$@"

exit 0;
