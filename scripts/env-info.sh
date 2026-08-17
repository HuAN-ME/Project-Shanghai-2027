#!/bin/bash

echo "===================================="
echo " Project Shanghai 2027 Environment "
echo "===================================="


echo ""
echo "[ System ]"

cat /etc/os-release | grep PRETTY_NAME

echo "Kernel:"
uname -r


echo ""
echo "[ Docker ]"

docker --version


echo ""
echo "[ Git ]"

git --version


echo ""
echo "[ Kubernetes ]"

if kubectl version --client >/dev/null 2>&1; then
    kubectl version --client 2>/dev/null | head -n 2
else
    echo "kubectl not installed"
fi


echo ""
echo "[ Minikube ]"

if minikube version >/dev/null 2>&1; then
    minikube version | head -1
else
    echo "Minikube not installed"
fi


echo ""
echo "[ Helm ]"

if helm version >/dev/null 2>&1; then
    helm version --short
else
    echo "Helm not installed"
fi


echo ""
echo "[ Harbor ]"

HARBOR_DIR="$HOME/Project-Shanghai-2027/k8s/labs/day47/harbor/harbor"

if [ -d "$HARBOR_DIR" ]; then
    echo "Harbor directory:"
    echo "$HARBOR_DIR"

    cd "$HARBOR_DIR"

    docker compose images | grep goharbor | head -5 \
    || echo "Harbor version unknown"

else
    echo "Harbor not found"
fi


echo ""
echo "[ GitHub Runner ]"

RUNNER_SERVICE=$(systemctl list-units --type=service \
| grep actions.runner \
| awk '{print $1}')

if [ -n "$RUNNER_SERVICE" ]; then
    systemctl is-active "$RUNNER_SERVICE"
else
    echo "Runner not found"
fi

echo ""
echo "[ Network ]"

echo "Default route:"
ip route | grep default

echo "Proxy environment:"
env | grep -i proxy || echo "No proxy env"

echo ""
echo "===================================="
echo " Environment Info Finished "
echo "===================================="
