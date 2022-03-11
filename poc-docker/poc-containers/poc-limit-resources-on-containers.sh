#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../utils/docker-utils.src"

IMAGE="mongo"

CONTAINER_PREFIX="poc_mongo"
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
  containers=($(docker_utils::getAllContainerIdsByPrefix ${CONTAINER_PREFIX}))
  docker_utils::removeContainers ${containers[*]}
  docker_utils::removeImages $IMAGE
}

function executeContainers {
  print_info "Execute containers..."
  xtrace on
  docker run -dit \
    --name ${CONTAINER1_NAME} \
    ${IMAGE}

  docker run -dit \
    -m "300mb" \
    --cpuset-cpus 1 \
    --name ${CONTAINER2_NAME} \
    ${IMAGE}

  docker run -dit \
    -m "500mb" \
    --cpuset-cpus 1,2 \
    --name ${CONTAINER3_NAME} \
    ${IMAGE}

  docker run -dit \
    -m "1gb" \
    --cpuset-cpus 0-2 \
    --name ${CONTAINER4_NAME} \
    ${IMAGE}

  xtrace off
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "LIMIT RESOURCES" \
    "" \
    " - By default, a container has no resource constraints and can use as much of a given resource" \
    "   as the host’s kernel scheduler allows." \
    " - Docker provides ways to control how much memory, or CPU a container can use," \
    "   setting runtime configuration flags of the docker run command."
  checkInteractiveMode

  print_info "Calculate free memory space"
  xtrace on
  free -h
  xtrace off
  checkInteractiveMode

  print_info "Calculate the number of cpu processors "
  xtrace on
  grep "model name" /proc/cpuinfo
  grep "model name" /proc/cpuinfo | wc -l
  xtrace off
  checkInteractiveMode

  print_info "Compare data from docker"
  xtrace on
  docker info | grep -E "CPU|Memory"
  xtrace off
  checkInteractiveMode

  executeContainers
  print_info "Check containers status"
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}

  print_info "Check containers stats"
  docker_utils::showStatsByPrefix ${CONTAINER_PREFIX}

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

main $@
