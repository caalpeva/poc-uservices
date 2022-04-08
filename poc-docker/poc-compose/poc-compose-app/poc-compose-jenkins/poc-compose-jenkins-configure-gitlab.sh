#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../../../utils/microservices-utils.src"
source "${DIR}/../../../utils/docker.src"
source "${DIR}/../../../utils/docker-compose.src"

GITLAB_DOMAIN="gitlab.example.com"

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
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_info "To execute this script successfully, it is necessary to manually execute the steps indicated in the readme.md file."
  print_debug "Create the corresponding job entries in jenkins."
  print_debug "Create repository and user in gitlab."
  checkInteractiveMode

  print_info "Check /etc/hosts file"
  evalCommand "cat /etc/hosts | grep -i $GITLAB_DOMAIN"
    if [ $? -ne 0  ]; then
    xtrace on
    sudo echo "127.0.0.1  $GITLAB_DOMAIN" >> /etc/hosts
    xtrace off
  fi

  print_info "Add application code to gitlab"
  xtrace on
  cd app
  git init
  git remote add origin http://$GITLAB_DOMAIN/poc/poc-app-maven-simple.git
  git add .
  git commit -m "Initial commit"
  git push -u origin master
  xtrace off
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

main $@
