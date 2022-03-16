#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../utils/docker.src"

CONTAINER_PREFIX="poc_ubuntu_top"
CONTAINER1_NAME="${CONTAINER_PREFIX}_1"
CONTAINER2_NAME="${CONTAINER_PREFIX}_2"
CONTAINER3_NAME="${CONTAINER_PREFIX}_3"
CONTAINER4_NAME="${CONTAINER_PREFIX}_4"

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
  containers=($(docker::getAllContainerIdsByPrefix ${CONTAINER_PREFIX}))
  docker::removeContainers ${containers[*]}
}

function executeContainers {
  print_info "Execute containers..."
  xtrace on
  docker run -dit \
    --name ${CONTAINER1_NAME} \
    ubuntu /usr/bin/top -b

  docker run -dit \
    --rm \
    --name ${CONTAINER2_NAME} \
    ubuntu /usr/bin/top -b

  docker run -dit \
    --name ${CONTAINER3_NAME} \
    ubuntu /usr/bin/top -b

  docker run -dit \
    --rm \
    --name ${CONTAINER4_NAME} \
    ubuntu /usr/bin/top -b

  xtrace off
}

function startContainers {
  print_info "Start containers..."
  containers=$(docker::getExitedContainerIdsByPrefix ${CONTAINER_PREFIX})
  for containerId in ${containers}
  do
    docker::startContainers ${containerId}
  done
}

function stopContainers {
  print_info "Stop containers..."
  containers=$(docker::getRunningContainerIdsByPrefix ${CONTAINER_PREFIX})

  for containerId in ${containers}
  do
    docker::stopContainers ${containerId}
  done
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  executeContainers
  print_info "Check containers status..."
  docker::showContainersByPrefix ${CONTAINER_PREFIX}
  stopContainers

  print_info "Check containers status after stopping..."
  docker::showContainersByPrefix ${CONTAINER_PREFIX}
  startContainers

  print_info "Check containers status after startup..."
  docker::showContainersByPrefix ${CONTAINER_PREFIX}

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

main $@
