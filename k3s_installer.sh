#!/bin/bash

# K3s Cluster Installation Script
# Usage: 
#   For server node: sudo ./install-k3s.sh --server
#   For agent node:  sudo ./install-k3s.sh --agent <SERVER_IP> <TOKEN>

# Exit immediately if any command fails
set -e

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root"
    exit 1
fi

# Configuration variables (customize as needed)
K3S_VERSION="v1.27.6+k3s1"  # Specify K3s version
FLANNEL_BACKEND="vxlan"      # Options: vxlan, host-gateway, wireguard
INSTALL_K3S_EXEC_SERVER="--flannel-backend=${FLANNEL_BACKEND} --disable=traefik"
INSTALL_K3S_EXEC_AGENT=""

# Functions
install_server() {
    echo "Installing K3s server..."
    curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${K3S_VERSION} \
    INSTALL_K3S_EXEC="${INSTALL_K3S_EXEC_SERVER}" sh -s - server --cluster-init

    # Wait for token to be created
    until [ -f /var/lib/rancher/k3s/server/node-token ]; do
        sleep 1
    done

    TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)
    IP=$(hostname -I | awk '{print $1}')

    echo "========================================================"
    echo "K3s server installed successfully!"
    echo "To join worker nodes, use the following command:"
    echo "  sudo ./install-k3s.sh --agent ${IP} ${TOKEN}"
    echo "========================================================"
}

install_agent() {
    SERVER_IP=$1
    TOKEN=$2

    if [ -z "$SERVER_IP" ] || [ -z "$TOKEN" ]; then
        echo "Missing required arguments for agent installation"
        echo "Usage: sudo $0 --agent <SERVER_IP> <TOKEN>"
        exit 1
    fi

    echo "Installing K3s agent joining ${SERVER_IP}..."
    curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${K3S_VERSION} \
    K3S_URL="https://${SERVER_IP}:6443" \
    K3S_TOKEN="${TOKEN}" \
    INSTALL_K3S_EXEC="${INSTALL_K3S_EXEC_AGENT}" sh -s - agent
}

# Main execution
case "$1" in
    --server)
        if systemctl is-active k3s >/dev/null 2>&1; then
            echo "K3s is already installed and running"
            exit 0
        fi
        install_server
        ;;
    --agent)
        if systemctl is-active k3s-agent >/dev/null 2>&1; then
            echo "K3s agent is already installed and running"
            exit 0
        fi
        shift
        install_agent "$@"
        ;;
    *)
        echo "Usage:"
        echo "  Server: sudo $0 --server"
        echo "  Agent:  sudo $0 --agent <SERVER_IP> <TOKEN>"
        exit 1
        ;;
esac

# Post-installation instructions
if [ "$1" = "--server" ]; then
    echo "========================================================"
    echo "To access your cluster:"
    echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml"
    echo "kubectl get nodes"
    echo "========================================================"
fi
