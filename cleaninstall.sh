#!/bin/bash

set -e

echo "🧼 STEP 0: Set noninteractive frontend (skip prompts)..."
export DEBIAN_FRONTEND=noninteractive

echo "🔧 STEP 1: Fully update and install core utilities..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
    apt-transport-https ca-certificates curl software-properties-common \
    lsb-release gnupg2 unzip git jq net-tools wget nano htop

echo "🐍 STEP 2: Install Python3 and development libraries..."
sudo apt install -y python3 python3-pip python3-venv \
    libssl-dev libffi-dev build-essential

echo "🐳 STEP 3: Install Docker (official method)..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "🔁 STEP 4: Enable Docker and permanently add user to docker group..."
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

echo "🐍 STEP 5: Install helpful Python packages (optional support tools)..."
python3 -m pip install --upgrade pip
python3 -m pip install virtualenv requests pandas flask

echo "📁 STEP 6: Clone the Beer Game repo..."
cd ~
if [ -d "blockchain-demonstrator-serious-game" ]; then
  echo "📦 Repo already exists, pulling latest changes..."
  cd blockchain-demonstrator-serious-game && git pull
else
  git clone https://github.com/Hogeschool-Windesheim/blockchain-demonstrator-serious-game.git
  cd blockchain-demonstrator-serious-game
fi

echo "🏗️ STEP 7: Build Docker image..."
docker build -t beergame .

echo "⚡ STEP 8: Activate docker group in this session (no logout needed)..."
newgrp docker <<EONG
echo "🚀 Running Beer Game container on http://localhost:5000 ..."
docker run -d -p 5000:80 --name beergame beergame
EONG

echo "✅ DONE"
echo "--------------------------------------------"
echo "🕹️ Open your browser and go to: http://localhost:5000"
echo "🛑 To stop the game:   docker stop beergame && docker rm beergame"
echo "🔁 To rerun:           docker run -d -p 5000:80 --name beergame beergame"
echo "ℹ️ Group change is permanent, but relogin is recommended for all terminal sessions."
