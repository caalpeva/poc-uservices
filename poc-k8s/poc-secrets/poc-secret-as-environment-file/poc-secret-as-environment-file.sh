#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/uservices.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

TMP_DIRECTORY="${DIR}/tmp"

CONFIG_DIR=${DIR}/config
CONFIGURATION_FILE=${CONFIG_DIR}/deployment.yaml
SECRET_NAME="poc-secret-as-environment-file"
DEPLOYMENT_NAME=$SECRET_NAME
POC_LABEL_VALUE=$SECRET_NAME

CHARACTER="una-corona."
SLEEP_TIME="3s"

HIDDEN_PLACE="un_pueblo_muy_lejano."

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
  xtrace off
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  kubectl::showNodes

  kubectl::createGenericSecret ${TMP_DIRECTORY}/secret.yaml \
    ${SECRET_NAME} "poc: $POC_LABEL_VALUE" \
    --from-literal=CHARACTER=${CHARACTER} \
    --from-literal=SLEEP_TIME=${SLEEP_TIME}
  kubectl::showSecrets -l "poc=$POC_LABEL_VALUE"
  kubectl::showSecretDescription ${SECRET_NAME}

  print_info "Decode secret value"
  print_debug "Check that the generated file has the values encoded in base64"
  DECODED_VALUE=$(kubectl::decodeSecretByKey ${SECRET_NAME} "CHARACTER")
  echo $DECODED_VALUE
  if [ $CHARACTER != $DECODED_VALUE ]; then
    print_error "Poc failure. Unexpected decoded value."
    exit 1
  fi

  kubectl::apply $CONFIGURATION_FILE
  kubectl::waitForDeployment $DEPLOYMENT_NAME
  kubectl::showDeployments -l "poc=$POC_LABEL_VALUE"
  kubectl::showReplicaSets -l "poc=$POC_LABEL_VALUE"
  kubectl::showPods -l "poc=$POC_LABEL_VALUE"

  print_info "Show logs..."
  POD_NAME=$(kubectl::getFirstPodName -l "poc=$POC_LABEL_VALUE")
  kubectl::showLogs $POD_NAME

  print_info "Check environment variables"
  kubectl::execUniqueContainer $POD_NAME env
  #kubectl::execUniqueContainer $POD_NAME env | grep CHARACTER

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
