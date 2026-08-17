#!/bin/bash

set -e

echo "===================================="
echo " Project Shanghai 2027 Health Check "
echo "===================================="


echo ""
echo "[ Docker ]"

if systemctl is-active --quiet docker; then
    echo "Status: OK"
else
    echo "Status: FAILED"
fi


echo ""
echo "[ Harbor ]"

HARBOR_DIR="$HOME/Project-Shanghai-2027/k8s/labs/day47/harbor/harbor"

if [ -d "$HARBOR_DIR" ]; then
    cd "$HARBOR_DIR"

    if docker compose ps | grep -q "Up"; then
        echo "Status: OK"
    else
        echo "Status: NOT RUNNING"
    fi
else
    echo "Harbor directory not found"
fi


echo ""
echo "[ Minikube ]"

if minikube status >/dev/null 2>&1; then
    echo "Status: OK"
else
    echo "Status: STOPPED"
fi


echo ""
echo "[ GitHub Runner ]"

RUNNER_SERVICE="actions.runner.HuAN-ME-Project-Shanghai-2027.rocky-devops-runner.service"

if systemctl is-active --quiet "$RUNNER_SERVICE"; then
    echo "Status: OK"
else
    echo "Status: NOT RUNNING"
fi


echo ""
echo "[ Helm ]"

if minikube status >/dev/null 2>&1; then

    if helm list -A >/dev/null 2>&1; then
        echo "Status: OK"
    else
        echo "Status: FAILED"
    fi

else

    echo "Status: SKIPPED (Kubernetes unavailable)"

fi


echo ""
echo "[ Proxy ]"

if curl -x http://192.168.157.1:7890 \
    -I --connect-timeout 5 https://github.com \
    >/dev/null 2>&1
then
    echo "Status: OK"
else
    echo "Status: FAILED"
fi

echo ""
echo "===================================="
echo " Health Check Finished "
echo "===================================="
