#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../../../utils/uservices.src"
source "${DIR}/../../../utils/docker.src"
source "${DIR}/../../../utils/docker-compose.src"

PROJECT_NAME="poc_cadence"
NETWORK_NAME="${PROJECT_NAME}_network"

CONTAINER_PREFIX="poc_cadence"
DOMAIN_NAME="poc-domain"

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
  containers=($(docker::getAllContainerIdsByPrefix ${CONTAINER_SSH}))
  docker_compose::downWithProjectName $PROJECT_NAME -v
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "CADENCE" \
    "" \
    " Cadence is a programming framework and managed service" \
    " that enables developers to create and coordinate tasks."
  checkInteractiveMode

  print_info "Execute docker-compose"
  docker_compose::upWithProjectName $PROJECT_NAME
  sleep 60 &
  PID=$!
  showProgressBar $PID
  wait $PID

  print_info "Check containers status..."
  docker_compose::psWithProjectName $PROJECT_NAME

  print_info "Register domain..."
  xtrace on
  docker run --network=host \
    --rm ubercadence/cli:master \
      --do $DOMAIN_NAME domain register -rd 1
  xtrace off
  sleep 5 && checkInteractiveMode

  print_info "Check that domain is registered"
  xtrace on
  docker run --network=host \
    --rm ubercadence/cli:master \
      --do $DOMAIN_NAME domain describe
  xtrace off
  checkInteractiveMode

  print_info "Start workflow..."
  xtrace on
  docker run --network=host \
    --rm ubercadence/cli:master \
      --do $DOMAIN_NAME workflow start \
      --tasklist PocTaskList \
      --workflow_type PocWorkflow::greeting \
      --execution_timeout 3600 --input \"$USER\"
  xtrace off
  checkInteractiveMode

  print_info "Show workflow executions..."
  xtrace on
  docker run --network=host \
    --rm ubercadence/cli:master \
      --do $DOMAIN_NAME workflow list
  xtrace off
  #docker run --network=host --rm ubercadence/cli:master --do $DOMAIN_NAME workflow showid <WORKFLOW_ID>
  #checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

main $@
