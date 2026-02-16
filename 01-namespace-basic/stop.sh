#!/bin/bash

set -e

echo "Cleaning up namespace and resources..."

# Delete namespace (this will cascade delete all resources)
kubectl delete namespace digital-team --ignore-not-found=true

echo "Cleanup completed!"
