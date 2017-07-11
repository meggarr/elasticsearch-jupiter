# elasticsearch-jupiter
A Elasticsearch 2.x run in Docker

## Build image
```
./build.sh -t 2.4.5-1
```
## Configs
Since it will change the ulimit, fs_max and max_map_count, the image must be run in privileged mode, e.g.
```
docker run --privileged=true elasticsearch2:2.4.5-1
```
Supported ENV variables as configs

| Name          | Default       | Description   |
| ------------- | ------------- | ------------- |
| CLUSTER_NAME  | elasticsearch-jupiter | The ES cluster name |
| ES_HEAP_SIZE  | 512m | The heap memory size of the node |
| HTTP_ENABLE  | true | True if the node will expose REST API port - 9200 |
| NODE_DATA  | true | True if the node will run in data mode |
| NODE_MASTER  | true | True if the node will run in master mode |
| ZEN_HOSTS  | "" | The comma separated list of IP addresses of ES cluster nodes, e.g. `"172.27.2.20","172.27.2.21","172.27.2.22","172.27.2.23"` |
| NUMBER_OF_MASTERS  | 1 | The minimum number of master nodes |
| NUMBER_OF_REPLICAS  | 0 | The number of replicas of the index |
| NUMBER_OF_SHARDS  | 1 | The number of shards of the index |

Note:
* Both master and data mode can be true, that means this node is master and data node,
* Both master and data mode can be false, that means this node is only for clients with REST API, a.k.a. client mode,
* If HTTP is disabled, it cannot be connected using REST API


## Example
This example run 4 nodes in the same VM, with
- 1 node for master only
- 2 nodes for master and data
- 1 node for data only
- Heap size as 1Gi each

Because we want set the IP address of the docker instance, we use a customized Docker network.
```
docker network create --driver=bridge --subnet=172.27.2.0/24 --ip-range=172.27.2.0/24 --gateway=172.27.2.1 esnet
```

### Run the 1 node for master only
```
chmod 777 /opt/es/d0
docker run --name=es-master --privileged=true -d \
           -e ES_HEAP_SIZE=1g -e NODE_DATA=false \
           -e ZEN_HOSTS="172.27.2.20","172.27.2.21","172.27.2.22","172.27.2.23" \
           --network esnet --ip 172.27.2.20 \
           -v /opt/es/d0:/data \
           elasticsearch2:2.4.5-1
```

### Run the 2 nodes for master and data
```
chmod 777 /opt/es/d1
docker run --privileged=true -d
           -e ES_HEAP_SIZE=1g \
           -e ZEN_HOSTS="172.27.2.20","172.27.2.21","172.27.2.22","172.27.2.23" \
           --network esnet --ip 172.27.2.21 \
           -v /opt/es/d1:/data \
           elasticsearch2:2.4.5-1

chmod 777 /opt/es/d2
docker run --privileged=true -d \
           -e ES_HEAP_SIZE=1g \
           -e ZEN_HOSTS="172.27.2.20","172.27.2.21","172.27.2.22","172.27.2.23" \
           --network esnet --ip 172.27.2.22 \
           -v /opt/es/d2:/data \
           elasticsearch2:2.4.5-1
```

### Run the 1 node for data only
```
chmod 777 /opt/es/d3
docker run --name=es-data --privileged=true -d \
           -e ES_HEAP_SIZE=1g \
           -e NODE_MASTER=false \
           -e HTTP_ENABLE=false \
           -e ZEN_HOSTS="172.27.2.20","172.27.2.21","172.27.2.22","172.27.2.23" \
           --network esnet --ip 172.27.2.23 \
           -v /opt/es/d3:/data \
           elasticsearch2:2.4.5-1
```
