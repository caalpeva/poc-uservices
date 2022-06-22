#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

TMP_DIRECTORY="${DIR}/tmp"

CONFIG_DIR=${DIR}/config
CONFIGFILE_POD=${CONFIG_DIR}/pod.yaml
POC_LABEL_VALUE="poc-probe-startup"
POD_NAME=$POC_LABEL_VALUE
CONFIGMAP_NAME="$POC_LABEL_VALUE-configmap-file"

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
  kubectl::unapplyReplacingPaths ${DIR} $CONFIGFILE_POD
  kubectl::unapply ${TMP_DIRECTORY}/*
  xtrace on
  rm -rf ${TMP_DIRECTORY}
  xtrace off
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "STARTUP PROBES" \
    "" \
    " - The kubelet uses startup probes to know when a container application has started." \
    "   If such a probe is configured, it disables liveness and readiness checks until it succeeds," \
    "   making sure those probes don't interfere with the application startup." \
    "   This can be used to adopt liveness checks on slow starting containers," \
    "   avoiding them getting killed by the kubelet before they are up and running."
  checkInteractiveMode

  kubectl::showNodes

  print_info "Create configmap from sql file and edit labels"
  kubectl::createConfigMap ${TMP_DIRECTORY}/configmap.yaml \
    ${CONFIGMAP_NAME} "poc: $POC_LABEL_VALUE" \
    --from-file=${CONFIG_DIR}/init-db.sql

  kubectl::applyReplacingPaths ${DIR} $CONFIGFILE_POD && sleep 1
  kubectl::showConfigMaps -l "poc=$POC_LABEL_VALUE"
  kubectl::showPods

  print_info "Wait a while for kubelet to use startup probes..."
  print_debug "Note that while the server is not available, the pod is marked as not ready"
  kubectl::showStartupProbe $POD_NAME
  kubectl::waitForReadyPod $POD_NAME
  kubectl::showPods

  print_info "Show database"
  xtrace on
  kubectl exec $POD_NAME -- mysql -uroot -proot SIMPSONS \
    --table -e "select * from CHARACTERS"
  xtrace off

  print_info "After waiting for the server with startup probe, the server is forced to stop"
  kubectl::execUniqueContainer $POD_NAME service mysql stop

  print_info "Wait a while for kubelet to use liveness probes..."
  kubectl::showLivenessProbe $POD_NAME && sleep 3
  kubectl::waitForReadyPod $POD_NAME
  kubectl::showPods
  print_debug "Note that when liveness probe fails the pod is restarted"

  print_info "Show database again"
  xtrace on
  kubectl exec $POD_NAME -- mysql -uroot -proot SIMPSONS \
    --table -e "select * from CHARACTERS"
  xtrace off

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
