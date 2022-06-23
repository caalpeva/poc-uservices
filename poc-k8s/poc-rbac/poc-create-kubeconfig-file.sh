#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../../poc-docker/utils/docker.src"
source "${DIR}/../utils/kubectl.src"

TMP_DIRECTORY="${DIR}/tmp"
DEFAULT_KUBERNETES_DIR=/etc/kubernetes/pki
DEFAULT_SERVER_ADDRESS="https://192.168.100.10:6443"

FROM_MASTER_NODE=false
SERVER_FROM_ADMIN_KUBECONFIG=true

KUBERNETES_DIR=${DEFAULT_KUBERNETES_DIR}
[ $FROM_MASTER_NODE = false ] && KUBERNETES_DIR=${DIR}/ca

SERVER_ADDRESS=${DEFAULT_SERVER_ADDRESS}
[ $SERVER_FROM_ADMIN_KUBECONFIG = true ] &&
   SERVER_ADDRESS=$(kubectl config view | grep server: | awk '{print $2}')

function createKubeconfigFile {
  USER=$1
  GROUP=$2
  KUBECONFIG_FILE=${TMP_DIRECTORY}/${USER}-config
  print_info "Create the key for the certificate"
  xtrace on
  openssl genrsa -out ${TMP_DIRECTORY}/${USER}.key 2048
  xtrace off
  checkInteractiveMode

  print_info "Create the certificate signing request file (CSR)"
  xtrace on
  openssl req -new \
    -key ${TMP_DIRECTORY}/${USER}.key \
    -out ${TMP_DIRECTORY}/${USER}.csr \
    -subj "/CN=${USER}/O=${GROUP}"
  xtrace off
  checkInteractiveMode

  print_info "Sign the certificate with the certificate authority (CA)"
  xtrace on
  sudo openssl x509 -req -days 365 \
    -in ${TMP_DIRECTORY}/${USER}.csr \
    -CA ${KUBERNETES_DIR}/ca.crt \
    -CAkey ${KUBERNETES_DIR}/ca.key \
    -CAcreateserial \
    -out ${TMP_DIRECTORY}/${USER}.crt
  xtrace off
  checkInteractiveMode

  print_info "Create kubeconfig file with cluster data"
  xtrace on
  kubectl --kubeconfig=${KUBECONFIG_FILE} \
    config set-cluster kubernetes \
    --server ${SERVER_ADDRESS} \
    --certificate-authority=${KUBERNETES_DIR}/ca.crt \
    --embed-certs=true
  xtrace off
  checkInteractiveMode

  print_info "Add the user data with their certificates to the kubeconfig file"
  xtrace on
  kubectl --kubeconfig=${KUBECONFIG_FILE} \
    config set-credentials ${USER} \
    --client-certificate=${TMP_DIRECTORY}/${USER}.crt \
    --client-key=${TMP_DIRECTORY}/${USER}.key \
    --embed-certs=true
  xtrace off
  checkInteractiveMode

  print_info "Create the context to establish the relationship between the user and the cluster"
  xtrace on
  kubectl --kubeconfig=${KUBECONFIG_FILE} \
    config set-context ${USER}@kubernetes \
    --user=${USER} \
    --cluster=kubernetes \
    --namespace=default
  xtrace off
  checkInteractiveMode

  print_info "Set the context to default"
  xtrace on
  kubectl --kubeconfig=${KUBECONFIG_FILE} \
    config use-context ${USER}@kubernetes
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
    " - Set the variable FROM_MASTER_NODE to true if this script will be executed on the master node." \
    "   Otherwise, you must copy the master node files ca.crt and ca.key from ${DEFAULT_KUBERNETES_DIR}" \
    "   to the path ${DIR}/ca in your local machine." \
    " - Set the variable SERVER_FROM_ADMIN_KUBECONFIG to true to extract master node address from" \
    "   current kubeconfig. Otherwise, you must configure the variable DEFAULT_SERVER_ADDRESS."

  checkInteractiveMode

  createKubeconfigFile $USERNAME "developers"

  print_done "Kubeconfig created"
  exit 0
}

main $@
