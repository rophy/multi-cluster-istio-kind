#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd "$SCRIPT_DIR"

NUM_CLUSTERS="${NUM_CLUSTERS:-2}"

for i in $(seq "${NUM_CLUSTERS}"); do
  echo "Starting with cluster${i}"
  kubectl create --context="cluster${i}" namespace sample
  kubectl label --context="cluster${i}" namespace sample \
      istio-injection=enabled
  kubectl apply --context="cluster${i}" \
      -f samples/helloworld/helloworld.yaml \
      -l service=helloworld -n sample

  v=$(($(($i%2))+1))
  kubectl apply --context="cluster${i}" \
      -f samples/helloworld/helloworld.yaml \
      -l version="v${v}" -n sample
  echo
done