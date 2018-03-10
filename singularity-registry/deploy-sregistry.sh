#!/usr/bin/env bash
# maintained by: Michael J. Stealey <michael.j.stealey@gmail.com>

_update_settings_py() {
  local OUTFILE=$(pwd)/sregistry/shub/settings/secrets.py
  cp $(pwd)/sregistry/shub/settings/dummy_secrets.py $OUTFILE
  if [[ $machine == "macOS" ]]; then
    sed -i "" \
      -e "s/#SECRET_KEY.*/SECRET_KEY = '${SECRET_KEY}'/" \
      $OUTFILE
  elif [[ $machine == "Linux" ]]; then
    sed -i \
      "s/#SECRET_KEY.*/SECRET_KEY = '${SECRET_KEY}'/" \
      $OUTFILE
  fi
}

_update_config_py() {
  local OUTFILE=$(pwd)/sregistry/shub/settings/config.py
  if [[ $machine == "macOS" ]]; then
    sed -i "" \
      -e "s/ENABLE_GOOGLE_AUTH=.*/ENABLE_GOOGLE_AUTH=${ENABLE_GOOGLE_AUTH}/" \
      -e "s/ENABLE_TWITTER_AUTH=.*/ENABLE_TWITTER_AUTH=${ENABLE_TWITTER_AUTH}/" \
      -e "s/ENABLE_GITHUB_AUTH=.*/ENABLE_GITHUB_AUTH=${ENABLE_GITHUB_AUTH}/" \
      -e "s/ENABLE_GITLAB_AUTH=.*/ENABLE_GITLAB_AUTH=${ENABLE_GITLAB_AUTH}/" \
      -e "s~DOMAIN_NAME =.*~DOMAIN_NAME = \"${DOMAIN_NAME}\"~" \
      -e "s~DOMAIN_NAME_HTTP =.*~DOMAIN_NAME_HTTP = \"${DOMAIN_NAME_HTTP}\"~" \
      -e "s/ADMINS =.*/ADMINS = (( '${ADMINS_USER}', '${ADMINS_MAIL}'),)/" \
      -e "s/HELP_CONTACT_EMAIL =.*/HELP_CONTACT_EMAIL = '${HELP_CONTACT_EMAIL}'/" \
      -e "s~HELP_INSTITUTION_SITE =.*~HELP_INSTITUTION_SITE = '${HELP_INSTITUTION_SITE}'~" \
      -e "s/REGISTRY_NAME =.*/REGISTRY_NAME = \"${REGISTRY_NAME}\"/" \
      -e "s/REGISTRY_URI =.*/REGISTRY_URI = \"${REGISTRY_URI}\"/" \
      -e "s/USER_COLLECTIONS =.*/USER_COLLECTIONS = ${USER_COLLECTIONS}/" \
      -e "s/PRIVATE_ONLY =.*/PRIVATE_ONLY = ${PRIVATE_ONLY}/" \
      -e "s/DEFAULT_PRIVATE =.*/DEFAULT_PRIVATE = ${DEFAULT_PRIVATE}/" \
      $OUTFILE
  elif [[ $machine == "Linux" ]]; then
    sed -i \
      "s/ENABLE_GOOGLE_AUTH=.*/ENABLE_GOOGLE_AUTH=${ENABLE_GOOGLE_AUTH}/;
      s/ENABLE_TWITTER_AUTH=.*/ENABLE_TWITTER_AUTH=${ENABLE_TWITTER_AUTH}/;
      s/ENABLE_GITHUB_AUTH=.*/ENABLE_GITHUB_AUTH=${ENABLE_GITHUB_AUTH}/;
      s/ENABLE_GITLAB_AUTH=.*/ENABLE_GITLAB_AUTH=${ENABLE_GITLAB_AUTH}/;
      s~DOMAIN_NAME =.*~DOMAIN_NAME = \"${DOMAIN_NAME}\"~;
      s~DOMAIN_NAME_HTTP =.*~DOMAIN_NAME_HTTP = \"${DOMAIN_NAME_HTTP}\"~;
      s/ADMINS =.*/ADMINS = (( '${ADMINS_USER}', '${ADMINS_MAIL}'),)/;
      s/HELP_CONTACT_EMAIL =.*/HELP_CONTACT_EMAIL = '${HELP_CONTACT_EMAIL}'/;
      s~HELP_INSTITUTION_SITE =.*~HELP_INSTITUTION_SITE = '${HELP_INSTITUTION_SITE}'~;
      s/REGISTRY_NAME =.*/REGISTRY_NAME = \"${REGISTRY_NAME}\"/;
      s/REGISTRY_URI =.*/REGISTRY_URI = \"${REGISTRY_URI}\"/;
      s/USER_COLLECTIONS =.*/USER_COLLECTIONS = ${USER_COLLECTIONS}/;
      s/PRIVATE_ONLY =.*/PRIVATE_ONLY = ${PRIVATE_ONLY}/;
      s/DEFAULT_PRIVATE =.*/DEFAULT_PRIVATE = ${DEFAULT_PRIVATE}/" \
      $OUTFILE
  fi
}

_get_machine() {
  local unameOut="$(uname -s)"
  case "${unameOut}" in
      Linux*)     machine=Linux;;
      Darwin*)    machine=macOS;;
      CYGWIN*)    machine=Cygwin;;
      MINGW*)     machine=MinGw;;
      *)          machine="UNKNOWN:${unameOut}"
  esac
  if [[ "$machine" != "macOS" ]] && [[ "$machine" != "Linux" ]]; then
    echo "WARNING: ${machine} platform is unsupported at this time... exiting"
    exit 1;
  else
    echo "INFO: configuring for ${machine}"
  fi
}

### main ###

# source the environment variables
source sregistry.env

# clone sregistry repository
if [[ ! -d sregistry ]]; then
  git clone https://github.com/singularityhub/sregistry.git
else
  echo "INFO: sregistry repository alread exists"
fi

# determine platform
_get_machine

# udpate docker-compose.yml
cp docker-compose.yml sregistry/docker-compose.yml

# update settings.py
_update_settings_py

# update config.py
_update_config_py

# stand up Registry
cd sregistry
docker-compose up -d

exit 0;
