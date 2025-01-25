#!/bin/bash

# Usage: restore-wineandcats-db.sh <stage> <password> <pgversion>
#
# Example: restore-wineandcats-db.sh dev thepassword 16

GOMP_STAGE=$1
PGPASSWORD=$2
PGVERSION=$3
docker stop wineandcats-$GOMP_STAGE
docker run -it --rm --network wineandcats-$GOMP_STAGE -v $PWD:/backup -e PGHOST=db -e POSTGRES_DB=gomp -e PGPASSWORD=$PGPASSWORD -e PGUSER=gomp postgres:$PGVERSION /bin/sh -c 'psql -c "DROP SCHEMA public CASCADE;" && psql < /backup/dump.sql'
docker start wineandcats-$GOMP_STAGE
