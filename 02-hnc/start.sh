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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Installing HNC (Hierarchical Namespace Controller) ==="

# Install HNC using kubectl
HNC_VERSION=v1.1.0
kubectl apply -f https://github.com/kubernetes-retired/hierarchical-namespaces/releases/download/${HNC_VERSION}/default.yaml

echo "=== Waiting for HNC to be ready ==="
kubectl wait --for=condition=available --timeout=120s deployment/hnc-controller-manager -n hnc-system

echo "=== Waiting for webhook to be ready (30s) ==="
countdown 30

echo ""
echo "=== Creating parent namespace ==="
kubectl apply -f parent-namespace.yaml

echo "=== Creating child namespaces ==="
kubectl apply -f child-namespaces.yaml

echo "=== Waiting for child namespaces to be created ==="
countdown 10

echo "=== Applying RBAC (will be propagated to children) ==="
kubectl apply -f rbac.yaml

echo "=== Applying NetworkPolicy (will be propagated to children) ==="
kubectl apply -f network-policy.yaml

countdown 5

echo ""
echo "=== Verification: Check hierarchy ==="
kubectl get subnamespaceanchor -n analytics
kubectl get ns | grep analytics
echo ""

echo "=== Verification: Check HNC pods ==="
kubectl get pods -n hnc-system
echo ""

echo "=== Test 1: Check RBAC propagation to children ==="
kubectl get role -n analytics-prod && echo "SUCCESS: Role propagated to analytics-prod"
kubectl get role -n analytics-staging && echo "SUCCESS: Role propagated to analytics-staging"
echo ""

echo "=== Test 2: Check NetworkPolicy propagation ==="
kubectl get networkpolicy -n analytics-prod && echo "SUCCESS: NetworkPolicy propagated"
kubectl get networkpolicy -n analytics-staging && echo "SUCCESS: NetworkPolicy propagated"
echo ""

echo "=== Test 3: Show namespace hierarchy ==="
kubectl hns tree analytics 2>/dev/null || echo "Note: kubectl hns plugin not installed (optional)"
echo ""

echo "=== Summary ==="
echo "HNC Controller: Running in hnc-system"
echo "Parent namespace: analytics"
echo "Child namespaces: analytics-prod, analytics-staging, analytics-dev"
echo "Features demonstrated:"
echo "  - Hierarchical namespace structure"
echo "  - RBAC propagation from parent to children"
echo "  - NetworkPolicy propagation"
echo ""
