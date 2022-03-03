#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"
source "${DIR}/../../utils/docker-utils.src"

CONTAINER_PREFIX="poc_nginx"
CONTAINER1_NAME="${CONTAINER_PREFIX}_1"
TMP_DIRECTORY="${DIR}/tmp"

CONTAINER_HTTP_PORT="80"
HOST_HTTP_PORT="8080"

function initialize() {
  print_info "Preparing poc environment..."
  setTerminalSignals
  cleanup
  print_debug "Creating temporal files..."
  if [ ! -d ${TMP_DIRECTORY} ]; then
    xtrace on
    mkdir ${TMP_DIRECTORY}
    xtrace off
  fi
  xtrace on
  cp -r ${DIR}/webapps/nginx/* ${TMP_DIRECTORY}
  ls -l ${TMP_DIRECTORY}
  xtrace off
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
  xtrace on
  rm -rf ${TMP_DIRECTORY}
  xtrace off
}

function executeContainers {
  print_info "Execute container with HTTP server..."
  xtrace on
  docker run -d \
    --rm \
    --name ${CONTAINER1_NAME} \
    -p ${HOST_HTTP_PORT}:${CONTAINER_HTTP_PORT} \
    -v ${TMP_DIRECTORY}:/usr/share/nginx/html \
    nginx

  xtrace off
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  executeContainers
  print_info "Check containers status..."
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}
  docker_utils::getContainerMounts ${CONTAINER1_NAME}

  docker_utils::checkHttpServerAvailability ${CONTAINER1_NAME} ${CONTAINER_HTTP_PORT}
  isHttpServer1Available=$?

  if [ $isHttpServer1Available -ne 0 ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  print_info "Check local modifications on shared storage..."
  textToReplace="Welcome ${USER^}"
  xtrace on
  sed -i "s/Nginx works!/Nginx works! $textToReplace/g" ${TMP_DIRECTORY}/index.html
  cat ${TMP_DIRECTORY}/index.html
  xtrace off
  checkInteractiveMode

  docker_utils::checkHttpServerAvailability ${CONTAINER1_NAME} ${CONTAINER_HTTP_PORT}
  isHttpServer1Available=$?

  if [ $isHttpServer1Available -ne 0 ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  print_info "Add file to container storage (rw)..."
  docker_utils::copyFiles ${DIR}/webapps/logo.png ${CONTAINER1_NAME}:/usr/share/nginx/html

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
