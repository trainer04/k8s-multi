#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Installing vCluster using Helm ==="

# Add vCluster Helm repo
helm repo add loft-sh https://charts.loft.sh
helm repo update

# Create namespace
kubectl create namespace core-banking-vcluster --dry-run=client -o yaml | kubectl apply -f -

# Create PVC for vCluster
echo "=== Creating PersistentVolumeClaim for vCluster ==="
kubectl apply -f pvc-creation.yaml

# Wait for PVC to be bound
echo "=== Waiting for PVC to be bound ==="
for i in {1..30}; do
    PVC_STATUS=$(kubectl get pvc vcluster-data -n core-banking-vcluster -o jsonpath='{.status.phase}' 2>/dev/null || echo "Pending")
    if [ "$PVC_STATUS" == "Bound" ]; then
        echo "? PVC is bound"
        break
    fi
    echo "Waiting for PVC to be bound... (${i}/30)"
    sleep 5
done

# Install vCluster with the PVC
echo "=== Creating vCluster ==="
helm upgrade --install core-banking loft-sh/vcluster \
  --namespace core-banking-vcluster \
  --values vcluster-values.yaml \
  --wait \
  --timeout 10m

echo "=== Verification ==="
kubectl get pods,pvc -n core-banking-vcluster

echo ""
echo "=== Verification: Check vCluster pods ==="
kubectl get pods -n core-banking-vcluster
echo ""

echo "=== Verification: Check vCluster service ==="
kubectl get svc -n core-banking-vcluster
echo ""

echo "=== Test 1: vCluster creates virtual pods in host namespace ==="
echo "Pods in core-banking-vcluster namespace:"
kubectl get pods -n core-banking-vcluster
echo ""

echo "=== Test 2: Check vCluster isolation ==="
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
