#!/bin/bash

echo "=== Cleaning up HNC resources ==="

# Delete parent namespace (this will cascade delete children)
kubectl delete namespace analytics --ignore-not-found=true

echo "Waiting for namespaces to be deleted..."
sleep 5

# Uninstall HNC
echo "=== Uninstalling HNC ==="
HNC_VERSION=v1.1.0
kubectl delete -f https://github.com/kubernetes-retired/hierarchical-namespaces/releases/download/${HNC_VERSION}/default.yaml --ignore-not-found=true

# Delete namespace
kubectl delete namespace hnc-system --ignore-not-found=true

echo ""
echo "=== Cleanup completed ==="
echo "All HNC resources removed, cluster returned to original state"
