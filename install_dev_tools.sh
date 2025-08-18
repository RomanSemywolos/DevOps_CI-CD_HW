#!/bin/bash

set -e

# --- Docker ---
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    sudo apt update
    sudo apt install -y ca-certificates curl gnupg

    sudo mkdir -p /etc/apt/keyrings
    sudo chmod 755 /etc/apt/keyrings

    if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
    fi

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
else
    echo "Docker already installed, skipping."
fi

# --- Python ---
if command -v python3 &> /dev/null; then
    python_version=$(python3 -V 2>&1 | awk '{print $2}')
    if dpkg --compare-versions "$python_version" ge "3.9"; then
        echo "Python $python_version already installed, skipping."
    else
        echo "Updating Python..."
        sudo apt update
        sudo apt install -y software-properties-common
        sudo add-apt-repository -y ppa:deadsnakes/ppa
        sudo apt update
        sudo apt install -y python3.12 python3-pip python3-venv
    fi
else
    echo "Installing Python..."
    sudo apt update
    sudo apt install -y software-properties-common
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt update
    sudo apt install -y python3.12 python3-pip python3-venv
fi

# --- pip ---
if ! command -v pip3 &> /dev/null; then
    sudo apt install -y python3-pip
fi

# --- venv ---
if ! python3 -m venv --help &> /dev/null; then
    sudo apt install -y python3-venv
fi

# --- Django ---
if ! pip show django &> /dev/null; then
    echo "Installing Django in virtual environment..."
    mkdir -p ~/newproject
    cd ~/newproject
    python3 -m venv my_env
    source my_env/bin/activate
    pip install --upgrade pip
    pip install django
else
    echo "Django already installed, skipping."
fi
