#!/usr/bin/env bash


## Timezone
export TZ='Asia/Shanghai'

## This is the OS user who runs pleroma service.
## value of UID and GID should be set as the same
## as userid and groupid of the OS user.
export INSTANCE_USER="pleroma"
export PUID=1002
export PGID=1002

## For PostgreSQL
export POSTGRES_PASSWORD="ChangeThis"

## For Nginx
## You need to own a domain name, and replace DOMAIN_NAME's value with it.
export DOMAIN_NAME="pleroma.xxx.com"
## This is for Letsencrypt
export DOMAIN_CERT_EMAIL='youremail@xxx.com'


## For Pleroma
default_secret_key_base=$(openssl rand -base64 48)
export SECRET_KEY_BASE="${default_secret_key_base}"
default_signing_salt=$(openssl rand -base64 48 | cut -c1-8)
export SIGNING_SALT="${default_signing_salt}"
export INSTANCE_NAME='YourInstanceNameForPleroma'
export INSTANCE_EMAIL='YourEmailAddressForPleroma'
