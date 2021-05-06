#!/usr/bin/env bash

# common.sh
# Commons scripts and variables

export CLOUD_HOME=$(dirname $(pwd))
export DEVELOP_SERVER="test.project.com"

# Server specific configuration
export PRIMARY_DOMAIN="example.project.com"
export DOMAIN_LIST="$CI_SERVER $NEXUS_SERVER $GIT_SERVER \
$CODE_METRICS_SERVER $TESTING_SERVER"

export CERTSDIR="$CLOUD_HOME/letsencrypt"
export LETSENCRYPT_TMP="$CLOUD_HOME/letsencrypt-tmp"
export LETSENCRYPT_WEB_ROOT="$CLOUD_HOME/letsencrypt-webroot"

AUTH_FOLDER="$CLOUD_HOME/auth"

configure_authentication(){
    read -p "Enter share folder username: " share_user
    echo "Configuring shared folder user password"
    htpasswd -c $HTTP_PASSWORD_FILE $share_user
    chmod 600 $HTTP_PASSWORD_FILE
}

wait_if_error_and_tty() {
  if [[ -t 0 || -t 1 ]] ;
  then
      echo press any key to continue
	  read;
  else
	  true;
  fi
}

create_network() {
    local network=${1:?}
    if ! docker network ls | grep -qw $network; then
       docker network create $network
    fi
}
