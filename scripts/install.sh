#!/usr/bin/env bash

# ./install.sh This script configure a reverse proxy to access other services

# Source commoun variables and functions
source common.sh

recreate_certificates=${1:-"false"}
CONFD_VERSION="0.16.0"
CONFD_URL="https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64"
CONFD_BINARY="confd"
rsa_key_size="4096"

# Create external networks
create_network $TESTING_NET
create_network $CODE_METRICS_NET

# Create auth directory
#echo "Creating proxy auth files"
mkdir -p $CLOUD_HOME/auth

# Create letsencrypt webroot
mkdir -p $LETSENCRYPT_WEB_ROOT

# Create share folder
mkdir -p $CLOUD_HOME/share

# Create dhparm cypher file
mkdir -p $CLOUD_HOME/dhparam/
if [ ! -f $CLOUD_HOME/dhparam/dhparam.pem ]; then
  openssl dhparam -out $CLOUD_HOME/dhparam/dhparam.pem 2048
fi

# Download confd
if [ ! -f $CLOUD_HOME/confd ]; then
  wget $CONFD_URL -O $CLOUD_HOME/confd
fi
cp $CLOUD_HOME/confd confd/

# Build confd image
docker build confd/ -t appollo-systems/confd

# Run confd
./run-confd.sh

DATA_PATH="${CERTSDIR}/live/$PRIMARY_DOMAIN"
mkdir -p $DATA_PATH
# Create dummy certificate if not exists
if [ ! -f $DATA_PATH/fullchain.pem ] || [ ! -f $DATA_PATH/privkey.pem ]; then
  echo "### Creating dummy certificate for $PRIMARY_DOMAIN ..."
  openssl req -newkey rsa:${rsa_key_size} -x509 -sha256 -days 365 -nodes -subj '/CN=localhost' -out "$DATA_PATH/fullchain.pem" -keyout "$DATA_PATH/privkey.pem"
  echo
fi

# Generate docker-compose.yml file
docker-compose -f proxy.yml config > docker-compose.yml

# Modify file permissions
chmod 600 docker-compose.yml

# Start services
docker-compose up --build --force-recreate -d || wait_if_error_and_tty

if [[ $recreate_certificates == "true" ]]; then
  # Requesting Let's Encrypt certificate for $domains ...
  ./generate-certificates.sh
fi