#!/usr/bin/env bash

set -e

if [ ! -f /data/config/pgadmin4.db ]; then
    su-exec pgadmin python /usr/local/lib/python3.8/site-packages/pgadmin4/setup.py
    su-exec pgadmin python /scripts/setup-server.py

    if [ "$MASTER_PASSWORD_REQUIRED" != '' ]; then
      echo -e "\n\nMASTER_PASSWORD_REQUIRED = $MASTER_PASSWORD_REQUIRED" >> /usr/local/lib/python3.8/site-packages/pgadmin4/config_local.py
    fi
fi

exec su-exec pgadmin python /usr/local/lib/python3.8/site-packages/pgadmin4/pgAdmin4.py
