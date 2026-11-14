#! /bin/bash

set -euo pipefail

kubectl config use-context "${KUBE_CONTEXT}"

if [ "$(kubectl config current-context)" != "${KUBE_CONTEXT}" ]; then
    printf "Failed to switch to context %s\n" "${KUBE_CONTEXT}"
    exit 1
fi

# Add the NVIDIA helm repository
helm repo add nvidia https://nvidia.github.io/gpu-operator
helm repo update

helm install \
    --wait --generate-name \
    --create-namespace --upgrade \
    --namespace gpu-operator  \
    --values "$CURRENT_DIR/gpu-operator-values.yaml" \
    nvidia/gpu-operator
