#!/bin/bash
set -e

if [ ! -f /data/neo4j/import_done ]; then
    echo "Importing lookup codes..."
    /var/lib/neo4j/bin/neo4j-admin database import full \
        --nodes=Code=/import/v5.0_lookup_codes.csv \
        --force
    touch /data/neo4j/import_done
fi

exec /sbin/tini -g -- /neo4j-entrypoint.sh neo4j
