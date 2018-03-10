#!/usr/bin/env bash
# maintained by: Michael J. Stealey <michael.j.stealey@gmail.com>

# build singularity.rpm:latest image
cd $(dirname $(pwd))/singularity-packages/centos-7
docker build -t singularity.rpm:latest .
cd -

# create .rpm files in local rpms directory
if [[ ! -d $(pwd)/rpms ]]; then
  mkdir -p $(pwd)/rpms
fi
docker run --rm \
	-e SINGULARITY_VERSION=2.4.2 \
	-v $(pwd)/rpms:/packages \
	singularity.rpm:latest

# list packages
echo "INFO: packages have been built sucessfully"
ls -alh $(pwd)/rpms | grep singularity

exit 0;
