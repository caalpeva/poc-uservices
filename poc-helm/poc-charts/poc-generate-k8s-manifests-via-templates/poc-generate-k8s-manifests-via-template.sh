#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/uservices-utils.src"
source "${DIR}/../../../poc-k8s/utils/kubectl.src"
source "${DIR}/../../utils/helm.src"

#############
# VARIABLES #
#############

CHARTS_DIRECTORY="${DIR}/charts"
TMP_DIRECTORY="${DIR}/tmp"

NAMESPACE="poc-charts"

CHART_NAME="mysql"
CHART_RELEASE="poc-$CHART_NAME"
SERVICE_NAME=$CHART_RELEASE

TEMPLATE_DIRECTORY="${DIR}/charts/${CHART_NAME}/templates"

MYSQL_DATABASE="CYCLING"

LABELS="app.kubernetes.io/name=$CHART_NAME,app.kubernetes.io/instance=$CHART_RELEASE"

#############
# FUNCTIONS #
#############

function initialize() {
  print_info "Preparing poc environment..."
  setTerminalSignals
  check_mandatory_command_installed tree
  cleanup
  print_debug "Creating temporal directory..."
  if [ ! -d ${TMP_DIRECTORY} ]; then
    evalCommand mkdir ${TMP_DIRECTORY}
  fi
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
  evalCommand rm -rf ${TMP_DIRECTORY}
}

function showDatabase {
  POD_NAME=$1
  MYSQL_ROOT_PASSWORD=$2
  xtrace on
  docker -n $NAMESPACE exec $POD_NAME \
    mysql -uroot -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} \
    --table -e "select * from TEAM"

  docker -n $NAMESPACE exec $POD_NAME \
    mysql -uroot -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} \
    --table -e "select * from RIDER"
  xtrace off
  sleep 1

  checkInteractiveMode
}

function main() {
  print_debug "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "GENERATE K8S MANIFESTS VIA TEMPLATE" \
    "" \
    " - Proof of concept about k8s manifests creation from templates"
  checkInteractiveMode

  kubectl::showNodes

  helm::templateFiles "${CHARTS_DIRECTORY}/$CHART_NAME" \
    "templates/configmap-scripts-initial.yaml"

  helm::templateFiles "${CHARTS_DIRECTORY}/$CHART_NAME" \
    "templates/deployment.yaml"

  helm::installChart $CHART_RELEASE "${CHARTS_DIRECTORY}/$CHART_NAME" \
    --namespace $NAMESPACE --create-namespace \
    --wait

  print_info "Show chart instance"
  helm::showChartReleasesByPrefix $CHART_RELEASE -n $NAMESPACE

  kubectl::showDeployments -n $NAMESPACE -l $LABELS
  kubectl::showReplicaSets -n $NAMESPACE -l $LABELS
  kubectl::showPods -n $NAMESPACE -l $LABELS
  kubectl::showServices -n $NAMESPACE -l $LABELS
  kubectl::showEndpointsByService $SERVICE_NAME -n $NAMESPACE

  MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace poc-charts poc-mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode)
  POD_NAME=$(kubectl get pods --namespace poc-charts -l "$LABELS" -o jsonpath="{.items[0].metadata.name}")

  print_info "Show database"
  showDatabase $POD_NAME $MYSQL_ROOT_PASSWORD

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

#############
# EXECUTION #
#############

main $@
