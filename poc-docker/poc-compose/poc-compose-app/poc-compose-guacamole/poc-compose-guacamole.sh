#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../../../utils/microservices-utils.src"
source "${DIR}/../../../utils/docker-utils.src"
source "${DIR}/../../../utils/docker-compose.src"

PROJECT_NAME="poc_guacamole"
NETWORK_NAME="${PROJECT_NAME}_network"
IMAGE="centos-server-ssh"

CONTAINER_PREFIX="poc_guacamole"
CONTAINER_MYSQL="${CONTAINER_PREFIX}_mysql"
CONTAINER_SSH="${CONTAINER_PREFIX}_server_ssh"

MYSQL_ROOT_PASSWORD="root"
MYSQL_DATABASE="guacamole_db"

SSH_SERVER_USER="guacamole"
SSH_SERVER_PASSWORD="1234"

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
  containers=($(docker_utils::getAllContainerIdsByPrefix ${CONTAINER_SSH}))
  docker_utils::removeContainers ${containers[*]}
  docker_compose::downWithProjectName $PROJECT_NAME -v
  docker_utils::removeImages $IMAGE
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

function executeSshServerContainer {
  print_info "Execute SSH server container in same network"
  xtrace on
  docker run -dit \
    --name ${CONTAINER_SSH} \
    --restart always \
    --network $NETWORK_NAME \
    ${IMAGE}

  xtrace off
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "GUACAMOLE" \
    "" \
    " - Guacamole is a web manager for ssh connections." \
    " - For this test to work correctly it is necessary to install the sshpass tool."
  checkInteractiveMode

  docker_utils::createImageFromDockerfile $IMAGE \
    "--build-arg NEWUSER=$SSH_SERVER_USER" \
    "--build-arg NEWUSER_PASSWORD=$SSH_SERVER_PASSWORD" \
    "--file dockerfile-server-ssh" $DIR

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

  executeSshServerContainer
  print_info "Create file in ssh server container"
  xtrace on
  docker exec $CONTAINER_SSH sh -c "echo \"hello\" > test.txt"
  xtrace off
  checkInteractiveMode

  print_info "Get ip address from ssh server container"
  SSH_SERVER_IP=$(docker_utils::getIpAddressFromContainer ${CONTAINER_SSH} "${NETWORK_NAME}")
  echo ${SSH_SERVER_IP}
  checkInteractiveMode

  print_info "Check ssh connection to ssh server container from localhost"
  print_debug "Do not enter any passwd, press 3 times enter"
  evalCommand "ssh ${SSH_SERVER_IP} -o \"StrictHostKeyChecking no\""

  print_debug "You need to install the sshpass tool"
  evalCommand "sshpass -p $SSH_SERVER_PASSWORD ssh $SSH_SERVER_USER@${SSH_SERVER_IP} \"whoami && pwd && cat test.txt\""
  if [ $? -ne 0 ]; then
    print_error "Error connecting via ssh."
    exit 1
  fi

  checkInteractiveMode
  print_info "Check ssh conection via guacamole web"
  print_debug "Interactive with guacamole in http://localhost:80 with credentials (guacadmin/guacadmin)"
  print_debug "Create SSH connection with ip $SSH_SERVER_IP and port 22 and credentias ($SSH_SERVER_USER/$SSH_SERVER_PASSWORD)"
  print_debug "Verify the test.txt file created"
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

main $@
