#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

CONFIG_DIR=${DIR}/config
CONFIGFILE_NAMESPACE=${CONFIG_DIR}/namespace.yaml
CONFIGFILE_ROLE=${CONFIG_DIR}/role.yaml
CONFIGFILE_ROLEBINDING=${CONFIG_DIR}/rolebinding.yaml
CONFIGFILE_SERVICEACCOUNT=${CONFIG_DIR}/serviceaccount.yaml
CONFIGFILE_DEPLOYMENT=${CONFIG_DIR}/deployment.yaml

NAMESPACE="poc-rbac-service-account-ns"
DEPLOYMENT_NAME="poc-rbac-service-account"
ROLE_NAME=$DEPLOYMENT_NAME
ROLEBINDING_NAME=$DEPLOYMENT_NAME
POC_LABEL_VALUE=$DEPLOYMENT_NAME

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
  kubectl::unapply ${DIR}/config/*
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "ROLE AUTHORIZATION FOR SERVICE ACCOUNT" \
    "" \
    " - Check the RBAC authorization is successful with the new kubeconfig file" \
    "   and when the role and rolebinding configuration is applied."
  checkInteractiveMode

  print_info "Before applying the role configuration, we make sure that we are using the administrator user, eliminating the KUBECONFIG variable."
  kubectl::unsetKubeconfig
  checkInteractiveMode

  kubectl::showKubeconfig
  kubectl::showNodes

  kubectl::apply $CONFIGFILE_NAMESPACE \
    $CONFIGFILE_SERVICEACCOUNT \
     $CONFIGFILE_ROLE \
     $CONFIGFILE_ROLEBINDING \
     $CONFIGFILE_DEPLOYMENT

  kubectl::showPods -n $NAMESPACE

  print_info "Show logs"
  PODS=($(kubectl::getAllPods -n $NAMESPACE))
  kubectl::showLogsNoTimeout ${PODS[0]} -n $NAMESPACE

  print_info "Check logs"
  print_debug "Check that you do not have permissions to access the requested resource."
  checkInteractiveMode

  print_info "Set role base access control with service account"
  kubectl::apply $CONFIGFILE_ROLE $CONFIGFILE_ROLEBINDING

  kubectl::showRoles -n $NAMESPACE -l "poc=$POC_LABEL_VALUE"
  kubectl::showRoleDescription $ROLE_NAME -n $NAMESPACE
  kubectl::showRoleBindings -n $NAMESPACE -l "poc=$POC_LABEL_VALUE"
  kubectl::showRoleBindingDescription $ROLEBINDING_NAME -n $NAMESPACE

  print_info "Delete the pod to ensure the new pod starts properly configured"
  kubectl::forceDeletePod ${PODS[0]} -n $NAMESPACE

  kubectl::showPods -n $NAMESPACE

  print_info "Show logs"
  RUNNING_PODS=($(kubectl::getRunningPods -n $NAMESPACE))
  kubectl::showLogs ${RUNNING_PODS[0]} -n $NAMESPACE

  print_info "Check logs again"
  print_debug "Check that you now have permissions to access the requested resource."
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
