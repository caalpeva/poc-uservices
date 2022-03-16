#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../../../utils/microservices-utils.src"
source "${DIR}/../../../utils/docker.src"
source "${DIR}/../../../utils/docker-compose.src"

PROJECT_NAME="poc_lamp"

CONTAINER_PREFIX="poc_lamp"
CONTAINER_MYSQL="${CONTAINER_PREFIX}_mysql"

MYSQL_ROOT_PASSWORD="root"
MYSQL_DATABASE="SIMPSONS"

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
  docker_compose::downWithProjectName $PROJECT_NAME -v
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
  --table -e "select * from CHARACTERS"

  xtrace off
  sleep 1

  checkInteractiveMode
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_info "Execute docker-compose"
  docker_compose::upWithProjectName $PROJECT_NAME

  print_info "Check containers status..."
  docker_compose::psWithProjectName $PROJECT_NAME

  print_info "Waiting for available mysql server..."
  waitForMysqlAvailable $CONTAINER_MYSQL &
  PID=$!
  showProgressBar $PID
  wait $PID
  if [ $? -ne 0 ]; then
    print_error "Timeout. Mysql server unavailable"
    exit 1
  fi

  print_info "Show database"
  showDatabase $CONTAINER_MYSQL

  print_info "Check container connections: apache and phpmyadmin"
  print_debug "Interactive with apache in http://localhost:80 to manage characters"
  print_debug "Verify user data with phpmyadmin in http://localhost:8080"
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

main $@
