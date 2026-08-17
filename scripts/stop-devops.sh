#!/bin/bash

set -e


SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

PROJECT_ROOT=$(dirname "$SCRIPT_DIR")

HARBOR_DIR="$PROJECT_ROOT/k8s/labs/day47/harbor/harbor"


echo "===================================="
echo " Stopping Project Shanghai 2027 "
echo "===================================="


echo ""
echo "[ Minikube ]"

if minikube status >/dev/null 2>&1; then
    echo "Stopping Minikube..."
    minikube stop
else
    echo "Minikube already stopped"
fi



echo ""
echo "[ Harbor ]"

if [ -d "$HARBOR_DIR" ]; then

    cd "$HARBOR_DIR"

    docker compose stop

    echo "Harbor stopped"

else

    echo "Harbor directory not found"

fi



echo ""
echo "[ GitHub Runner ]"


RUNNER_SERVICE="actions.runner.HuAN-ME-Project-Shanghai-2027.rocky-devops-runner.service"


if systemctl is-active --quiet "$RUNNER_SERVICE"; then

    echo "Stopping Runner..."

    sudo systemctl stop "$RUNNER_SERVICE"

else

    echo "Runner already stopped"

fi



echo ""
echo "===================================="
echo " Environment Shutdown Complete "
echo "===================================="
