#!/bin/bash

NETWORK_NAME=sentinel
MASTER_INSTANCE_NAME=redis_master
REPLICA_NAME_PREFIX=replica

# creates the cluster network if it does not exist
docker network inspect $NETWORK_NAME >/dev/null 2>&1 || docker network create $NETWORK_NAME

# Creates a master redis instance
docker run -d --name $MASTER_INSTANCE_NAME --net $NETWORK_NAME redis

# Creates the sentinel instance
docker run -d \
    -- name $REPLICA_NAME_PREFIX
    -e REDIS_MASTER_HOST=master \
    --net $NETWORK_NAME \
    bitnami/redis-sentinel