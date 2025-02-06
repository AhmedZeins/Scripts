#!/bin/bash

set -e  # Exit on error

echo "Configuring Git to store credentials permanently..."

# Check if Git is installed
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Please install Git first."
    exit 1
fi

# Set Git to store credentials
git config --global credential.helper store

echo "Git is now configured to store credentials."
echo "The next time you push or pull, enter your GitHub username and Personal Access Token (PAT)."
echo "Git will remember your credentials automatically for future operations."
