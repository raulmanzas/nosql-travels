#!/bin/bash

. ./config.sh

# creates the cluster network if it does not exist
echo "Creating ${NETWORK_NAME} network..."
docker network inspect $NETWORK_NAME >/dev/null 2>&1 || docker network create $NETWORK_NAME

# Creates a master redis instance
echo "Creating the cluster master node..."
docker run -d --name $MASTER_INSTANCE_NAME --net $NETWORK_NAME redis

# Creates the sentinel instance
echo "Creating the master sentinel"
docker run -d \
    --name $SENTINEL_NAME_PREFIX \
    -e REDIS_MASTER_HOST=$MASTER_INSTANCE_NAME \
    --net $NETWORK_NAME \
    bitnami/redis-sentinel redis-sentinel

echo "Creating each replica and it's sentinel"
for ((i=0; i<$NUM_REPLICAS; ++i))
do
    docker run -d \
        --name $REPLICA_NAME_PREFIX$i \
        --net $NETWORK_NAME \
        redis redis-server --replicaof $MASTER_INSTANCE_NAME 6379

    docker run -d \
        --name $SENTINEL_NAME_PREFIX$i \
        -e REDIS_MASTER_HOST=$REPLICA_NAME_PREFIX$i \
        --net $NETWORK_NAME \
        bitnami/redis-sentinel
done