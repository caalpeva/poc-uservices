#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

export POC_ROLE_TYPE=Group
export POC_ROLE_TYPE_NAME=developers
#export POC_ROLE_TYPE=User
#export POC_ROLE_TYPE_NAME=$USER

CONFIGURATION1_FILE=${DIR}/config/role.yaml
CONFIGURATION2_FILE=${DIR}/config/rolebinding.yaml
ROLE_NAME="poc-rbac-role"
ROLEBINDING_NAME="poc-rbac-rolebinding"
POC_LABEL_VALUE=poc-rbac-authorization

TMP_DIRECTORY="${DIR}/../tmp"
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
  kubectl::unapply $CONFIGURATION1_FILE
  kubectl::unapplyReplacingEnvVars $CONFIGURATION2_FILE
  unset $POC_ROLE_TYPE
  unset $POC_ROLE_TYPE_NAME
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "ROLE AUTHORIZATION" \
    "" \
    " - Check the RBAC authorization is successful with the new kubeconfig file" \
    "   and when the role and rolebinding configuration is applied."
  checkInteractiveMode

  print_info "Before applying the role configuration, we make sure that we are using the administrator user, eliminating the KUBECONFIG variable."
  kubectl::unsetKubeconfig
  checkInteractiveMode

  kubectl::showKubeconfig
  kubectl::showNodes

  kubectl::apply $CONFIGURATION1_FILE
  kubectl::applyReplacingEnvVars $CONFIGURATION2_FILE
  print_debug "Role configuration for: $POC_ROLE_TYPE, $POC_ROLE_TYPE_NAME"

  kubectl::showRoles -l "poc=$POC_LABEL_VALUE"
  kubectl::showRoleDescription $ROLE_NAME
  kubectl::showRoleBindings -l "poc=$POC_LABEL_VALUE"
  kubectl::showRoleBindingDescription $ROLEBINDING_NAME

  if [ ! -f ${KUBECONFIG_FILE} ]; then
    print_error "New kubeconfig not found."
    checkCleanupMode
    exit 1
  fi

  print_info "Set the kubeconfig to refer to the file that contains the user credentials"
  kubectl::setKubeconfig ${KUBECONFIG_FILE}
  kubectl::showKubeconfig

  print_info "Check that you have permissions to list pods in default namespace"
  kubectl::showPods

  print_info "Check that you doesn't have permissions to list pods in other namespaces"
  kubectl::showPods -n kube-system

  print_info "Check that you doesn't have permissions to access to others cluster resources"
  kubectl::showServices

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
