#!/usr/bin/env bash

set -e

PGADMIN_PATH="/usr/local/lib/python3.8/site-packages/pgadmin4"
CONFIG_FILE="$PGADMIN_PATH/config_local.py"

if [ ! -f /data/config/pgadmin4.db ]; then
    su-exec pgadmin python "$PGADMIN_PATH/setup.py"
    su-exec pgadmin python /scripts/setup-server.py
fi

if [ "$MASTER_PASSWORD_REQUIRED" != '' ]; then
    if ! grep ^MASTER_PASSWORD_REQUIRED "$CONFIG_FILE" >/dev/null; then
      echo -e "\n\nMASTER_PASSWORD_REQUIRED = $MASTER_PASSWORD_REQUIRED" >> "$CONFIG_FILE"
    fi
fi

exec su-exec pgadmin python "$PGADMIN_PATH/pgAdmin4.py"
