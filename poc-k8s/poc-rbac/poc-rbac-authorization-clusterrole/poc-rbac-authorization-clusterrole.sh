#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

CONFIGURATION1_FILE=${DIR}/config/clusterrole.yaml
CONFIGURATION2_FILE=${DIR}/config/clusterrolebinding.yaml
CLUSTERROLE_NAME="poc-rbac-clusterrole"
CLUSTERROLEBINDING_NAME="poc-rbac-clusterrolebinding"
POC_LABEL_VALUE=poc-rbac-authorization

TMP_DIRECTORY="${DIR}/../tmp"
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
  kubectl::unsetKubeconfig
  kubectl::unapply $CONFIGURATION2_FILE
  kubectl::unapply $CONFIGURATION1_FILE
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "CLUSTERROLE AUTHORIZATION" \
    "" \
    " - Check the RBAC authorization is successful with the new kubeconfig file" \
    "   and when the clusterrole and clusterrolebinding configuration is applied."
  checkInteractiveMode

  print_info "Before applying the cluster role configuration, we make sure that we are using the administrator user, eliminating the KUBECONFIG variable."
  kubectl::unsetKubeconfig
  kubectl::showKubeconfig
  kubectl::showNodes

  kubectl::apply $CONFIGURATION1_FILE
  kubectl::apply $CONFIGURATION2_FILE

  kubectl::showClusterRoles -l "poc=$POC_LABEL_VALUE"
  kubectl::showClusterRoleDescription $CLUSTERROLE_NAME
  kubectl::showClusterRoleBindings -l "poc=$POC_LABEL_VALUE"
  kubectl::showClusterRoleBindingDescription $CLUSTERROLEBINDING_NAME

  if [ ! -f ${KUBECONFIG_FILE} ]; then
    print_error "New kubeconfig not found."
    exit 1
  fi

  print_info "Set the kubeconfig to refer to the file that contains the user credentials"
  kubectl::setKubeconfig ${KUBECONFIG_FILE}
  kubectl::showKubeconfig

  print_info "Check that you have permissions to list pods in default namespace"
  kubectl::showPods

  print_info "Check that you also have permissions to list pods in other namespaces"
  kubectl::showPods -n kube-system

  print_info "Check that you doesn't have permissions to access to others cluster resources"
  kubectl::showServices

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
