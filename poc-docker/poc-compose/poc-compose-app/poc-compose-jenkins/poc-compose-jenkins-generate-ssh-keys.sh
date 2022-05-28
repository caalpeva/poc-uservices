#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../../../utils/microservices-utils.src"
source "${DIR}/../../../utils/docker.src"
source "${DIR}/../../../utils/docker-compose.src"

TMP_DIRECTORY="${DIR}/tmp"

function generateSshKeys {
  print_info "Generate ssh keys"
  xtrace on
  ssh-keygen -f ${TMP_DIRECTORY}/key -m PEM -N ''
  xtrace off
  checkInteractiveMode

  print_info "Create common.env file with public key content"
  xtrace on
  echo "JENKINS_AGENT_SSH_PUBKEY=$(cat ${TMP_DIRECTORY}/key.pub)" > ${TMP_DIRECTORY}/common.env
  xtrace off
  checkInteractiveMode
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@

  rm -rf ${TMP_DIRECTORY}
  print_debug "Creating tmp directory..."
  if [ ! -d ${TMP_DIRECTORY} ]; then
    xtrace on
    mkdir ${TMP_DIRECTORY}
    xtrace off
  fi

  print_box "GENERATE SSH KEYS" \
    "" \
    " - Generate ssh keys to securely access remote machines via command line."
  checkInteractiveMode

  generateSshKeys

  print_done "SSH keys generated"
  exit 0
}

main $@
