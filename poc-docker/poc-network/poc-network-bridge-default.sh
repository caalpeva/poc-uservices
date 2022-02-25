#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../utils/docker-utils.src"

CONTAINER_PREFIX="poc_alpine"
CONTAINER1_NAME="${CONTAINER_PREFIX}_1"
CONTAINER2_NAME="${CONTAINER_PREFIX}_2"

NETWORK_NAME="bridge"

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
  print_info "Execute containers..."
  xtrace on
  docker run -dit \
    --name ${CONTAINER1_NAME} \
    alpine

  docker run -dit \
    --name ${CONTAINER2_NAME} \
    alpine

  xtrace off
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  docker_utils::getNetworkList
  print_info "Show network data: $NETWORK_NAME"
  docker_utils::networkInspect $NETWORK_NAME

  executeContainers
  print_info "Check containers status..."
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}

  print_info "Get ip address from containers"
  CONTAINER1_IP_ADDRESS=$(docker_utils::getIpAddressFromContainer ${CONTAINER1_NAME})
  echo ${CONTAINER1_IP_ADDRESS}

  CONTAINER2_IP_ADDRESS=$(docker_utils::getIpAddressFromContainer ${CONTAINER2_NAME})
  echo ${CONTAINER2_IP_ADDRESS}

  echo -e "### NOTE ###"
  echo -e "The containers on the default bridge network can only access other containers \non the same network through their IP addresses or using the --link option, which is considered legacy."
  echo -e "############"
  checkInteractiveMode

  print_info "Check connection from ${CONTAINER1_NAME} to ${CONTAINER2_NAME} by ip address"
  docker_utils::execContainerPing ${CONTAINER1_NAME} ${CONTAINER2_IP_ADDRESS}
  if [ $? -ne 0 ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  checkInteractiveMode
  print_info "Check connection from ${CONTAINER2_NAME} to ${CONTAINER1_NAME} by ip address"
  docker_utils::execContainerPing ${CONTAINER2_NAME} ${CONTAINER1_IP_ADDRESS}
  if [ $? -ne 0 ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  checkInteractiveMode
  print_info "Check connection from ${CONTAINER1_NAME} to ${CONTAINER2_NAME} by name"
  docker_utils::execContainerPing ${CONTAINER1_NAME} ${CONTAINER2_NAME}
  if [ $? -eq 0 ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  checkInteractiveMode
  print_info "Check connection from ${CONTAINER2_NAME} to ${CONTAINER1_NAME} by name"
  docker_utils::execContainerPing ${CONTAINER2_NAME} ${CONTAINER1_NAME}
  if [ $? -eq 0 ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  checkInteractiveMode
  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

main $@
