#!/bin/bash

set -e  # Exit on error

# Determine OS type
OS=$(uname -s)
ARCH=$(uname -m)
TERRAFORM_VERSION="latest"
INSTALL_DIR="/usr/local/bin"

# Function to get the latest Terraform version
get_latest_version() {
    curl -sL https://api.github.com/repos/hashicorp/terraform/releases/latest | grep '"tag_name":' | awk -F '"' '{print $4}' | sed 's/v//'
}

# Function to download and install Terraform
install_terraform() {
    echo "Detecting OS..."
    case "$OS" in
        "Linux")
            echo "Linux detected."
            ;;
        "Darwin")
            echo "macOS detected."
            ;;
        *)
            echo "Unsupported OS: $OS"
            exit 1
            ;;
    esac

    if [[ "$TERRAFORM_VERSION" == "latest" ]]; then
        TERRAFORM_VERSION=$(get_latest_version)
    fi

    echo "Downloading Terraform v$TERRAFORM_VERSION..."

    case "$ARCH" in
        "x86_64")
            ARCH="amd64"
            ;;
        "arm64" | "aarch64")
            ARCH="arm64"
            ;;
        *)
            echo "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac

    DOWNLOAD_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${OS,,}_${ARCH}.zip"
    TEMP_DIR=$(mktemp -d)

    echo "Downloading from: $DOWNLOAD_URL"
    curl -sLo "$TEMP_DIR/terraform.zip" "$DOWNLOAD_URL"

    echo "Extracting Terraform..."
    unzip -o "$TEMP_DIR/terraform.zip" -d "$TEMP_DIR"

    echo "Installing Terraform..."
    sudo mv "$TEMP_DIR/terraform" "$INSTALL_DIR/terraform"
    sudo chmod +x "$INSTALL_DIR/terraform"

    echo "Cleaning up..."
    rm -rf "$TEMP_DIR"

    echo "Terraform installation completed!"
    terraform version
}

# Run installation function
install_terraform
