#!/bin/bash

. ./config.sh

# name of a node that is going to be used to fetch the cluster's ip
NODE_NAME=${NODE_NAME_PREFIX}0

IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $NODE_NAME)
# connects as a cluster
redis-cli -c -h $IP -p $REDIS_PORT