#!/bin/bash

echo "=== Cleaning up Capsule resources ==="

# Delete test namespace
kubectl delete namespace mobile-app --ignore-not-found=true

# Delete Tenants
kubectl delete tenant digital-channels analytics --ignore-not-found=true

echo "Waiting for tenant namespaces to be deleted..."
sleep 5

# Uninstall Capsule
echo "=== Uninstalling Capsule Helm release ==="
helm uninstall capsule -n capsule-system --ignore-not-found 2>/dev/null || true

# Delete namespace
echo "=== Deleting capsule-system namespace ==="
kubectl delete namespace capsule-system --ignore-not-found=true

echo ""
echo "=== Cleanup completed ==="
echo "All Capsule resources removed, cluster returned to original state"
