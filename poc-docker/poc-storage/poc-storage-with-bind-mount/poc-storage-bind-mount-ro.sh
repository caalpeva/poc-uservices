#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"
source "${DIR}/../../utils/docker.src"

CONTAINER_PREFIX="poc_php_apache"
CONTAINER1_NAME="${CONTAINER_PREFIX}_1"
TMP_DIRECTORY="${DIR}/tmp"

CONTAINER_HTTP_PORT="80"
HOST_HTTP_PORT="80"

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
  cp -r ${DIR}/webapps/php-apache/* ${TMP_DIRECTORY}
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
  containers=($(docker::getAllContainerIdsByPrefix ${CONTAINER_PREFIX}))
  docker::removeContainers ${containers[*]}
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
    -v ${TMP_DIRECTORY}:/var/www/html:ro \
    php:7.2-apache

  xtrace off
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  executeContainers
  print_info "Check containers status..."
  docker::showContainersByPrefix ${CONTAINER_PREFIX}
  docker::getContainerMounts ${CONTAINER1_NAME}

  docker::checkHttpServerAvailability ${CONTAINER1_NAME} ${CONTAINER_HTTP_PORT}
  isHttpServer1Available=$?

  if [ $isHttpServer1Available -ne 0 ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  print_info "Try to add file to container storage (readonly)..."
  docker::copyFiles ${DIR}/webapps/logo.png ${CONTAINER1_NAME}:/var/www/html

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
