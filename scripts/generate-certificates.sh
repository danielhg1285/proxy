#!/usr/bin/env bash

# genereate-certificates.sh
# Generates letsencrypt certificates

# Source commoun variables and functions
source common.sh

domains=($DOMAIN_LIST)
data_path="${CERTSDIR}/live/$PRIMARY_DOMAIN"
email="danielhg1285@gmail.com" # Adding a valid address is strongly recommended
staging=0 # Set to 1 if you're testing your setup to avoid hitting request limits

echo "### Requesting Let's Encrypt certificate for $domains ..."
#Join $domains to -d args
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Select appropriate email arg
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

# Enable staging mode if needed
if [ $staging != "0" ]; then staging_arg="--test-cert"; fi

# Create certificates directories
rm -rf $LETSENCRYPT_TMP
mkdir -p $LETSENCRYPT_TMP/conf
mkdir -p $LETSENCRYPT_TMP/log
mkdir -p $LETSENCRYPT_TMP/workdir

certbot certonly -n \
--config-dir $LETSENCRYPT_TMP/conf \
--logs-dir $LETSENCRYPT_TMP/log \
--work-dir $LETSENCRYPT_TMP/workdir \
--webroot --webroot-path=${LETSENCRYPT_WEB_ROOT} \
$staging_arg \
$email_arg \
$domain_args \
--agree-tos

# Update certificates
rsync -av --delete --links $LETSENCRYPT_TMP/conf/ $CERTSDIR/

# Modify renewal configuration changing letsencrypt temporary directory for letsencrypt directory
sed -i -e 's|'$LETSENCRYPT_TMP'/conf|'$CERTSDIR'|' $CERTSDIR/renewal/$PRIMARY_DOMAIN.conf

# Reload nginx
echo "Reloading nginx"
docker exec nginx-proxy nginx -s reload

echo