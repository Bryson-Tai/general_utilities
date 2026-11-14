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

helm upgrade nvidia-gpu-operator nvidia/gpu-operator \
    --wait --install \
    --create-namespace  \
    --namespace gpu-operator  \
    --values "${CURRENT_DIR}/gpu-operator-values.yaml"
