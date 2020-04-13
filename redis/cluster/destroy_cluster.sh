#!/bin/bash

# import configs
. ./config.sh

# stops and removes all cluster containers
for ((i=0; i<$NUMBER_OF_NODES; ++i))
do
    echo "Removing node ${i}"
    docker rm --force $NODE_NAME_PREFIX$i
done

# removes the container used to start the cluster
echo "Removing the control container"
docker rm --force $REDIS_CONTROL_NAME

# removes the network
echo "Removing the cluster network..."
docker network rm $CLUSTER_NETWORK
