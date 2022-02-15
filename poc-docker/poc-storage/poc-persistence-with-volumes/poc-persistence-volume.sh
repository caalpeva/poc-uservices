#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"
source "${DIR}/../../utils/docker-utils.src"

CONTAINER_PREFIX="poc_mysql"
CONTAINER1_NAME="${CONTAINER_PREFIX}_1"

CONTAINER_PORT="3306"
HOST_PORT="3306"
VOLUMEN_NAME="mysql_data"

MYSQL_ROOT_PASSWORD="root"
MYSQL_DATABASE="CYCLING"
MYSQL_USER="user"
MYSQL_PASSWORD="password"

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
  docker_utils::removeVolumes ${VOLUMEN_NAME}
}

function executeContainers {
  print_info "Execute container with MySQL server..."
  xtrace on
  docker run -d \
    --name ${CONTAINER1_NAME} \
    -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
    -e MYSQL_DATABASE=${MYSQL_DATABASE} \
    -e MYSQL_USER=${MYSQL_USER} \
    -e MYSQL_PASSWORD=${MYSQL_PASSWORD} \
    -p ${HOST_PORT}:${CONTAINER_PORT} \
    -v ${VOLUMEN_NAME}:/var/lib/mysql \
    -v ${DIR}/scripts/initial:/docker-entrypoint-initdb.d \
    -v ${DIR}/scripts/update.sql:/update.sql \
    mysql:5.7.28


  #-v ${DIR}/scripts:/docker-entrypoint-initdb.d \
  #-v ${TMP_DIRECTORY}:/usr/share/nginx/html \

  xtrace off
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_info "Create docker volumen..."
  docker_utils::createVolumen ${VOLUMEN_NAME}
  executeContainers
  print_info "Check containers status..."
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}
  docker_utils::getContainerMounts ${CONTAINER1_NAME}

  print_info "Run command in the same running container with tty..."
  print_debug "Use the shell for example to execute:\n\tmysql -u root -p \t# (password = ${MYSQL_ROOT_PASSWORD})"
  print_info "-Type exit or press CTRL+D to exit and stop the container"
  print_info "-Press CTRL+P+Q to keep the container in background"
  docker_utils::execContainerWithTty ${CONTAINER1_NAME} "/bin/bash"

  xtrace on
  docker exec -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
  -e MYSQL_DATABASE=${MYSQL_DATABASE} \
  -e MYSQL_USER=root \
  -e MYSQL_PASSWORD=root \
  ${CONTAINER1_NAME} "mysql  ${MYSQL_DATABASE} <<< source /update.sql"
  docker exec -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
  -e MYSQL_DATABASE=${MYSQL_DATABASE} \
  -e MYSQL_USER=root \
  -e MYSQL_PASSWORD=root \
  ${CONTAINER1_NAME} mysql ${MYSQL_DATABASE} <<< "select * from TEAM"
  xtrace off

  print_info "Check containers status again..."
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
