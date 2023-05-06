#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../../utils/uservices.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

CONFIG_DIR=${DIR}/config
CONFIGFILE_DEPLOYMENT_01=${CONFIG_DIR}/deployment-01.yaml
CONFIGFILE_DEPLOYMENT_02=${CONFIG_DIR}/deployment-02.yaml
CONFIGFILE_INGRESS=${CONFIG_DIR}/ingress.yaml

INGRESS_CONTROLLER_NAMESPACE="ingress-nginx"
INGRESS_SERVICE_NAME="ingress-nginx-controller"

DEPLOYMENT_SERVER_01_NAME="poc-deployment-01"
DEPLOYMENT_SERVER_02_NAME="poc-deployment-02"
INGRESS_NAME="poc-ingress-from-external-ip"
POC_LABEL_VALUE=$INGRESS_NAME

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
  kubectl::unapply $CONFIGFILE_INGRESS \
    $CONFIGFILE_DEPLOYMENT_01 \
    $CONFIGFILE_DEPLOYMENT_02
}

function checkServicesAvailable {
  NODE_PORT=$1
  NODE_ADDRESSES=$(kubectl::getMasterNodeAddresses)
  for NODE_ADDRESS in ${NODE_ADDRESSES[@]}
  do
    executeCurl http://${NODE_ADDRESS}:${NODE_PORT}/webapp-server-01/echo
    if [ $? -ne 0 ]
    then
      print_error "Http server from ${NODE_ADDRESS}:${NODE_PORT}/webapp-server-01/echo is not available"
    fi
    executeCurl http://${NODE_ADDRESS}:${NODE_PORT}/webapp-server-02/
    if [ $? -ne 0 ]
    then
      print_error "Http server from ${NODE_ADDRESS}:${NODE_PORT}/webapp-server-02/ is not available"
    fi
  done
  checkInteractiveMode
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "INGRESS FROM EXTERNAL IP" \
    "" \
    " - Checks the ingress behavior from an external IP."
  checkInteractiveMode

  kubectl::showNodes
  kubectl::apply $CONFIGFILE_DEPLOYMENT_01 \
    $CONFIGFILE_DEPLOYMENT_02
  kubectl::waitForDeployment $DEPLOYMENT_SERVER_01_NAME
  kubectl::waitForDeployment $DEPLOYMENT_SERVER_02_NAME
  kubectl::showDeployments -l "poc=$POC_LABEL_VALUE"
  kubectl::showReplicaSets -l "poc=$POC_LABEL_VALUE"
  kubectl::showPods -l "poc=$POC_LABEL_VALUE"
  kubectl::showServices -l "poc=$POC_LABEL_VALUE"
  kubectl::showEndpointsByLabels -l "poc=$POC_LABEL_VALUE"

  print_info "Extract node port from ingress controller service"
  NODE_PORT=$(kubectl::getNodePortByService ${INGRESS_SERVICE_NAME} http -n $INGRESS_CONTROLLER_NAMESPACE)
  checkInteractiveMode

  print_info "Check that the applications are still not accessible from the external IP (master node address)"
  print_debug "Note that the ingress controller is working correctly. The '404 not found' message indicates"
  print_debug "that ingress has not been configured for the application services."
  checkServicesAvailable $NODE_PORT

  kubectl::apply $CONFIGFILE_INGRESS && sleep 5
  kubectl::showIngresses
  kubectl::showIngressesDescription $INGRESS_NAME

  print_info "Check that now the applications are accessible from the external IP (master node address)"
  checkServicesAvailable $NODE_PORT

  print_info "Check access from traditional port 80 via proxy"
  print_debug "Only if a proxy is used on the master node to redirect traffic from the traditional"
  print_debug "ports (80 for HTTP and 443 for HTTPS) to the ports exposed by the ingress controller"
  #print_debug "Note that the port 80 has only been enabled on master node"
  checkServicesAvailable 80

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
