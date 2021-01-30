#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../utils/docker-utils.src"

CONTAINER_PREFIX="poc_ubuntu_top$(date '+%Y%m%d')"
CONTAINER1_NAME="${CONTAINER_PREFIX}_1"
CONTAINER2_NAME="${CONTAINER_PREFIX}_2"
CONTAINER3_NAME="${CONTAINER_PREFIX}_3"
CONTAINER4_NAME="${CONTAINER_PREFIX}_4"


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
  print_info "Execute containers..."  
  xtrace on
  docker run -dit \
    --name ${CONTAINER1_NAME} \
    ubuntu /usr/bin/top -b

  docker run -dit \
    --name ${CONTAINER3_NAME} \
    ubuntu /usr/bin/top -b

  docker run -dit \
    --rm \
    --name ${CONTAINER2_NAME} \
    ubuntu /usr/bin/top -b
  
  docker run -dit \
    --rm \
    --name ${CONTAINER4_NAME} \
    ubuntu /usr/bin/top -b

  xtrace off
}

function startContainers {
  print_info "Start containers..."
  containers=$(docker_utils::getExitedContainerIdsByPrefix ${CONTAINER_PREFIX})

  # args=("$@") 
  # get number of elements 
  # ELEMENTS=${#args[@]} 
  # echo each element in array  
  # for loop 
  # for (( i=0;i<$ELEMENTS;i++)); do 
  # echo ${args[${i}]} 


  for containerId in ${containers}
  do
    xtrace on
    docker start ${containerId}
    xtrace off
  done
}

function stopContainers {
  print_info "Stop containers..."
  containers=$(docker_utils::getRunningContainerIdsByPrefix ${CONTAINER_PREFIX})

  for containerId in ${containers}
  do
    xtrace on
    docker stop ${containerId}
    xtrace off
  done
}

function main {
  print_info "$(basename $0) [PID = $$]"
  initialize
  executeContainers

  print_info "Check containers status..."
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}
  stopContainers

  print_info "Check containers status after stopping..."
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}
  startContainers

  print_info "Check containers status after startup..."
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}

  print_info "Cleanup containers..."
  cleanup

  print_info "Check containers status after cleanup..."
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}

  print_done "Poc completed successfully "
  exit 0
}

main $@