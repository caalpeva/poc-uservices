#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../utils/docker-utils.src"

CONTAINER_PREFIX="poc_network"
CONTAINER_MYSQL="${CONTAINER_PREFIX}_mysql"
CONTAINER_PHPMYADMIN="${CONTAINER_PREFIX}_phpmyadmin"

MYSQL_ROOT_PASSWORD="root"

PHPMYADMIN_CONTAINER_PORT="80"
PHPMYADMIN_HOST_PORT="8081"

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

function executeMysqlContainer {
  print_info "Execute container ${CONTAINER_MYSQL} with MySQL server"
  print_debug "With ip address assigned"
  xtrace on
  docker run -d \
    --name ${CONTAINER_MYSQL} \
    --network ${NETWORK_NAME} \
    --ip 180.128.10.50 \
    -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
    -v ${DIR}/scripts/initial:/docker-entrypoint-initdb.d \
    mysql:5.7.28

  xtrace off
}

function executePhpMyAdminContainer {
  print_info "Execute container ${CONTAINER_PHPMYADMIN} with phpMyAdmin"
  xtrace on
  docker run -d \
    --name ${CONTAINER_PHPMYADMIN} \
    --network ${NETWORK_NAME} \
    -e PMA_ARBITRARY=1 \
    -p ${PHPMYADMIN_HOST_PORT}:${PHPMYADMIN_CONTAINER_PORT} \
    phpmyadmin/phpmyadmin:5.1.3

  xtrace off
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_info "Create ${NETWORK_NAME} network"
  docker_utils::createNetwork "--subnet 180.128.10.0/24 --gateway 180.128.10.1 -d bridge" ${NETWORK_NAME}

  docker_utils::getNetworkList
  print_info "Show network data: $NETWORK_NAME"
  docker_utils::networkInspect $NETWORK_NAME

  executeMysqlContainer
  executePhpMyAdminContainer

  print_info "Check containers status..."
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}

  docker inspect poc_network_mysql -f "{{ .NetworkSettings.Networks.poc_network.IPAddress }}"
  print_info "Get ip address from containers"
  MYSQL_IP_ADDRESS=$(docker_utils::getIpAddressFromContainer ${CONTAINER_MYSQL} ${NETWORK_NAME})
  echo ${MYSQL_IP_ADDRESS}

  PHPMYADMIN_IP_ADDRESS=$(docker_utils::getIpAddressFromContainer ${CONTAINER_PHPMYADMIN} ${NETWORK_NAME})
  echo ${PHPMYADMIN_IP_ADDRESS}

  echo -e "### NOTE ###"
  echo -e "User defined bridges provide automatic DNS resolution between containers on the same network."
  echo -e "############"
  checkInteractiveMode

  print_info "Install network utils in container ${CONTAINER_PHPMYADMIN}"
  xtrace on
  docker exec -u root ${CONTAINER_PHPMYADMIN} apt-get update > /dev/null
  docker exec -u root ${CONTAINER_PHPMYADMIN} apt-get install -y iputils-ping > /dev/null
  xtrace off
  checkInteractiveMode

  print_info "Check connection from ${CONTAINER_PHPMYADMIN} to ${CONTAINER_MYSQL} by name"
  docker_utils::execContainerPingAsRoot ${CONTAINER_PHPMYADMIN} ${CONTAINER_MYSQL}
  if [ $? -ne 0 ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  checkInteractiveMode
  print_info "Check /etc/hosts file from ${CONTAINER_PHPMYADMIN}"
  print_debug "No line added in /etc/hosts because network uses DNS and containers can resolve each other by name "
  docker_utils::execContainer ${CONTAINER_PHPMYADMIN} "cat /etc/hosts"

  print_info "Check that the ${CONTAINER_PHPMYADMIN} container can connect to the ${CONTAINER_MYSQL} container."
  print_debug "Open a browser and access to http://localhost:${PHPMYADMIN_HOST_PORT}"
  print_debug "Note that the name of the server you want to access is the name of the mysql container."
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

main $@
