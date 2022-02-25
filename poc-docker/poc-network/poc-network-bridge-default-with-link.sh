#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../utils/docker-utils.src"

CONTAINER_PREFIX="poc_link"
CONTAINER_MYSQL="${CONTAINER_PREFIX}_mysql"
CONTAINER_ADMINER="${CONTAINER_PREFIX}_adminer"

MYSQL_ROOT_PASSWORD="root"

ADMINER_CONTAINER_PORT="8080"
ADMINER_HOST_PORT="8080"

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

function executeMysqlContainer {
  print_info "Execute container ${CONTAINER_MYSQL} with MySQL server"
  xtrace on
  docker run -d \
    --name ${CONTAINER_MYSQL} \
    -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
    -v ${DIR}/scripts/initial:/docker-entrypoint-initdb.d \
    mysql:5.7.28

  xtrace off

  docker_utils::getContainerMounts ${CONTAINER_MYSQL}
}

function executeAdminerContainer {
  print_info "Execute container ${CONTAINER_ADMINER} with adminer"
  xtrace on
  docker run -d \
    --name ${CONTAINER_ADMINER} \
    --link ${CONTAINER_MYSQL} \
    -p ${ADMINER_HOST_PORT}:${ADMINER_CONTAINER_PORT} \
    adminer:4.8.1

  xtrace off
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "DEFAULT BRIDGE NETWORK" \
    "" \
    " - The containers on the default bridge network can only access other containers" \
    "   on the same network through their IP addresses or using the --link option, which is considered legacy."
  checkInteractiveMode

  docker_utils::getNetworkList
  print_info "Show network data: $NETWORK_NAME"
  docker_utils::networkInspect $NETWORK_NAME

  executeMysqlContainer
  executeAdminerContainer

  print_info "Check containers status..."
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}

  print_info "Get ip address from containers"
  MYSQL_IP_ADDRESS=$(docker_utils::getIpAddressFromContainer ${CONTAINER_MYSQL})
  echo ${MYSQL_IP_ADDRESS}
  checkInteractiveMode

  print_info "Check connection from ${CONTAINER_ADMINER} to ${CONTAINER_MYSQL} by ip address"
  docker_utils::execContainerPingAsRoot ${CONTAINER_ADMINER} ${MYSQL_IP_ADDRESS}
  if [ $? -ne 0 ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  checkInteractiveMode
  print_info "Check connection from ${CONTAINER_ADMINER} to ${CONTAINER_MYSQL} by name"
  docker_utils::execContainerPingAsRoot ${CONTAINER_ADMINER} ${CONTAINER_MYSQL}
  if [ $? -ne 0 ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  checkInteractiveMode
  print_info "Check /etc/hosts file from ${CONTAINER_ADMINER}"
  docker_utils::execContainer ${CONTAINER_ADMINER} "cat /etc/hosts"

  print_info "Check that the ${CONTAINER_ADMINER} container can connect to the ${CONTAINER_MYSQL} container."
  print_debug "Open a browser and access to http://localhost:${ADMINER_HOST_PORT}"
  print_debug "Note that the name of the server you want to access is the name of the mysql container."
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

main $@
