#!/bin/bash

# Usage: wineandcats-backup-db.sh <stage> <password> <pgversion>
#
# Example: wineandcats-backup-db.sh dev thepassword 16

GOMP_STAGE=$1
PGPASSWORD=$2
PGVERSION=$3
docker stop wineandcats-$GOMP_STAGE
docker run -it --rm --network wineandcats-$GOMP_STAGE -v $PWD:/backup -e PGHOST=db -e POSTGRES_DB=gomp -e PGPASSWORD=$PGPASSWORD -e PGUSER=gomp postgres:$PGVERSION /bin/sh -c 'pg_dump --schema=public $POSTGRES_DB > /backup/dump.sql'
docker start wineandcats-$GOMP_STAGE
