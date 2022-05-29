#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../../poc-docker/utils/docker.src"
source "${DIR}/../utils/kubectl.src"

TMP_DIRECTORY="${DIR}/tmp"
USERNAME=user
KUBECONFIG_FILE=${TMP_DIRECTORY}/${USERNAME}-config

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
  xtrace on
  unset KUBECONFIG
  xtrace off
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "RBAC AUTHENTICATION" \
    "" \
    " - Check the RBAC authentication is successful with the new kubeconfig file" \
    "   but the user still does not have permissions to access the cluster resources."
  checkInteractiveMode

  print_info "Before applying the role configuration, we make sure that we are using the administrator user, eliminating the KUBECONFIG variable."
  kubectl::unsetKubeconfig
  kubectl::showKubeconfig
  kubectl::showNodes

  print_info "Check that you have permissions to to access the cluster resources pods"
  kubectl::showPods
  kubectl::showServices

  if [ ! -f ${KUBECONFIG_FILE} ]; then
    print_error "New kubeconfig not found."
    checkCleanupMode
    exit 1
  fi

  print_info "Set the kubeconfig to refer to the file that contains the user credentials"
  xtrace on
  export KUBECONFIG=${KUBECONFIG_FILE}
  xtrace off
  checkInteractiveMode

  kubectl::showKubeconfig

  print_info "Check that you doesn't have permissions to access the cluster resources"
  kubectl::showPods
  kubectl::showPods -n kube-system
  kubectl::showServices

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
