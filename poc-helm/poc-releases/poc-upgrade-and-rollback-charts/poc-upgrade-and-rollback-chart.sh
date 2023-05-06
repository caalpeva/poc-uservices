#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/uservices.src"
source "${DIR}/../../../poc-k8s/utils/kubectl.src"
source "${DIR}/../../utils/helm.src"

#############
# VARIABLES #
#############

CHARTS_DIRECTORY="${DIR}/charts"
CONFIGURATION_FILE1=${DIR}/config/custom-values.yaml
CONFIGURATION_FILE2=${DIR}/config/custom-values2.yaml
CONFIGURATION_FILE3=${DIR}/config/custom-values3.yaml

NAMESPACE="poc-charts"

CHART_NAME="loop-message"
CHART_RELEASE="poc-$CHART_NAME"
SERVICE_NAME=$CHART_RELEASE

LABELS="app.kubernetes.io/name=$CHART_NAME,app.kubernetes.io/instance=$CHART_RELEASE"
LOCAL_PORT=8080

#############
# FUNCTIONS #
#############

function initialize() {
  print_info "Preparing poc environment..."
  setTerminalSignals
  check_mandatory_command_installed tree
  cleanup
}

function handleTermSignal() {
  xtrace off
  print_warn "Handling termination signal..."
  cleanup
  exit 1
}

function cleanup() {
  print_debug "Cleaning environment..."
  if [ -n "$PORT_FORWARD_PID" ]; then
    print_info "Kill the execution of the port-forward command"
    evalCommand kill -9 $PORT_FORWARD_PID
  fi
  helm::uninstallChart $CHART_RELEASE --namespace $NAMESPACE
  kubectl delete ns $NAMESPACE
}

function main() {
  print_debug "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "UPGRATE AND ROLLBACK CHART" \
    "" \
    " - Proof of concept about chat upgrate and rollback"
  checkInteractiveMode

  kubectl::showNodes

  print_info "Before installing the chart, find out what values can be set."
  helm::showDefaultLimitedChartValues 25 "${CHARTS_DIRECTORY}/$CHART_NAME"

  helm::installChartSilently $CHART_RELEASE "${CHARTS_DIRECTORY}/$CHART_NAME" \
    --namespace $NAMESPACE --create-namespace \
    -f $CONFIGURATION_FILE1 \
    #--wait

  helm::historyChart $CHART_RELEASE --namespace $NAMESPACE
  helm::getCustomValues $CHART_RELEASE -n $NAMESPACE

  kubectl::showDeployments -n $NAMESPACE -l $LABELS
  kubectl::showReplicaSets -n $NAMESPACE -l $LABELS
  kubectl::showPods -n $NAMESPACE -l $LABELS

  print_info "Wait for a few seconds to show logs..." && sleep 5
  RUNNING_PODS=($(kubectl::getRunningPods -n $NAMESPACE -l $LABELS))
  kubectl::showLogs ${RUNNING_PODS[0]} -n $NAMESPACE -l $LABELS

  helm::upgradeChartSilently $CHART_RELEASE "${CHARTS_DIRECTORY}/$CHART_NAME" \
    --namespace $NAMESPACE \
    --version 10.6.3 \
    -f $CONFIGURATION_FILE2

  helm::historyChart $CHART_RELEASE --namespace $NAMESPACE
  helm::getCustomValues $CHART_RELEASE -n $NAMESPACE

  kubectl::showDeployments -n $NAMESPACE -l $LABELS
  kubectl::showReplicaSets -n $NAMESPACE -l $LABELS
  kubectl::showPods -n $NAMESPACE -l $LABELS

  print_info "Wait for a few seconds to show logs..." && sleep 5
  RUNNING_PODS=($(kubectl::getRunningPods -n $NAMESPACE -l $LABELS))
  kubectl::showLogs ${RUNNING_PODS[0]} -n $NAMESPACE -l $LABELS

  print_info "Check chart upgrade"
  print_debug "Note that environment variables have changed."
  print_debug "Note that it uses a second replicaset that groups the new pod that are updated."
  checkInteractiveMode

  helm::upgradeChartSilently $CHART_RELEASE "${CHARTS_DIRECTORY}/$CHART_NAME" \
    --namespace $NAMESPACE \
    --version 10.6.4 \
    --values $CONFIGURATION_FILE3

  helm::historyChart $CHART_RELEASE --namespace $NAMESPACE
  helm::getCustomValues $CHART_RELEASE -n $NAMESPACE

  kubectl::showDeployments -n $NAMESPACE -l $LABELS
  kubectl::showReplicaSets -n $NAMESPACE -l $LABELS
  kubectl::showPods -n $NAMESPACE -l $LABELS

  print_info "Wait for a few seconds to show logs..." && sleep 5
  RUNNING_PODS=($(kubectl::getRunningPods -n $NAMESPACE -l $LABELS))
  kubectl::showLogs ${RUNNING_PODS[0]} -n $NAMESPACE -l $LABELS

  print_info "Check chart upgrade again"
  print_debug "Note that environment variables have changed again."
  print_debug "Note that it uses a third replicaset that groups the new pod that are updated."
  checkInteractiveMode

  helm::rollbackChart $CHART_RELEASE 2 --namespace $NAMESPACE

  print_info "List chart releases after rollback"
  helm::showChartReleasesByPrefix $CHART_RELEASE -n $NAMESPACE
  helm::historyChart $CHART_RELEASE --namespace $NAMESPACE
  helm::getCustomValues $CHART_RELEASE -n $NAMESPACE

  kubectl::showDeployments -n $NAMESPACE -l $LABELS
  kubectl::showReplicaSets -n $NAMESPACE -l $LABELS
  kubectl::showPods -n $NAMESPACE -l $LABELS

  print_info "Wait for a few seconds to show logs..." && sleep 5
  RUNNING_PODS=($(kubectl::getRunningPods -n $NAMESPACE -l $LABELS))
  kubectl::showLogs ${RUNNING_PODS[0]} -n $NAMESPACE -l $LABELS

  print_info "Check chart rollback"
  print_debug "Note that a version is rolled back to a previous revision"
  print_debug "Check that the environment variables are correct in that revision."
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

#############
# EXECUTION #
#############

main $@
