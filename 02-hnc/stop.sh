#!/bin/bash

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

echo "=== Cleaning up HNC resources ==="

# Uninstall HNC
echo "=== Uninstalling HNC ==="
HNC_VERSION=v1.1.0
kubectl delete -f https://github.com/kubernetes-retired/hierarchical-namespaces/releases/download/${HNC_VERSION}/default.yaml --ignore-not-found=true

countdown 10

# Delete parent namespace
kubectl delete namespace analytics --ignore-not-found=true
kubectl delete namespace analytics-prod --ignore-not-found=true
kubectl delete namespace analytics-staging --ignore-not-found=true
kubectl delete namespace analytics-dev --ignore-not-found=true

echo "Waiting for namespaces to be deleted..."
countdown 10

# Delete namespace
kubectl delete namespace hnc-system --ignore-not-found=true

echo ""
echo "=== Cleanup completed ==="
echo "All HNC resources removed, cluster returned to original state"
