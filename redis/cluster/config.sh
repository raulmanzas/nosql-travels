# Tweak these parameters to change cluster creation.
NUMBER_OF_NODES=6
NUMBER_OF_REPLICAS=1
NODE_NAME_PREFIX=redis_node
CLUSTER_NETWORK=cluster
NODE_CONFIG_FILE_PATH=${PWD}/cluster-node.conf
REDIS_CONFIG_FILE_PATH=/usr/local/etc/redis/redis.conf
REDIS_PORT=6379
REDIS_CONTROL_NAME=redis_control