#!/bin/bash

. ./config.sh

create_sentinel_instance () {
    docker run -d \
        --name $1 \
        -e REDIS_MASTER_HOST=$2 \
        --net $NETWORK_NAME \
        bitnami/redis-sentinel
}

# creates the cluster network if it does not exist
echo "Creating ${NETWORK_NAME} network..."
docker network inspect $NETWORK_NAME >/dev/null 2>&1 || docker network create $NETWORK_NAME

# Creates a master redis instance
echo "Creating the cluster master node..."
docker run -d --name $MASTER_INSTANCE_NAME --net $NETWORK_NAME redis

# Creates the sentinel instance
echo "Creating the master sentinel"
create_sentinel_instance $SENTINEL_NAME_PREFIX $MASTER_INSTANCE_NAME

echo "Creating each replica and it's sentinel"
for ((i=0; i<$NUM_REPLICAS; ++i))
do
    docker run -d \
        --name $REPLICA_NAME_PREFIX$i \
        --net $NETWORK_NAME \
        redis redis-server --replicaof $MASTER_INSTANCE_NAME 6379

    create_sentinel_instance $SENTINEL_NAME_PREFIX$i $REPLICA_NAME_PREFIX$i
done