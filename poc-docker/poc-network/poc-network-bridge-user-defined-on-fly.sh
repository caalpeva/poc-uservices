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

NETWORK1_NAME="poc_network_a"
NETWORK2_NAME="poc_network_b"

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
  docker_utils::removeNetwork ${NETWORK1_NAME} ${NETWORK2_NAME}
}

function executeContainers {
  print_info "Execute containers..."
  xtrace on
  docker run -dit \
    --name ${CONTAINER1_NAME} \
    --network ${NETWORK1_NAME} \
    alpine

  docker run -dit \
    --name ${CONTAINER2_NAME} \
    --network ${NETWORK1_NAME} \
    alpine

  docker run -dit \
    --name ${CONTAINER3_NAME} \
    --network ${NETWORK2_NAME} \
    alpine

  xtrace off
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "USER-DEFINED BRIDGE NETWORK" \
    "" \
    " - Provide automatic DNS resolution between containers on the same network." \
    " - Provide better isolation in which only containers attached to that network are able to communicate." \
    " - Containers can be attached and detached from user-defined networks on the fly."
  checkInteractiveMode

  print_info "Create ${NETWORK_NAME} networks"
  docker_utils::createNetwork ${NETWORK1_NAME}
  docker_utils::createNetwork ${NETWORK2_NAME}

  docker_utils::getNetworkList
  print_info "Show network data: ${NETWORK1_NAME}"
  docker_utils::networkInspect ${NETWORK1_NAME}
  print_info "Show network data: ${NETWORK2_NAME}"
  docker_utils::networkInspect ${NETWORK2_NAME}

  executeContainers

  print_info "Check containers status..."
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}

  print_info "Get ip address from containers"
  echo $(docker_utils::getIpAddressFromContainer ${CONTAINER1_NAME} ${NETWORK1_NAME})
  echo $(docker_utils::getIpAddressFromContainer ${CONTAINER2_NAME} ${NETWORK1_NAME})
  CONTAINER3_IP_ADDRESS=$(docker_utils::getIpAddressFromContainer ${CONTAINER3_NAME} ${NETWORK2_NAME})
  echo $CONTAINER3_IP_ADDRESS
  checkInteractiveMode

  print_info "Check connection from ${CONTAINER1_NAME} to ${CONTAINER2_NAME} by name"
  docker_utils::execContainerPing ${CONTAINER1_NAME} ${CONTAINER2_NAME}
  if [ $? -ne 0 ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  checkInteractiveMode
  print_info "Check no connection from ${CONTAINER1_NAME} to ${CONTAINER3_NAME} by name (different networks)"
  docker_utils::execContainerPing ${CONTAINER1_NAME} ${CONTAINER3_NAME}
  if [ $? -eq 0 ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  checkInteractiveMode
  print_info "Check no connection from ${CONTAINER1_NAME} to ${CONTAINER3_NAME} by ip (different networks)"
  docker_utils::execContainerPing ${CONTAINER1_NAME} ${CONTAINER3_IP_ADDRESS}
  if [ $? -eq 0 ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  checkInteractiveMode
  print_info "Connect ${CONTAINER3_NAME} to ${NETWORK1_NAME} network"
  docker_utils::connectToNetwork $NETWORK1_NAME $CONTAINER3_NAME

  print_info "Get ip address from container ${CONTAINER3_NAME}"
  echo $(docker_utils::getIpAddressFromContainer ${CONTAINER3_NAME} ${NETWORK1_NAME})
  echo $(docker_utils::getIpAddressFromContainer ${CONTAINER3_NAME} ${NETWORK2_NAME})
  checkInteractiveMode

  print_info "Check connection from ${CONTAINER1_NAME} to ${CONTAINER3_NAME} by name"
  docker_utils::execContainerPing ${CONTAINER1_NAME} ${CONTAINER3_NAME}
  if [ $? -ne 0 ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  checkInteractiveMode
  print_info "Check connection from ${CONTAINER3_NAME} to ${CONTAINER1_NAME} by name"
  docker_utils::execContainerPing ${CONTAINER3_NAME} ${CONTAINER1_NAME}
  if [ $? -ne 0 ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  checkInteractiveMode
  print_info "Disconnect ${CONTAINER3_NAME} from ${NETWORK1_NAME} network"
  docker_utils::disconnectToNetwork $NETWORK1_NAME $CONTAINER3_NAME

  print_info "Get ip address from container ${CONTAINER3_NAME}"
  echo $(docker_utils::getIpAddressFromContainer ${CONTAINER3_NAME} ${NETWORK1_NAME})
  echo $(docker_utils::getIpAddressFromContainer ${CONTAINER3_NAME} ${NETWORK2_NAME})
  checkInteractiveMode

  print_info "Check no connection from ${CONTAINER1_NAME} to ${CONTAINER3_NAME} by name (different networks)"
  docker_utils::execContainerPing ${CONTAINER1_NAME} ${CONTAINER3_NAME}
  if [ $? -eq 0 ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  checkInteractiveMode
  print_info "Check no connection from ${CONTAINER3_NAME} to ${CONTAINER1_NAME} by name (different networks)"
  docker_utils::execContainerPing ${CONTAINER3_NAME} ${CONTAINER1_NAME}
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
