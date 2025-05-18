#!/bin/bash

set -e

# Colors
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

# Title
clear
echo -e "${CYAN}========================================="
echo -e " ETHEREUM SEPOLIA NODE SETUP SCRIPT"
echo -e "            by MeG"
echo -e "=========================================${RESET}"

# Step 1: System Packages
echo -e "${YELLOW}Installing system packages...${RESET}"
sudo apt update && sudo apt upgrade -y
sudo apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip -y

# Step 2: Docker Setup
echo -e "${YELLOW}Setting up Docker...${RESET}"
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove -y $pkg; done
sudo apt install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo systemctl enable docker
sudo systemctl restart docker
sudo docker run hello-world

# Step 3: Directory Setup
echo -e "${YELLOW}Creating directories...${RESET}"
mkdir -p /root/ethereum/{execution,consensus}

# Step 4: JWT Secret
echo -e "${YELLOW}Generating JWT secret...${RESET}"
openssl rand -hex 32 > /root/ethereum/jwt.hex
cat /root/ethereum/jwt.hex

# Step 5: docker-compose.yml
echo -e "${YELLOW}Creating docker-compose.yml...${RESET}"
cat > /root/ethereum/docker-compose.yml <<EOF
services:
  geth:
    image: ethereum/client-go:stable
    container_name: geth
    network_mode: host
    restart: unless-stopped
    ports:
      - 30303:30303
      - 30303:30303/udp
      - 8545:8545
      - 8546:8546
      - 8551:8551
    volumes:
      - /root/ethereum/execution:/data
      - /root/ethereum/jwt.hex:/data/jwt.hex
    command:
      - --sepolia
      - --http
      - --http.api=eth,net,web3
      - --http.addr=0.0.0.0
      - --authrpc.addr=0.0.0.0
      - --authrpc.vhosts=*
      - --authrpc.jwtsecret=/data/jwt.hex
      - --authrpc.port=8551
      - --syncmode=snap
      - --datadir=/data

  prysm:
    image: gcr.io/prysmaticlabs/prysm/beacon-chain
    container_name: prysm
    network_mode: host
    restart: unless-stopped
    depends_on:
      - geth
    volumes:
      - /root/ethereum/consensus:/data
      - /root/ethereum/jwt.hex:/data/jwt.hex
    ports:
      - 4000:4000
      - 3500:3500
    command:
      - --sepolia
      - --accept-terms-of-use
      - --datadir=/data
      - --disable-monitoring
      - --rpc-host=0.0.0.0
      - --execution-endpoint=http://127.0.0.1:8551
      - --jwt-secret=/data/jwt.hex
      - --rpc-port=4000
      - --grpc-gateway-corsdomain=*
      - --grpc-gateway-host=0.0.0.0
      - --grpc-gateway-port=3500
      - --min-sync-peers=3
      - --checkpoint-sync-url=https://checkpoint-sync.sepolia.ethpandaops.io
      - --genesis-beacon-api-url=https://checkpoint-sync.sepolia.ethpandaops.io
EOF

# Step 6: Firewall
echo -e "${YELLOW}Setting up UFW firewall...${RESET}"
sudo ufw allow 22
sudo ufw allow ssh
sudo ufw allow 30303/tcp
sudo ufw allow 30303/udp
sudo ufw allow from 127.0.0.1 to any port 8545 proto tcp
sudo ufw allow from 127.0.0.1 to any port 3500 proto tcp
sudo ufw reload

# Step 7: Start Node
echo -e "${GREEN}Starting Geth + Prysm nodes...${RESET}"
cd /root/ethereum
docker compose up -d

# Step 8: Done
echo -e "${GREEN}Ethereum Sepolia node is now running!${RESET}"
echo -e "Use ${CYAN}docker compose logs -f${RESET} to see logs."
echo -e "Access RPC: http://<your-ip>:8545  |  Prysm: http://<your-ip>:3500"
