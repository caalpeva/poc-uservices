#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../utils/docker-utils.src"

CONTAINER_PREFIX="poc_alpine"
CONTAINER1_NAME="${CONTAINER_PREFIX}_1"
CONTAINER2_NAME="${CONTAINER_PREFIX}_2"
CONTAINER3_NAME="${CONTAINER_PREFIX}_3"
CONTAINER4_NAME="${CONTAINER_PREFIX}_4"

NETWORK_NAME="poc_network"

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
  docker_utils::removeNetwork ${NETWORK_NAME}
}

function executeContainers {
  print_info "Execute containers..."
  xtrace on
  docker run -dit \
    --name ${CONTAINER1_NAME} \
    alpine

  docker run -dit \
    --network ${NETWORK_NAME} \
    --name ${CONTAINER2_NAME} \
    alpine

  docker run -dit \
    --network host \
    --name ${CONTAINER3_NAME} \
    alpine

  docker run -dit \
    --network none \
    --name ${CONTAINER4_NAME} \
    alpine

  xtrace off
}

function showLocalhostNetworkInterfaces() {
  xtrace on
  hostname
  ip addr
  ip route
  xtrace off
  checkInteractiveMode
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "NETWORK TYPES" \
    "" \
    " - Default bridge: Default network where containers will run." \
    " - User-defined bridge: User-defined network with high-performance where containers will run when specified. " \
    " - Host: The containers will have the same network interfaces as the docker engine server host it runs on," \
    "   including the docker0 virtual interface." \
    " - None: No network, only the loopback (lo)"
  checkInteractiveMode

  print_info "Show network interfaces from localhost before container execution"
  showLocalhostNetworkInterfaces

  print_info "Create ${NETWORK_NAME} network"
  docker_utils::createNetwork ${NETWORK_NAME}

  docker_utils::getNetworkList

  executeContainers
  print_info "Check containers status..."
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}

  print_info "Get ip address from containers"
  echo $(docker_utils::getIpAddressFromContainer ${CONTAINER1_NAME})
  echo $(docker_utils::getIpAddressFromContainer ${CONTAINER2_NAME} $NETWORK_NAME)
  echo $(docker_utils::getIpAddressFromContainer ${CONTAINER3_NAME} "host")
  echo $(docker_utils::getIpAddressFromContainer ${CONTAINER4_NAME} "none")
  checkInteractiveMode

  print_info "Show network interfaces from ${CONTAINER1_NAME} container (default bridge network)"
  docker_utils::showNetworkInterfaces ${CONTAINER1_NAME}

  print_info "Show network interfaces from ${CONTAINER2_NAME} container (user-defined bridge network)"
  docker_utils::showNetworkInterfaces ${CONTAINER2_NAME}

  print_info "Show network interfaces from ${CONTAINER3_NAME} container (host network)"
  docker_utils::showNetworkInterfaces ${CONTAINER3_NAME}

  print_info "Show network interfaces from ${CONTAINER4_NAME} container (none network)"
  docker_utils::showNetworkInterfaces ${CONTAINER4_NAME}

  print_info "Show network interfaces from localhost during container execution"
  showLocalhostNetworkInterfaces

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

main $@
