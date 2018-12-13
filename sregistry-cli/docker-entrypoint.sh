#!/usr/bin/env bash
set -e

# allow singularity to sudo run singularity, python3.6 and pip3.6
_sudoers_d() {
  local OUTFILE=/etc/sudoers.d/singularity
  cat > $OUTFILE << EOF
singularity ALL=(root) NOPASSWD: /usr/bin/singularity
singularity ALL=(root) NOPASSWD: /usr/bin/python3.6
singularity ALL=(root) NOPASSWD: /bin/pip3.6
EOF
  chmod 0440 $OUTFILE
}

# create .sregistry file based on ENV variables
_generate_sregistry() {
  local OUTFILE=/home/singularity/.sregistry
  cat > $OUTFILE << EOF
{
  "registry":
  {
    "token": "${REGISTRY_TOKEN}",
    "username": "${REGISTRY_USERNAME}",
    "base": "${REGISTRY_BASE}"
  }
}
EOF
  chown ${USER_UID}:${USER_GID} $OUTFILE
}

_update_uid_gid() {
  # if USER_UID < 1000 or USER_GID < 1000, exit with error message
  if [[ ${USER_UID} < 1000 ]] || [[ ${USER_GID} < 1000 ]]; then
    echo "ERROR: user UID and GID must be > 1000"
    exit 1;
  fi
  # Set USER_UID and USER_GID and update file ownership
  mkdir -p /home/singularity
  usermod -u ${USER_UID} singularity
  groupmod -g ${USER_GID} singularity
  chown -R ${USER_UID}:${USER_GID} /home/singularity
}

### main ###
_sudoers_d
_update_uid_gid
_generate_sregistry

exec "$@"
