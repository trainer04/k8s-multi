#!/bin/bash

set -e

echo "Testing vCluster isolation..."
echo ""

echo "1. Connecting to vCluster..."
vcluster connect core-banking -n core-banking-vcluster -- bash -c "
  echo 'Connected to vCluster!'
  echo ''

  echo '2. Installing Strimzi Kafka Operator...'
  kubectl create namespace kafka --dry-run=client -o yaml | kubectl apply -f -
  kubectl apply -f https://strimzi.io/install/latest -n kafka

  echo ''
  echo '3. Waiting for Strimzi to be ready...'
  kubectl wait --for=condition=available --timeout=120s deployment/strimzi-cluster-operator -n kafka

  echo ''
  echo '4. Checking CRD inside vCluster:'
  kubectl get crd | grep kafka || echo 'No Kafka CRDs found'

  echo ''
  echo '5. Creating Kafka cluster...'
  kubectl apply -f kafka-cluster.yaml

  echo ''
  echo 'Waiting for Kafka cluster...'
  sleep 10
  kubectl get kafka -n kafka
"

echo ""
echo "6. Disconnecting from vCluster..."
vcluster disconnect

echo ""
echo "7. Checking CRD in host cluster (should be empty):"
kubectl get crd | grep kafka || echo "No Kafka CRDs in host - isolation works!"

echo ""
echo "Isolation test completed!"
