#!/bin/bash

. ./config.sh

destroy_container () {
    docker rm --force $1
}

echo "Removing master and it's sentinel..."
destroy_container $MASTER_INSTANCE_NAME
destroy_container $SENTINEL_NAME_PREFIX

echo "Removing replicas and sentinels.."
for ((i=0; i<$NUM_REPLICAS; ++i))
do
    destroy_container $REPLICA_NAME_PREFIX$i
    destroy_container $SENTINEL_NAME_PREFIX$i
done

# removes the network
echo "Removing the network..."
docker network rm $NETWORK_NAME