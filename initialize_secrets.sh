#!/bin/sh
# Run this from autolab-docker root

if ! ls docker-compose.yml > /dev/null 2>&1 ; then 
  echo "Please run this from autolab-docker root"
  exit 1
fi

if ! ls .env > /dev/null 2>&1 ; then
  echo ".env file does not exist (run: make)"
  exit 0
fi

if ! (grep -q SECRET_KEY_BASE .env && grep -q LOCKBOX_MASTER_KEY .env && grep -q DEVISE_SECRET_KEY .env); then
  echo ".env file must be updated (run: cp .env.template .env; make initialize_secrets)"
  exit 1
fi

SECRET_KEY_BASE=$(openssl rand -hex 64)
LOCKBOX_MASTER_KEY=$(openssl rand -hex 32)
DEVISE_SECRET_KEY=$(openssl rand -hex 64)
SECRET_TANGO_KEY=$(openssl rand -hex 32)

if ! perl -i -pe"s/<SECRET_KEY_BASE_REPLACE_ME>/${SECRET_KEY_BASE}/g" .env ; then
  echo "SECRET_KEY_BASE seems to have already been set"
fi

if ! perl -i -pe"s/<LOCKBOX_MASTER_KEY_REPLACE_ME>/${LOCKBOX_MASTER_KEY}/g" .env ; then
  echo "LOCKBOX_MASTER_KEY seems to have already been set"
fi

if ! perl -i -pe"s/<DEVISE_SECRET_KEY_REPLACE_ME>/${DEVISE_SECRET_KEY}/g" .env ; then
  echo "DEVISE_SECRET_KEY seems to have already been set"
fi

if ! perl -i -pe"s/<SECRET_TANGO_KEY_REPLACE_ME>/${SECRET_TANGO_KEY}/g" .env ; then
  echo "SECRET_TANGO_KEY seems to have already been set"
fi

echo ".env file secrets have been initialized"
