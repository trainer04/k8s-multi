#!/bin/bash

set -e

echo "=== Deploying namespace with basic isolation ==="
echo ""

# Apply manifests
kubectl apply -f namespace.yaml
kubectl apply -f rbac.yaml
kubectl apply -f resourcequota.yaml
kubectl apply -f limitrange.yaml

echo ""
echo "=== Waiting for resources to be ready ==="
sleep 2

echo ""
echo "=== Verification: Check namespace ==="
kubectl get ns digital-team
echo ""

echo "=== Verification: Check ResourceQuota ==="
kubectl get resourcequota -n digital-team
kubectl describe resourcequota digital-team-quota -n digital-team | grep -A 10 "Used"
echo ""

echo "=== Verification: Check LimitRange ==="
kubectl get limitrange -n digital-team
echo ""

echo "=== Test: Developer can list pods in their namespace ==="
kubectl --as=dev-user --as-group=digital-team get pods -n digital-team && echo "SUCCESS: Developer can access their namespace" || echo "FAILED"
echo ""

echo "=== Test: Developer CANNOT list pods in other namespaces ==="
kubectl --as=dev-user --as-group=digital-team get pods -n kube-system 2>&1 | grep -q "Forbidden" && echo "SUCCESS: Access denied to other namespaces" || echo "WARNING: Should be forbidden"
echo ""

echo "=== Test: Create a test pod ==="
kubectl --as=dev-user --as-group=digital-team run nginx --image=nginx -n digital-team && echo "SUCCESS: Pod created" || echo "Pod creation test"
sleep 3
kubectl get pods -n digital-team
echo ""

echo "=== Summary ==="
echo "Namespace: digital-team"
echo "ResourceQuota: Limits CPU, Memory, Storage"
echo "LimitRange: Default limits for pods"
echo "RBAC: dev-user can only access digital-team namespace"
echo ""
