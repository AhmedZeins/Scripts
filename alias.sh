#!/bin/bash

# Create kubectl alias and enable autocompletion
echo "Setting up kubectl alias and autocompletion..."

# Get user's home directory (works with/without sudo)
USER_HOME=$(eval echo ~${SUDO_USER:-$USER})

# Add kubectl alias to bashrc
echo "alias k=kubectl" >> "$USER_HOME/.bashrc"

# Enable kubectl autocompletion
echo 'source <(kubectl completion bash)' >> "$USER_HOME/.bashrc"

# Enable alias autocompletion
echo 'complete -o default -F __start_kubectl k' >> "$USER_HOME/.bashrc"

# Fix permissions for kubectl config if exists
echo "Checking kubectl permissions..."
if [ -f "$USER_HOME/.config" ]; then
    sudo chown $(id -u):$(id -g) "$USER_HOME/.config"
    echo "Updated kubectl permissions"
else
    echo "Kubeconfig not found at $USER_HOME/.config - Skipping permission fix"
    echo "This will auto-resolve when you create a cluster or generate config"
fi

# Apply changes to current session
source "$USER_HOME/.bashrc"

echo "Setup complete!"
echo "You can now use 'k' instead of 'kubectl' with autocompletion."
