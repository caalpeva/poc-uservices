#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../../utils/microservices-utils.src"
source "${DIR}/../../utils/helm.src"

#############
# VARIABLES #
#############

REGISTRY_CONTAINER_NAME="poc-registry-for-chart-storage"

REGISTRY_URL="localhost:5000"
REPOSITORY="helm-charts"

CHART_NAME="tomcat"
CHART_VERSION="3.0.0"
CHART_FILENAME="$CHART_NAME-$CHART_VERSION.tgz"

#############
# FUNCTIONS #
#############

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

function cleanup() {
  print_debug "Cleaning environment..."
  containers=($(docker::getAllContainerIdsByPrefix ${REGISTRY_CONTAINER_NAME}))
  docker::removeContainers ${containers[*]}
}

function executeRegistryContainer() {
  xtrace on
  docker run -d \
    --restart always \
    --name ${REGISTRY_CONTAINER_NAME} \
    -p 5000:5000 \
    -v $PWD/data/:/var/lib/registry \
    registry:2

  xtrace off
}

function main() {
  print_debug "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_info "Execute registry container"
  executeRegistryContainer

  print_info "Check containers status again..."
  docker::showContainersByPrefix ${REGISTRY_CONTAINER_NAME}

  helm::packageChart $CHART_NAME --version $CHART_VERSION

  # echo "mypass" | helm registry login $REGISTRY_URL -u myuser --password-stdin

  print_info "Push chart to local registry"
  helm::pushChart "$DIR/$CHART_FILENAME" "oci://$REGISTRY_URL/$REPOSITORY"

  print_info "Delete the chart archive"
  evalCommand rm "$DIR/$CHART_FILENAME"
  checkInteractiveMode

  print_info "Pull chart from local registry"
  helm::pullChart "oci://$REGISTRY_URL/$REPOSITORY/$CHART_NAME" --version $CHART_VERSION

  print_info "Check that the chart archive has been downloaded"
  evalCommand ls -l "$DIR/$CHART_FILENAME"
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

#############
# EXECUTION #
#############

main $@
