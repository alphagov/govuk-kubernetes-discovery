#!/bin/bash

#
# This is not really a script so much as a set of notes on what seems to work
#

# Tunnel to the Production Router Mongo and list a recent backup
rsync -av --rsync-path="sudo rsync" mongo-1.cluster:/var/lib/automongodbbackup/daily/*.tgz

# Pick one and use it
BACKUP_ARCHIVE="1666-09-02_00h42m.Sunday"
rsync -av --rsync-path="sudo rsync" mongo-1.cluster:/var/lib/automongodbbackup/daily/${BACKUP_ARCHIVE}.tgz tmp/

# Untar it and rename it.
cd tmp/
tar -zxvf ${BACKUP_ARCHIVE}.tgz

tar -czf content.tgz ${BACKUP_ARCHIVE}/admin ${BACKUP_ARCHIVE}/content_store_production
cd ..


## Copy this up to the "Primary" Mongo pod
kubectl cp tmp/content.tgz mongo-0:/root/ -c mongo

## Get a shell on this primary Mongo node
kubectl exec mongo-0 -ti -- bash

## On mongo-0 import the dump from within the container (or use kubectl exec)
# $ mongo
#   > db.getSiblingDB('admin').runCommand( { setParameter: 1, failIndexKeyTooLong: false } )
# $ cd /root
# $ tar -zxvf content.tgz
# $ mongorestore --drop $BACKUP_ARCHIVE
