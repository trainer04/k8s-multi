#!/bin/bash

set -e

countdown() {
    local seconds=$1
    local message=${2:-"Waiting"}
    
    while [ $seconds -gt 0 ]; do
        echo -ne "${message}: ${seconds}s remaining...\r"
        sleep 1
        ((seconds--))
    done
    echo -e "${message}: done!          \r"
}

echo "=== Installing vCluster using Helm ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Creating local-path storage
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml

# Add vCluster Helm repo
helm repo add loft-sh https://charts.loft.sh
helm repo update

# Create namespace
kubectl create namespace core-banking-vcluster --dry-run=client -o yaml | kubectl apply -f -

# Create PVC for etcd
kubectl apply -f pvc-etcd.yaml

# Install vCluster using Helm
echo "=== Creating vCluster ==="
helm upgrade --install core-banking loft-sh/vcluster \
  --namespace core-banking-vcluster \
  --values vcluster-values.yaml \
  --wait

echo "=== Waiting for vCluster to be ready ==="
kubectl wait --for=condition=ready --timeout=300s pod -l app=vcluster -n core-banking-vcluster

countdown 5

echo ""
echo "=== Verification: Check vCluster pods ==="
kubectl get pods -n core-banking-vcluster
echo ""

echo "=== Verification: Check vCluster service ==="
kubectl get svc -n core-banking-vcluster
echo ""

echo "=== Check vCluster isolation ==="
echo "vCluster has its own API server and control plane"
kubectl logs -n core-banking-vcluster -l app=vcluster -c syncer --tail=10 | head -10
echo ""

echo "=== Test 3: Access vCluster (optional) ==="
echo "To connect to vCluster, you can use port-forward:"
echo ""
echo "  kubectl port-forward -n core-banking-vcluster service/core-banking 8443:443 &"
echo "  export KUBECONFIG=./vcluster-kubeconfig.yaml"
echo "  kubectl --kubeconfig=./vcluster-kubeconfig.yaml get nodes"
echo ""

echo "=== Summary ==="
echo "vCluster: core-banking"
echo "Namespace: core-banking-vcluster"
echo "Features demonstrated:"
echo "  - Virtual Kubernetes cluster running as pods"
echo "  - Own control plane (API server, controller-manager, etcd)"
echo "  - Syncer component bridges virtual and host cluster"
echo "  - Pods run in host cluster but managed by vCluster"
echo ""
echo "Note: Full vCluster testing requires vcluster CLI"
echo "Install with: curl -s -L https://github.com/loft-sh/vcluster/releases/latest | sed -nE 's!.*\"([^\"]*vcluster-darwin-amd64)\".*!\\1!p' | xargs -I {} curl -L -o vcluster {} && chmod +x vcluster"
echo ""
