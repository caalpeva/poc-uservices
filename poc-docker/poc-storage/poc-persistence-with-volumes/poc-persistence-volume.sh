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

TIMEOUT_SECS=90 # Set timeout in seconds
INTERVAL_SECS=5   # Set interval (duration) in seconds

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

function checkMysqlAvailable() {
  isTraceEnabled=${1:-false}
  if [ $isTraceEnabled = true ]; then
      xtrace on
  fi

  docker exec -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
  ${CONTAINER1_NAME} mysql -uroot -p${MYSQL_ROOT_PASSWORD} \
  -e "SELECT 1 FROM DUAL" > /dev/null 2>&1
  # ${CONTAINER1_NAME} mysql -e "SELECT CURDATE()"

  result=$?
  xtrace off
  return $result
}

function waitForMysqlAvailable() {
  checkMysqlAvailable true
  local isMysqlAvailable=$?

  print_warn "Waiting for available mysql server..."
  local endTime=$(( $(date +%s) + $TIMEOUT_SECS )) # Calculate end time.
  while [ $isMysqlAvailable != 0 -a $(date +%s) -lt $endTime ]; do  # Loop until interval has elapsed.
    sleep $INTERVAL_SECS
    checkMysqlAvailable
    isMysqlAvailable=$?
  done

  return $isMysqlAvailable
}

function showTableContents {
  xtrace on
  docker exec -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
  ${CONTAINER1_NAME} mysql -uroot -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} \
  -e "select * from TEAM"

  docker exec -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
  ${CONTAINER1_NAME} mysql -uroot -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} \
  -e "select * from RIDER" 2>&1
  xtrace off

  checkInteractiveMode
}

function updateDatabase {
  xtrace on
  docker exec -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
  ${CONTAINER1_NAME} mysql -uroot -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} \
  -e "source /update.sql"
  xtrace off

  checkInteractiveMode
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

  print_info "Check mysql server availability"
  waitForMysqlAvailable
  if [ $? -ne 0 ]; then
    print_error "Timeout. Mysql server unavailable"
    exit 0
  fi

  showTableContents
  updateDatabase
  showTableContents

  print_info "Check containers status again..."
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
