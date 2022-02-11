#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../utils/docker-utils.src"

CONTAINER_PREFIX="poc_httpd"
CONTAINER1_NAME="${CONTAINER_PREFIX}_1"
CONTAINER2_NAME="${CONTAINER_PREFIX}_2"

CONTAINER_HTTP_PORT="80"
HOST_HTTP_PORT="81"

function initialize() {
  print_info "Preparing poc environment..."
  setTerminalSignals
  cleanup
}

function handleTermSignal() {
  xtrace off
  print_warn "Handling termination signal..."
  cleanup
  exit 1
}

function cleanup {  
  print_debug "Cleaning environment..."   
  containers=($(docker_utils::getAllContainerIdsByPrefix ${CONTAINER_PREFIX}))
  docker_utils::removeContainers ${containers[*]}
}

function executeContainers {
  print_info "Execute containers with HTTP servers ..."  
  xtrace on
  docker run -d \
    --rm \
    --name ${CONTAINER1_NAME} \
    -p ${HOST_HTTP_PORT}:${CONTAINER_HTTP_PORT} \
    httpd
  
  docker run -d \
    --rm \
    --name ${CONTAINER2_NAME} \
    -P \
    httpd

  xtrace off
}

function checkUrl  { 
  command="curl $1"
  echo "+ $command"
  eval "$command"
  return $?
}

function checkHttpServerAvailability  {
  declare -i result=0
  print_info "Check that the Http server from $1 is available ..."
  print_debug "Extract host port from container data ..."
  port=$(docker_utils::getFirstHostPortFromContainerData $1 ${CONTAINER_HTTP_PORT})
    
  checkUrl "http://localhost:${port}"
  if [ $? -ne 0 ]
  then
    print_error "Http server from $1 is not available"
    result=1
  fi

  checkInteractiveMode
  return $result
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize
  
  executeContainers
  print_info "Check containers status..."
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}

  checkHttpServerAvailability ${CONTAINER1_NAME}
  isHttpServer1Available=$?
  
  checkHttpServerAvailability ${CONTAINER2_NAME}
  isHttpServer2Available=$?

  checkCleanupMode
  if [ $isHttpServer1Available -ne 0 -o $isHttpServer2Available -ne 0 ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  print_done "Poc completed successfully"
  exit 0
}

main $@
