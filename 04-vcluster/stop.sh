#!/bin/bash

echo "=== Cleaning up vCluster ==="

# Uninstall vCluster using Helm
helm uninstall core-banking -n core-banking-vcluster --ignore-not-found 2>/dev/null || true

# Delete namespace
kubectl delete namespace core-banking-vcluster --ignore-not-found=true

echo ""
echo "=== Cleanup completed ==="
echo "All vCluster resources removed, cluster returned to original state"
