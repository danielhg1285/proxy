#!/usr/bin/env bash

# renew-certificates.sh
# This command attempts to renew any previously-obtained certificates that expire in less than 30 days
# The same plugin and options as when certificate was originally issued are applied.

# Source commoun variables and functions
source common.sh

certbot -n \
--config-dir $CERTSDIR \
--logs-dir $LETSENCRYPT_TMP/log \
--work-dir $LETSENCRYPT_TMP/workdir \
--webroot --webroot-path=${LETSENCRYPT_WEB_ROOT} renew

# Update certificates
rsync -av --delete --links $LETSENCRYPT_TMP/conf/ $CERTSDIR/

# Modify renewal configuration changing letsencrypt temporary directory for letsencrypt directory
sed -i -e 's|'$LETSENCRYPT_TMP'/conf|'$CERTSDIR'|' $CERTSDIR/renewal/$PRIMARY_DOMAIN.conf

# Reload proxy
./reload-proxy.sh