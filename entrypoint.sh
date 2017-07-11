#!/bin/bash

set -e

# Allow for memlock
ulimit -l unlimited
sysctl -w fs.file-max=65536
sysctl -w vm.max_map_count=262144

# Add elasticsearch as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- es "$@"
fi

# Drop root privileges if we are running elasticsearch
# allow the container to be started with `--user`
if [ "$1" = 'elasticsearch' -a "$(id -u)" = '0' ]; then
	chown -R es:es "/es"
	sync
	set -- gosu es "$@"
fi

# As argument is not related to elasticsearch,
# then assume that user wants to run his own process,
# for example a `bash` shell to explore this image
exec "$@"
