#!/bin/bash

function get_service {
  curl -sS --header "accept: application/json" http://rancher-metadata.rancher.internal/latest/$1
}

container=$(get_service "self/container")
index=$(echo $container | jq -r .service_index)

mkdir -p /brick/data

if [ $index == 1 ]; then
  # wait for 2 and 3 and join cluster
  wait-for-it.sh -t 0 gluster-server-gluster-server-2:24007 -- gluster peer probe gluster-server-gluster-server-2
  wait-for-it.sh -t 0 gluster-server-gluster-server-3:24007 -- gluster peer probe gluster-server-gluster-server-3

  volume_info=$(gluster volume info data)
  if [ $? == 1 ]; then
    echo "-- Create data volume"
    gluster volume create data --force replica 3 gluster-server-gluster-server-1:/brick/data gluster-server-gluster-server-2:/brick/data gluster-server-gluster-server-3:/brick/data
    gluster volume data start
  else
    echo "-- data volume exists"
  fi
fi

exec $@
