#!/bin/bash

echo "-- Starting Service --"

function get_service {
  curl -sS --header "accept: application/json" http://rancher-metadata.rancher.internal/latest/$1
}

sleep 1
container=$(get_service "self/container")
index=$(echo $container | jq -r .service_index)

echo "-- Making /brick/data --"
mkdir -p /brick/data

if [ $index == 1 ]; then
  echo "-- Starting glusterd to join cluster --"
  glusterd --log-file=/dev/stdout --pid-file=/tmp/gluster.pid
  # wait for 2 and 3 and join cluster
  wait-for-it.sh -t 0 gluster-server-gluster-server-2:24007 -- gluster peer probe gluster-server-gluster-server-2
  wait-for-it.sh -t 0 gluster-server-gluster-server-3:24007 -- gluster peer probe gluster-server-gluster-server-3

  echo "-- Checking for volume --"
  volume_info=$(gluster volume info data 2>&1)
  if [ $? == 1 ]; then
    echo "-- Create default data volume --"
    gluster volume create data replica 3 gluster-server-gluster-server-1:/brick/data gluster-server-gluster-server-2:/brick/data gluster-server-gluster-server-3:/brick/data force
    gluster volume start data
  else
    echo "-- Default data volume exists --"
  fi

  echo "-- Stopping glusterd --"
  kill $(cat /tmp/gluster.pid)
  rm /tmp/gluster.pid
fi

exec "$@"
