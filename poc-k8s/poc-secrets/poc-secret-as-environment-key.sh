#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../../poc-docker/utils/docker.src"
source "${DIR}/../utils/kubectl.src"

CONFIGURATION_FILE=${DIR}/config/deployment-with-env-key-from-secret.yaml
SECRET_NAME="poc-secret-as-environment-key"
DEPLOYMENT_NAME="poc-secret-as-environment-key"
POC_LABEL_VALUE="poc-secret-as-environment-key"

HIDDEN_PLACE="un_pueblo_muy_lejano."

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
  kubectl::unapply $CONFIGURATION_FILE
  kubectl::deleteSecret $SECRET_NAME
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  kubectl::showNodes

  kubectl::createGenericSecret $SECRET_NAME "poc: $POC_LABEL_VALUE" \
    --from-literal=hidden-place=${HIDDEN_PLACE}
  kubectl::showSecrets -l "poc=$POC_LABEL_VALUE"
  kubectl::showSecretDescription $SECRET_NAME

  print_info "Decode secret value"
  DECODED_VALUE=$(kubectl::decodeSecretByKey $SECRET_NAME "hidden-place")
  echo $DECODED_VALUE
  if [ $HIDDEN_PLACE != $DECODED_VALUE ]; then
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
