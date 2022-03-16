#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"
source "${DIR}/../../utils/docker.src"

CONTAINER_PREFIX="poc_mysql"
CONTAINER1_NAME="${CONTAINER_PREFIX}_1"
CONTAINER2_NAME="${CONTAINER_PREFIX}_2"

CONTAINER_PORT="3306"
HOST_PORT="3306"

MYSQL_ROOT_PASSWORD="root"
MYSQL_DATABASE="CYCLING"
MYSQL_USER="user"
MYSQL_PASSWORD="password"

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
  containers=($(docker::getAllContainerIdsByPrefix ${CONTAINER_PREFIX}))
  docker::removeContainers ${containers[*]}
  docker::removeVolumes $(docker volume list -q)
}

function checkMysqlAvailable() {
  isTraceEnabled=${2:-false}
  if [ $isTraceEnabled = true ]; then
      xtrace on
  fi

  docker exec $1 mysql -uroot -p${MYSQL_ROOT_PASSWORD} \
  -e "SELECT 1 FROM DUAL" > /dev/null 2>&1
  # ${CONTAINER1_NAME} mysql -e "SELECT CURDATE()"

  result=$?
  xtrace off
  return $result
}

function waitForMysqlAvailable() {
  checkMysqlAvailable $1 true
  local isMysqlAvailable=$?
  local endTime=$(( $(date +%s) + $TIMEOUT_SECS )) # Calculate end time.
  while [ $isMysqlAvailable != 0 -a $(date +%s) -lt $endTime ]; do  # Loop until interval has elapsed.
    sleep $INTERVAL_SECS
    checkMysqlAvailable $1
    isMysqlAvailable=$?
  done
  sleep 10

  return $isMysqlAvailable
}

function showDatabase {
  xtrace on
  docker exec $1 mysql -uroot -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} \
  --table -e "select * from TEAM"

  docker exec $1 mysql -uroot -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} \
  --table -e "select * from RIDER"
  xtrace off
  sleep 1

  checkInteractiveMode
}

function updateDatabase {
  xtrace on
  docker exec $1 mysql -uroot -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} \
  -e "source /update.sql"
  xtrace off
  sleep 1

  checkInteractiveMode
}

function executeContainer {
  print_info "Execute container $1 with MySQL server"
  xtrace on
  docker run -d \
    --name $1 \
    -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
    -e MYSQL_DATABASE=${MYSQL_DATABASE} \
    -e MYSQL_USER=${MYSQL_USER} \
    -e MYSQL_PASSWORD=${MYSQL_PASSWORD} \
    -p ${HOST_PORT}:${CONTAINER_PORT} \
    -v ${DIR}/scripts/initial:/docker-entrypoint-initdb.d \
    -v ${DIR}/scripts/update.sql:/update.sql:ro \
    mysql:5.7.28

  result=$?
  xtrace off

  [ $result -ne 0 ] && print_error "Error starting container" && exit 1
}

function executeContainerAndShowDatabase {
  executeContainer $1
  print_info "Check containers status"
  docker::showContainersByPrefix ${CONTAINER_PREFIX}
  docker::getContainerMounts $1

  print_info "Waiting for available mysql server..."
  waitForMysqlAvailable $1 &
  PID=$!
  showProgressBar $PID
  wait $PID
  if [ $? -ne 0 ]; then
    print_error "Timeout. Mysql server unavailable"
    exit 1
  fi

  print_info "Show database"
  showDatabase $1
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_info "List volumes"
  docker::listVolumes

  # Se crea el primer contenedor con mysql server
  executeContainerAndShowDatabase ${CONTAINER1_NAME}

  print_info "Update database"
  updateDatabase ${CONTAINER1_NAME}
  print_info "Show database after update data"
  showDatabase ${CONTAINER1_NAME}

  print_info "Remove container ${CONTAINER1_NAME} but keep anonymous volume"
  docker::removeContainers ${CONTAINER1_NAME}
  print_info "List volumes"
  docker::listVolumes
  print_info "Check containers status again"
  docker::showContainersByPrefix ${CONTAINER_PREFIX}

  # Se crea el segundo contenedor con mysql server
  executeContainerAndShowDatabase ${CONTAINER2_NAME}

  print_info "List volumes"
  docker::listVolumes

  print_box "ANONYMOUS VOLUMES" \
    "" \
    " - As a different anonymous volume is used in each container, the information is not persisted between containers"
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
