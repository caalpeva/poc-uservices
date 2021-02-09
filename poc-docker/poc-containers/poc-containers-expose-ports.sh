#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../utils/docker-utils.src"

CONTAINER_PREFIX="poc_httpd_$(date '+%Y%m%d')"
CONTAINER1_NAME="${CONTAINER_PREFIX}_1"
CONTAINER2_NAME="${CONTAINER_PREFIX}_2"

CONTAINER_HTTP_PORT="80"

function initialize {
  print_info "Preparing poc environment..."
  trap handleTermSignal INT QUIT TERM KILL
  cleanup
}

function handleTermSignal {
  xtrace off
  print_warn "Handling termination signal..."
  cleanup
  exit 1
}

function cleanup {  
  containers=($(docker_utils::getAllContainerIdsByPrefix ${CONTAINER_PREFIX}))
  echo "Containers: ${containers[@]}"
  echo "Count: ${#containers[@]}"
  if [ ${#containers[@]} -gt 0 ]
  then
    print_debug "Se necesita limpiar"
    for containerId in ${containers[@]}
    do
      xtrace on
      docker rm -f $containerId
      xtrace off
    done
  fi
}

function executeContainers {
  print_info "Execute containers with HTTP servers ..."  
  xtrace on
  docker run -d \
    --rm \
    --name ${CONTAINER1_NAME} \
    -p 81:${CONTAINER_HTTP_PORT} \
    httpd
  
  docker run -d \
    --rm \
    --name ${CONTAINER2_NAME} \
    -P \
    httpd

  xtrace off
}

function checkHttpServerAvailability  {
  print_info "Check that the http server from $1 is available ..."
  print_debug "Extract host port from $1 ..."
  port=$(docker_utils::getFirstHostPortFromContainerData $1 ${CONTAINER_HTTP_PORT})
    
  xtrace on
  curl "http://localhost:${port}"
  return $?
}

function main {
  print_info "$(basename $0) [PID = $$]"
  initialize
  executeContainers

  print_info "Check containers status..."
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}

  checkHttpServerAvailability ${CONTAINER1_NAME}
  xtrace off
  checkHttpServerAvailability ${CONTAINER2_NAME}
  xtrace off

  if [ $? -ne 0 ]
  then
    print_error "Server from ${CONTAINER1_NAME} container not available"
  fi

  print_info "Cleanup containers..."
  cleanup

  print_info "Check containers status after cleanup..."
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}

  print_done "Poc completed successfully "
  exit 0
}

main $@