#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../../poc-docker/utils/docker.src"
source "${DIR}/../utils/kubectl.src"

TMP_DIRECTORY="${DIR}/tmp"
MASTER_NODE=false
DEFAULT_KUBERNETES_DIR=/etc/kubernetes/pki

[ $MASTER_NODE = true ] &&
   KUBERNETES_DIR=${DEFAULT_KUBERNETES_DIR} ||
   KUBERNETES_DIR=${DIR}/ca

function createKubeconfigFile {
  USERNAME=$1
  GROUP=$2
  KUBECONFIG_FILE=${TMP_DIRECTORY}/${USERNAME}-config
  print_info "Create the key for the certificate"
  xtrace on
  openssl genrsa -out ${TMP_DIRECTORY}/${USERNAME}.key 2048
  xtrace off
  checkInteractiveMode

  print_info "Create the certificate signing request file (CSR)"
  xtrace on
  openssl req -new \
    -key ${TMP_DIRECTORY}/${USERNAME}.key \
    -out ${TMP_DIRECTORY}/${USERNAME}.csr \
    -subj "/CN=${USERNAME}/O=${GROUP}"
  xtrace off
  checkInteractiveMode

  print_info "Sign the certificate with the certificate authority (CA)"
  xtrace on
  sudo openssl x509 -req -days 365 \
    -in ${TMP_DIRECTORY}/${USERNAME}.csr \
    -CA ${KUBERNETES_DIR}/ca.crt \
    -CAkey ${KUBERNETES_DIR}/ca.key \
    -CAcreateserial \
    -out ${TMP_DIRECTORY}/${USERNAME}.crt
  xtrace off
  checkInteractiveMode

  print_info "Create kubeconfig file with cluster data"
  xtrace on
  kubectl --kubeconfig=${KUBECONFIG_FILE} \
    config set-cluster kubernetes \
    --server https://192.168.100.10:6443 \
    --certificate-authority=${KUBERNETES_DIR}/ca.crt \
    --embed-certs=true
  xtrace off
  checkInteractiveMode

  print_info "Add the user data with their certificates to the kubeconfig file"
  xtrace on
  kubectl --kubeconfig=${KUBECONFIG_FILE} \
    config set-credentials ${USERNAME} \
    --client-certificate=${TMP_DIRECTORY}/${USERNAME}.crt \
    --client-key=${TMP_DIRECTORY}/${USERNAME}.key \
    --embed-certs=true
  xtrace off
  checkInteractiveMode

  print_info "Create the context to establish the relationship between the user and the cluster"
  xtrace on
  kubectl --kubeconfig=${KUBECONFIG_FILE} \
    config set-context ${USERNAME}@kubernetes \
    --user=${USERNAME} \
    --cluster=kubernetes \
    --namespace=default
  xtrace off
  checkInteractiveMode

  print_info "Set the context to default"
  xtrace on
  kubectl --kubeconfig=${KUBECONFIG_FILE} \
    config use-context ${USERNAME}@kubernetes
  xtrace off
  checkInteractiveMode
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@

  print_debug "Creating temporal files..."
  rm -rf ${TMP_DIRECTORY}
  if [ ! -d ${TMP_DIRECTORY} ]; then
    xtrace on
    mkdir ${TMP_DIRECTORY}
    xtrace off
  fi

  print_box "CREATE KUBECONFIG FILE" \
    "" \
    " - Generate the certificate for the user signed by the certifying authority (CA)" \
    "   of the kubernetes installation and create the kubeconfig file for the user." \
    " - Set the variable NODE_MASTER to true if this script will be executed on the master node." \
    "   Otherwise, you must copy the master node files ca.crt and ca.key from ${DEFAULT_KUBERNETES_DIR}" \
    "   to the path ${DIR}/ca in your local machine."
  checkInteractiveMode

  createKubeconfigFile "user" "developers"

  print_done "Kubeconfig created"
  exit 0
}

main $@
