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

set +euo pipefail

helm upgrade nvidia-gpu-operator nvidia/gpu-operator \
    --wait --install \
    --create-namespace  \
    --namespace gpu-operator  \
    --values "${CURRENT_DIR}/bash/gpu-operator-values.yaml" || true

# Set toleration for the node-feature-discovery-master deployment to schedule on GPU nodes
## This is due to Helm Chart not setting the tolerations for the master deployment by default
kubectl patch deploy nvidia-gpu-operator-node-feature-discovery-master \
    -n gpu-operator \
    --type=json \
    -p '[{"op":"add","path":"/spec/template/spec/tolerations/-","value":{"key":"sku","operator":"Equal","value":"gpu","effect":"NoSchedule"}}]'

kubectl patch job gpu-operator-cleanup-gpucluster  \
    -n gpu-operator \
    --type=json \
    -p '[{"op":"add","path":"/spec/template/spec/tolerations/-","value":{"key":"sku","operator":"Equal","value":"gpu","effect":"NoSchedule"}}]'
