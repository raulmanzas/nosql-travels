#!/bin/bash

# import configs
. ./config.sh

# creates the cluster network if it does not exist
docker network inspect $CLUSTER_NETWORK >/dev/null 2>&1 || docker network create $CLUSTER_NETWORK

# downloads the official image
docker pull redis

# starts the container for each node in the cluster
for ((i=0; i<$NUMBER_OF_NODES; ++i))
do
    echo "Creating node ${i}..."
    docker run -d \
        -v $NODE_CONFIG_FILE_PATH:$REDIS_CONFIG_FILE_PATH \
        --name $NODE_NAME_PREFIX$i \
        --net $CLUSTER_NETWORK \
        redis redis-server $REDIS_CONFIG_FILE_PATH
done