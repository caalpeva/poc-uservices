#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

TMP_DIRECTORY="${DIR}/tmp"

CONFIGURATION_FILE=${DIR}/deployment.yaml
SECRET_NAME="poc-secret-as-volume"
DEPLOYMENT_NAME=$SECRET_NAME
POC_LABEL_VALUE=$SECRET_NAME

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
}

function handleTermSignal() {
  xtrace off
  print_warn "Handling termination signal..."
  cleanup
  exit 1
}

function cleanup {
  print_debug "Cleaning environment..."
  kubectl::unapply $CONFIGURATION_FILE
  kubectl::unapply ${TMP_DIRECTORY}/*
  #kubectl::deleteSecret $SECRET_NAME
  xtrace on
  rm -rf ${TMP_DIRECTORY}
  xtrace offpoc-secret-as-volume
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  kubectl::showNodes

  kubectl::createGenericSecret ${TMP_DIRECTORY}/secret.yaml \
    ${SECRET_NAME} "poc: $POC_LABEL_VALUE" \
    --from-file=${DIR}/text.txt
  kubectl::showSecrets -l "poc=$POC_LABEL_VALUE"
  kubectl::showSecretDescription ${SECRET_NAME}

  kubectl::apply $CONFIGURATION_FILE
  kubectl::waitForDeployment $DEPLOYMENT_NAME
  kubectl::showDeployments -l "poc=$POC_LABEL_VALUE"
  kubectl::showReplicaSets -l "poc=$POC_LABEL_VALUE"
  kubectl::showPods -l "poc=$POC_LABEL_VALUE"

  print_info "Show logs..."
  POD_NAME=$(kubectl::getFirstPodName -l "poc=$POC_LABEL_VALUE")
  kubectl::showLogs $POD_NAME

  print_info "Check files created"
  kubectl::execUniqueContainer $POD_NAME "ls -l /tmp/files"

  print_info "Check file content"
  kubectl::execUniqueContainerWithReturnCarriage $POD_NAME "cat /tmp/files/text.txt"

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
