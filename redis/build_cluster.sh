#!/bin/bash

# import configs
. ./config.sh

# creates the cluster network if it does not exist
docker network inspect $CLUSTER_NETWORK >/dev/null 2>&1 || docker network create $CLUSTER_NETWORK

# downloads the official image
docker pull redis

declare -a IP_LIST
# starts the container for each node in the cluster
for ((i=0; i<$NUMBER_OF_NODES; ++i))
do
    NAME=$NODE_NAME_PREFIX$i
    echo "Creating node ${NAME}..."

    docker run -d \
        -v $NODE_CONFIG_FILE_PATH:$REDIS_CONFIG_FILE_PATH \
        --name $NAME \
        --net $CLUSTER_NETWORK \
        redis redis-server $REDIS_CONFIG_FILE_PATH

    # Captures the IP of the node
    NODE_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $NAME)
    IP_LIST[$i]=$NODE_IP:$REDIS_PORT
done

# starts the cluster itself, with 1 replica node for each master (by shard)
docker run -i --rm --net $CLUSTER_NETWORK redis redis-cli --cluster create ${IP_LIST[*]} --cluster-replicas 1
