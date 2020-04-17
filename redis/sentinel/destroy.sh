#!/bin/bash

. ./config.sh

echo "Removing master and it's sentinel..."
docker rm --force $MASTER_INSTANCE_NAME
docker rm --force $SENTINEL_NAME_PREFIX

echo "Removing replicas and sentinels.."
for ((i=0; i<$NUM_REPLICAS; ++i))
do
    docker rm --force $REPLICA_NAME_PREFIX$i
    docker rm --force $SENTINEL_NAME_PREFIX$i
done

# removes the network
echo "Removing the network..."
docker network rm $NETWORK_NAME