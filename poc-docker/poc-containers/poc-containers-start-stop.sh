#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"

CONTAINER_PREFIX="topdemo_$(date '+%Y%m%d')"
CONTAINER1_NAME="${CONTAINER_PREFIX}_1"
CONTAINER2_NAME="${CONTAINER_PREFIX}_2"

function handleSignal {
  echo "Caught signal..."
  echo "Done cleanup... quitting"
  docker ps -a | grep $CONTAINER_PREFIX
  if [ $? -eq 0 ]
  then
    echo "OK"
    set -x
    docker rm -f ${CONTAINER1_NAME}
    docker rm -f ${CONTAINER2_NAME}
  else
    echo "KO"
  fi
  exit 1
}

echo "Initializing... (PID = $$)"
trap handleSignal INT QUIT TERM KILL

CONTAINER_NAME="topdemo_$(date '+%Y%m%d')"

print_info "Execute containers..."
set -x

docker run -dit \
    --name ${CONTAINER1_NAME} \
    ubuntu /usr/bin/top -b

docker run -dit \
    --rm \
    --name ${CONTAINER2_NAME} \
    ubuntu /usr/bin/top -b

set +x
print_info "Check containers..."

set -x
docker ps -a | grep ${container_name}

set +x
while /bin/true
do
  sleep 3
  echo "Processing..."
done




