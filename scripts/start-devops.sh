#!/bin/bash

set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

PROJECT_ROOT=$(dirname "$SCRIPT_DIR")

HARBOR_DIR="$PROJECT_ROOT/k8s/labs/day47/harbor/harbor"

echo "===================================="
echo " Starting Project Shanghai 2027 "
echo "===================================="


echo ""
echo "[ Docker ]"

if systemctl is-active --quiet docker; then
    echo "Docker already running"
else
    echo "Starting Docker..."
    sudo systemctl start docker
fi


echo ""
echo "[ Harbor ]"

HARBOR_DIR="$HOME/Project-Shanghai-2027/k8s/labs/day47/harbor/harbor"

cd "$HARBOR_DIR"

docker compose up -d

echo "Harbor started"


echo ""
echo "[ Minikube ]"

if minikube status >/dev/null 2>&1; then
    echo "Minikube already running"
else
    echo "Starting Minikube..."
    minikube start
fi


echo ""
echo "[ GitHub Runner ]"

RUNNER_SERVICE="actions.runner.HuAN-ME-Project-Shanghai-2027.rocky-devops-runner.service"

if systemctl is-active --quiet "$RUNNER_SERVICE"; then
    echo "Runner already running"
else
    echo "Starting Runner..."
    sudo systemctl start "$RUNNER_SERVICE"
fi


echo ""
echo "Running health check..."

"$SCRIPT_DIR/health-check.sh"


echo ""
echo "===================================="
echo " Environment Ready "
echo "===================================="
